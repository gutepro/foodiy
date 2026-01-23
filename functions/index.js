const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const { ImageAnnotatorClient } = require("@google-cloud/vision");
const { Configuration, OpenAIApi } = require("openai");

if (!admin.apps.length) {
  admin.initializeApp();
}

const visionClient = new ImageAnnotatorClient();
const IMPORT_FN_VERSION = "2026-01-23-pdf-ocr-v1";
const IMPORT_FN_BUILD = "a3105ac1";
const openaiApiKey = process.env.OPENAI_API_KEY || functions.config().openai?.key;
console.log("[LLM] has key on init:", !!openaiApiKey);
const LLM_MODEL = "gpt-4o-mini";
const DEBUG_IMPORT =
  process.env.NODE_ENV !== "production" || functions.config().debug?.import === "true";
const openai = openaiApiKey
  ? new OpenAIApi(
      new Configuration({
        apiKey: openaiApiKey,
      }),
    )
  : null;
const db = admin.firestore();

const LANGUAGE_HINTS = ["he", "iw", "en"];
const MAX_TEXT_LENGTH = 20000;

function sanitizeText(raw) {
  return String(raw || "")
    .replace(/[\u0000-\u001F\u007F\u0080-\u009F]/g, " ")
    .replace(/[~^`|]/g, " ")
    .replace(/Ø/g, " ")
    .replace(/\s+\n/g, "\n")
    .replace(/[ \t]+/g, " ")
    .trim();
}

function normalizeForMatch(s) {
  return (s || "")
    .toString()
    .replace(/\u200F|\u200E|\u202A|\u202B|\u202C|\u2066|\u2067|\u2068|\u2069/g, "")
    .replace(/[“”„‟]/g, '"')
    .replace(/[‘’‚‛]/g, "'")
    .replace(/\.\.\.+/g, ".")
    .replace(/([!?,;:\-–—])\1+/g, "$1")
    .replace(/[!?,;:\-–—]{2,}/g, (m) => m[0])
    .replace(/\s+/g, " ")
    .trim();
}

function normalizeForTitle(s) {
  return (s || "")
    .toString()
    .toLowerCase()
    .replace(/[^A-Za-z0-9א-תء-يА-Яа-яЁёЀ-ӿ\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function includesEvidence(ocrText, evidence) {
  const ocr = normalizeForMatch(ocrText);
  const ev = normalizeForMatch(evidence);
  if (!ev || ev.length < 6) return false;
  return ocr.includes(ev);
}

function titleMatches(title, ocrText) {
  const normTitle = normalizeForTitle(title);
  const normOcr = normalizeForTitle(ocrText);
  if (!normTitle || !normOcr) return false;
  if (normOcr.includes(normTitle)) return true;
  const tokens = normTitle.split(" ").filter(Boolean);
  if (normTitle.length >= 6 && tokens.length > 0) {
    const matched = tokens.filter((t) => normOcr.includes(t)).length;
    if (matched / tokens.length >= 0.7) return true;
  }
  return false;
}

function appearsInOcr(term, ocrText) {
  const normalizedTerm = normalizeForMatch(term).toLowerCase();
  if (!normalizedTerm) return false;
  const normalizedOcr = normalizeForMatch(ocrText).toLowerCase();
  if (!normalizedOcr) return false;
  if (normalizedOcr.includes(normalizedTerm)) return true;
  const compactOcr = normalizedOcr.replace(/\s+/g, "");
  const compactTerm = normalizedTerm.replace(/\s+/g, "");
  return compactOcr.includes(compactTerm);
}

function detectLanguages(text) {
  const langs = new Set();
  if (/[א-ת]/.test(text)) langs.add("he");
  if (/[ء-ي]/.test(text)) langs.add("ar");
  if (/[А-Яа-яЁёЀ-ӿ]/.test(text)) langs.add("ru");
  if (/[A-Za-z]/.test(text)) langs.add("en");
  if (langs.size === 0) langs.add("unknown");
  return Array.from(langs);
}

function reconstructTextFromAnnotation(fullTextAnnotation) {
  const lines = [];
  let confidenceSum = 0;
  let confidenceCount = 0;
  const pages = (fullTextAnnotation && fullTextAnnotation.pages) || [];
  let lineId = 0;
  for (const page of pages) {
    for (const block of page.blocks || []) {
      for (const paragraph of block.paragraphs || []) {
        const words = paragraph.words || [];
        const text = words
          .map((w) => (w.symbols || []).map((s) => s.text || "").join(""))
          .join(" ")
          .trim();
        if (!text) continue;
        const vertices = (paragraph.boundingBox && paragraph.boundingBox.vertices) || [];
        const xs = vertices.map((v) => v.x || 0);
        const ys = vertices.map((v) => v.y || 0);
        const xCenter = xs.length > 0 ? xs.reduce((a, b) => a + b, 0) / xs.length : 0;
        const yCenter = ys.length > 0 ? ys.reduce((a, b) => a + b, 0) / ys.length : 0;
        lines.push({ lineId: lineId++, text, xCenter, yCenter, page: page.pageNumber || 0 });
        for (const word of words) {
          if (typeof word.confidence === "number") {
            confidenceSum += word.confidence;
            confidenceCount += 1;
          }
        }
      }
    }
  }

  const avgConfidence =
    confidenceCount > 0 ? Number((confidenceSum / confidenceCount).toFixed(3)) : 0;

  if (lines.length === 0) {
    return { text: "", lines: [], avgConfidence, hasTwoColumns: false, columnDivider: null };
  }

  const sortedByY = [...lines].sort((a, b) => {
    if (Math.abs(a.yCenter - b.yCenter) > 12) {
      return a.yCenter - b.yCenter;
    }
    return a.xCenter - b.xCenter;
  });

  const pageWidth = pages[0]?.width || null;
  const xCenters = sortedByY.map((l) => l.xCenter).filter((x) => typeof x === "number");
  const medianX =
    xCenters.length === 0
      ? 0
      : xCenters.sort((a, b) => a - b)[Math.floor(xCenters.length / 2)];
  const leftCount = xCenters.filter((x) => x <= medianX).length;
  const rightCount = xCenters.length - leftCount;
  const hasBalancedColumns =
    leftCount > 0 && rightCount > 0 && Math.min(leftCount, rightCount) / xCenters.length > 0.25;
  const widthThreshold = pageWidth ? pageWidth * 0.15 : 80;
  const hasTwoColumns = hasBalancedColumns && medianX > widthThreshold;

  if (!hasTwoColumns) {
    const text = sortedByY.map((l) => l.text).join("\n");
    return { text, lines: sortedByY, avgConfidence, hasTwoColumns, columnDivider: null };
  }

  const leftLines = sortedByY.filter((l) => l.xCenter <= medianX);
  const rightLines = sortedByY.filter((l) => l.xCenter > medianX);
  leftLines.sort((a, b) => (a.yCenter === b.yCenter ? a.xCenter - b.xCenter : a.yCenter - b.yCenter));
  rightLines.sort((a, b) =>
    a.yCenter === b.yCenter ? a.xCenter - b.xCenter : a.yCenter - b.yCenter,
  );
  const text = [...leftLines.map((l) => l.text), "", ...rightLines.map((l) => l.text)].join("\n");
  return { text, lines: [...leftLines, ...rightLines], avgConfidence, hasTwoColumns, columnDivider: medianX };
}

function gateByEvidence(parsed, ocrText) {
  const issues = Array.isArray(parsed.issues) ? [...parsed.issues] : [];
  let needsReview = !!parsed.needsReview;

  const dropIfNoEvidence = (arr, label) => {
    if (!Array.isArray(arr)) return [];
    const kept = [];
    for (const item of arr) {
      const ev = item?.evidence || item?.evidenceSnippet || item?.source || "";
      if (!ev) {
        needsReview = true;
        issues.push("missing evidence");
        continue;
      }
      if (includesEvidence(ocrText, ev)) {
        kept.push(item);
      } else {
        needsReview = true;
        issues.push(`${label} removed because evidence was missing/not found in OCR`);
      }
    }
    return kept;
  };

  if (parsed?.titleEvidence) {
    if (!titleMatches(parsed.titleEvidence, ocrText)) {
      needsReview = true;
      issues.push("title evidence not found in OCR");
    }
  } else {
    if (parsed?.title && !titleMatches(parsed.title, ocrText)) {
      needsReview = true;
      issues.push("title not confidently found in OCR");
    }
  }

  parsed.ingredients = dropIfNoEvidence(parsed.ingredients, "ingredient");
  parsed.tools = dropIfNoEvidence(parsed.tools, "tool");
  parsed.steps = dropIfNoEvidence(parsed.steps, "step");

  if ((parsed.ingredients?.length || 0) < 3) {
    needsReview = true;
    issues.push("too_few_ingredients");
  }
  if ((parsed.steps?.length || 0) < 3) {
    needsReview = true;
    issues.push("too_few_steps");
  }

  parsed.needsReview = needsReview;
  parsed.issues = issues;

  return parsed;
}

function firstLineNoiseInfo(text) {
  const lines = String(text || "")
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean);
  const sample = lines.slice(0, 2).join(" ").trim();
  if (!sample) return { ratio: 0, line: "", flagged: false, threshold: 0.35 };
  const noise = (sample.match(/[^A-Za-zא-ת0-9\s]/g) || []).length;
  const ratio = sample.length > 0 ? noise / sample.length : 0;
  const threshold = 0.35;
  return {
    ratio: Number(ratio.toFixed(3)),
    line: sample,
    flagged: ratio > threshold,
    threshold,
  };
}

function titleCandidatesFromText(text, limit = 3) {
  const lines = String(text || "")
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean);
  const scored = [];
  for (const line of lines) {
    const noise = (line.match(/[^A-Za-zא-ת0-9\s]/g) || []).length;
    const ratio = line.length > 0 ? noise / line.length : 1;
    if (ratio >= 0.35) continue;
    scored.push({ line, ratio });
    if (scored.length >= limit) break;
  }
  scored.sort((a, b) => a.ratio - b.ratio || a.line.length - b.line.length);
  return scored.slice(0, limit).map((s) => s.line);
}

function detectSectionCandidates(ocrLines, hasTwoColumns, columnDivider) {
  const ingHeaders = ["מצרכים", "מרכיבים", "ingredients"];
  const stepHeaders = ["אופן הכנה", "הכנה", "הוראות", "instructions", "method", "directions"];

  const isHeaderMatch = (text, headers) => {
    const lower = String(text || "").toLowerCase();
    return headers.some((h) => lower.includes(h.toLowerCase()));
  };

  const lines = Array.isArray(ocrLines) ? ocrLines : [];
  let stepsHeaderIdx = -1;
  let stepsHeaderColumn = null;
  for (let i = 0; i < lines.length; i++) {
    if (isHeaderMatch(lines[i].text, stepHeaders)) {
      stepsHeaderIdx = i;
      if (hasTwoColumns && typeof columnDivider === "number") {
        stepsHeaderColumn = lines[i].xCenter > columnDivider ? "right" : "left";
      }
      break;
    }
  }

  const ingredientsLines = [];
  const stepsLines = [];

  const useStepsColumn = hasTwoColumns && stepsHeaderColumn;
  const isInStepsColumn = (line) => {
    if (!useStepsColumn) return true;
    return stepsHeaderColumn === "right" ? line.xCenter > columnDivider : line.xCenter <= columnDivider;
  };

  if (stepsHeaderIdx !== -1) {
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (i <= stepsHeaderIdx) {
        if (!useStepsColumn || !isInStepsColumn(line)) {
          ingredientsLines.push({ lineId: line.lineId, text: line.text || "" });
        }
        continue;
      }
      if (!isInStepsColumn(line)) {
        ingredientsLines.push({ lineId: line.lineId, text: line.text || "" });
      } else {
        stepsLines.push({ lineId: line.lineId, text: line.text || "" });
      }
    }
  } else {
    // Fallback: split by simple cues (numbers/bullets) for steps
    for (const line of lines) {
      const txt = line.text || "";
      if (/^\s*(\d+[\).\:-]|[-•*+])\s+/.test(txt)) {
        stepsLines.push({ lineId: line.lineId, text: txt });
      } else {
        ingredientsLines.push({ lineId: line.lineId, text: txt });
      }
    }
  }

  return { ingredientsLines, stepsLines, stepsHeaderFound: stepsHeaderIdx !== -1, stepsHeaderIdx };
}

function buildStepDrafts(lines) {
  const steps = [];
  const bulletRe = /^\s*(\d+[\).\:-]|[-•*+])\s+/;
  const splitRe = /\b(then|after that|while|until)\b|[,;]\s*then\b/i;
  const actionVerbRe = /\b(mix|stir|bake|cook|add|combine|pour|heat|serve|chop|slice|whisk|fold|knead|shape|rest|proof|spread|pour|boil|simmer|fry|preheat)\b/i;

  for (const raw of lines) {
    const lineId = raw.lineId;
    const text = String(raw.text || "").trim();
    if (!text) continue;
    const base = text.replace(bulletRe, "").trim();
    const segments = base.split(splitRe).map((s) => s && s.trim()).filter(Boolean);
    for (const seg of segments) {
      if (!actionVerbRe.test(seg)) {
        // treat as continuation if previous exists
        if (steps.length > 0) {
          const last = steps.pop();
          steps.push({
            ...last,
            text: `${last.text} ${seg}`.trim(),
            evidenceLineIds: Array.from(new Set([...(last.evidenceLineIds || []), lineId])),
          });
        } else {
          steps.push({ text: seg, evidenceLineIds: [lineId] });
        }
      } else {
        steps.push({ text: seg, evidenceLineIds: [lineId] });
      }
    }
  }

  // Extract explicit durations from evidence
  const durationRe =
    /(\d+)\s*(hours?|hrs?|h\b)|(\d+)\s*(minutes?|mins?|min\b)|(\d+)\s*(seconds?|secs?|sec\b)/i;
  return steps
    .map((s) => {
      const match = s.text.match(durationRe);
      let durationSeconds = null;
      if (match) {
        if (match[1]) durationSeconds = parseInt(match[1], 10) * 3600;
        else if (match[3]) durationSeconds = parseInt(match[3], 10) * 60;
        else if (match[5]) durationSeconds = parseInt(match[5], 10);
      }
      return {
        text: s.text,
        durationSeconds: durationSeconds ?? null,
        evidenceLineIds: s.evidenceLineIds || [],
      };
    })
    .filter((s) => s.text.length > 0);
}

async function extractTextWithVision(
  bucketName,
  filePath,
  contentType,
  isPdf = false,
  recipeId = "",
  ownerId = "",
) {
  const gcsUri = `gs://${bucketName}/${filePath}`;
  console.log("[extractTextWithVision] gcsUri =", gcsUri, "contentType =", contentType);

  try {
    const treatAsPdf = isPdf || String(contentType).toLowerCase().includes("pdf");
    if (treatAsPdf) {
      console.log("[PDF_OCR_PATH] using AsyncBatchAnnotateFiles");
      const safeRecipeId = recipeId ? String(recipeId).replace(/[^a-zA-Z0-9_-]/g, "_") : "";
      const safeOwnerId = ownerId ? String(ownerId).replace(/[^a-zA-Z0-9_-]/g, "_") : "";
      const outputPrefix =
        safeOwnerId && safeRecipeId
          ? `ocr_outputs/${safeOwnerId}/${safeRecipeId}/`
          : safeRecipeId
            ? `ocr_outputs/${safeRecipeId}/`
            : `ocr_outputs/${filePath.replace(/[^a-zA-Z0-9_-]/g, "_")}_${Date.now()}/`;
      const outputUri = `gs://${bucketName}/${outputPrefix}`;
      console.log(`[PDF_OCR] recipeId=${recipeId} input=${gcsUri} outputPrefix=${outputUri}`);
      const request = {
        inputConfig: {
          gcsSource: { uri: gcsUri },
          mimeType: "application/pdf",
        },
        features: [{ type: "DOCUMENT_TEXT_DETECTION" }],
        imageContext: { languageHints: LANGUAGE_HINTS },
        outputConfig: { gcsDestination: { uri: outputUri }, batchSize: 10 },
      };
      const [operation] = await visionClient.asyncBatchAnnotateFiles({ requests: [request] });
      const [operationResult] = await operation.promise();

      const bucket = admin.storage().bucket(bucketName);
      const [files] = await bucket.getFiles({ prefix: outputPrefix });
      files.sort((a, b) => a.name.localeCompare(b.name));
      let text = "";
      let lines = [];
      let avgConfidence = 0;
      let pages = 0;
      let extractedChars = 0;
      let responsesWithText = 0;
      let responsesWithFullText = 0;
      const errors = [];
      console.log(
        `[PDF_OCR_OUTPUT] recipeId=${recipeId} filesCount=${files.length} firstFiles=${files
          .slice(0, 3)
          .map((f) => f.name)
          .join(",")}`,
      );

      for (const file of files) {
        if (!file.name.endsWith(".json")) continue;
        const [contents] = await file.download();
        const json = JSON.parse(contents.toString());
        const responses = json.responses || [];
        console.log(
          `[PDF_OCR] recipeId=${recipeId} file=${file.name} bytes=${contents.length} responsesCount=${responses.length}`,
        );
        pages += responses.length;
        for (const response of responses) {
          if (response.error) {
            errors.push(response.error);
          }
          if (response.fullTextAnnotation?.text) {
            responsesWithFullText += 1;
          }
          const parsed = reconstructTextFromAnnotation(response.fullTextAnnotation);
          if (parsed.text) {
            text = text ? `${text}\n${parsed.text}` : parsed.text;
            extractedChars += parsed.text.length;
            responsesWithText += 1;
          } else if (response.textAnnotations?.[0]?.description) {
            const desc = response.textAnnotations[0].description;
            text = text ? `${text}\n${desc}` : desc;
            extractedChars += desc.length;
            responsesWithText += 1;
          }
          if (Array.isArray(parsed.lines) && parsed.lines.length > 0) {
            lines = lines.concat(parsed.lines);
          }
          if (parsed.avgConfidence) {
            avgConfidence = Math.max(avgConfidence, parsed.avgConfidence);
          }
        }
      }

      console.log(
        `[PDF_OCR_TEXT] recipeId=${recipeId} extractedChars=${extractedChars} previewFirst200=${text.slice(
          0,
          200,
        )} hasAnyFullText=${responsesWithFullText > 0} errorsCount=${errors.length}`,
      );
      if (files.length > 0 && extractedChars === 0) {
        console.log(
          `[PDF_OCR] empty_text responsesWithFullText=${responsesWithFullText} errorsCount=${errors.length}`,
        );
        console.log(
          `[PDF_OCR_OP] recipeId=${recipeId} operationResult=${JSON.stringify(operationResult)}`,
        );
      }
      return {
        text,
        lines,
        avgConfidence,
        width: null,
        height: null,
        hasTwoColumns: false,
        columnDivider: null,
        ocrDebug: {
          route: "pdf_async",
          outputFilesCount: files.length,
          extractedChars,
          previewFirst200: text.slice(0, 200),
          responsesWithText,
          responsesWithFullText,
          errors,
          errorsCount: errors.length,
        },
        pagesCount: pages,
        ocrGcsOutputPrefix: outputUri,
      };
    }

    console.log("[IMG_OCR_PATH] using BatchAnnotateImages");
    const [result] = await visionClient.documentTextDetection({
      image: { source: { imageUri: gcsUri } },
      imageContext: { languageHints: LANGUAGE_HINTS },
    });
    const { text, lines, avgConfidence, hasTwoColumns, columnDivider } =
      reconstructTextFromAnnotation(result.fullTextAnnotation);
    console.log("[extractTextWithVision] docText length =", text.length, "twoCols=", hasTwoColumns);
    return {
      text,
      lines,
      avgConfidence,
      hasTwoColumns,
      columnDivider,
      width: null,
      height: null,
      ocrDebug: {
        route: "image",
        extractedChars: text.length,
        previewFirst200: text.slice(0, 200),
      },
      pagesCount: 1,
      ocrGcsOutputPrefix: null,
    };
  } catch (err) {
    console.error("[extractTextWithVision] Vision error for", gcsUri, err);
    return {
      text: "",
      lines: [],
      avgConfidence: 0,
      width: null,
      height: null,
      hasTwoColumns: false,
      ocrDebug: {
        route: isPdf ? "pdf_async" : "image",
        extractedChars: 0,
        previewFirst200: "",
        errors: [String(err)],
      },
      pagesCount: 0,
      ocrGcsOutputPrefix: null,
    };
  }
}

function validateParsedRecipe(parsed) {
  const issues = [];
  if (!parsed || typeof parsed !== "object") {
    issues.push("parsed_not_object");
    return { valid: false, issues };
  }
  if (!Array.isArray(parsed.ingredients)) issues.push("ingredients_not_array");
  if (!Array.isArray(parsed.tools)) issues.push("tools_not_array");
  if (!Array.isArray(parsed.steps)) issues.push("steps_not_array");
  if (typeof parsed.needsReview !== "boolean") issues.push("needsReview_missing");
  if (!Array.isArray(parsed.issues)) issues.push("issues_not_array");
  return { valid: issues.length === 0, issues };
}

function logImportStage(recipeId, stage, data = {}) {
  const payload = {
    recipeId,
    stage,
    ocrLen: data.ocrLen ?? null,
    llmInputLen: data.llmInputLen ?? null,
    afterIng: data.afterIng ?? null,
    afterSteps: data.afterSteps ?? null,
    afterTools: data.afterTools ?? null,
    needsReview: data.needsReview ?? null,
    issuesCount: data.issuesCount ?? null,
  };
  console.log(JSON.stringify(payload));
}

const recipeExtractionFunction = {
  name: "save_recipe",
  description:
    "Extract structured recipe directly from OCR text. Never invent or infer any item that is not explicitly present.",
  parameters: {
    type: "object",
    properties: {
      title: { type: "string", description: "Recipe title exactly as written; empty if missing." },
      titleEvidence: {
        type: "string",
        description: "Exact substring from OCR that supports the title; omit if not present.",
      },
      preCookingNotes: {
        type: "string",
        description: "Any notes before cooking; empty if missing.",
      },
      ingredients: {
        type: "array",
        items: {
          type: "object",
          properties: {
            name: { type: "string" },
            quantity: { type: "string" },
            unit: { type: "string" },
            evidence: {
              type: "string",
              description: "Exact substring from OCR (10-80 chars) that supports this ingredient.",
            },
          },
          required: ["name", "quantity", "unit", "evidence"],
        },
      },
      tools: {
        type: "array",
        items: {
          type: "object",
          properties: {
            name: { type: "string" },
            evidence: {
              type: "string",
              description: "Exact substring from OCR (10-80 chars) that supports this tool.",
            },
          },
          required: ["name", "evidence"],
        },
      },
      steps: {
        type: "array",
        items: {
          type: "object",
          properties: {
            text: { type: "string" },
            durationMinutes: { type: ["number", "null"] },
            evidence: {
              type: "string",
              description: "Exact substring from OCR (10-80 chars) that supports this step text.",
            },
          },
          required: ["text", "durationMinutes", "evidence"],
        },
      },
      needsReview: {
        type: "boolean",
        description:
          "Set true if any field is missing/uncertain/garbled or if you omitted items due to uncertainty.",
      },
      issues: {
        type: "array",
        items: { type: "string" },
        description: "List of issues explaining omissions or uncertainty.",
      },
    },
    required: ["title", "preCookingNotes", "ingredients", "tools", "steps", "needsReview", "issues"],
  },
};

async function parseRecipeWithLLM(text) {
  console.log("[LLM] input length:", text.length);
  if (!openai) {
    throw new Error("Missing OPENAI_API_KEY (required for recipe parsing)");
  }

  const baseMessages = [
    {
      role: "system",
      content:
        "You extract structured recipes from OCR. Only extract information explicitly present in the OCR text. Do NOT infer, normalize, translate, or add missing items. For EVERY ingredient/tool/step, include evidence as a verbatim substring from OCR (10-80 chars) and ensure it appears exactly in the OCR. If you cannot find exact evidence, OMIT the item and add an issue. If title is not explicitly present, set title=null. Always respond via the function call schema.",
    },
    {
      role: "user",
      content: `OCR TEXT:\n"""${text}"""`,
    },
  ];

  let lastError = null;
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const completion = await openai.createChatCompletion({
        model: LLM_MODEL,
        temperature: 0,
        messages:
          attempt === 0
            ? baseMessages
            : [
                ...baseMessages,
                {
                  role: "system",
                  content: "Previous response was invalid JSON. Return only valid JSON via the function call.",
                },
              ],
        functions: [recipeExtractionFunction],
        function_call: { name: recipeExtractionFunction.name },
      });

      const message = completion?.data?.choices?.[0]?.message;
      const rawArgs = message?.function_call?.arguments;
      if (!rawArgs) {
        throw new Error("LLM returned no function_call arguments");
      }
      const parsed = JSON.parse(rawArgs);
      const validation = validateParsedRecipe(parsed);
      if (!validation.valid) {
        lastError = new Error(`LLM schema issues: ${validation.issues.join(",")}`);
        continue;
      }
      const parsedRecipe = parsed;
      console.log("[PARSE] before", {
        ing: parsedRecipe.ingredients?.length || 0,
        steps: parsedRecipe.steps?.length || 0,
        tools: parsedRecipe.tools?.length || 0,
      });
      const debugBefore = {
        beforeIng: parsedRecipe.ingredients?.length || 0,
        beforeSteps: parsedRecipe.steps?.length || 0,
        beforeTools: parsedRecipe.tools?.length || 0,
      };
      console.log("[EVIDENCE_GATE] before", {
        ing: parsedRecipe.ingredients?.length || 0,
        steps: parsedRecipe.steps?.length || 0,
        tools: parsedRecipe.tools?.length || 0,
        title: parsedRecipe.title,
      });
      const final = gateByEvidence(parsedRecipe, text);
      console.log("[PARSE] after", {
        ing: final.ingredients?.length || 0,
        steps: final.steps?.length || 0,
        tools: final.tools?.length || 0,
        issues: final.issues || [],
      });
      console.log("[EVIDENCE_GATE] after", {
        ing: final.ingredients?.length || 0,
        steps: final.steps?.length || 0,
        tools: final.tools?.length || 0,
        title: final.title,
        needsReview: final.needsReview,
        issuesCount: final.issues?.length || 0,
      });
      const debugAfter = {
        afterIng: final.ingredients?.length || 0,
        afterSteps: final.steps?.length || 0,
        afterTools: final.tools?.length || 0,
        issuesCount: final.issues?.length || 0,
      };
      return {
        parsed: final,
        rawResponse: rawArgs,
        debug: { ...debugBefore, ...debugAfter },
      };
    } catch (err) {
      lastError = err;
      console.error("[LLM] attempt failed", attempt + 1, err);
    }
  }

  throw lastError || new Error("LLM parsing failed");
}

function buildCategoryTitleToKeyMap() {
  // Keep this list in sync with the Flutter app's kRecipeCategoryOptions.
  const categories = [
    { key: "breakfast", title: "Breakfast" },
    { key: "brunch", title: "Brunch" },
    { key: "quick-weeknight-dinners", title: "Quick Weeknight Dinners" },
    { key: "friday-lunch", title: "Friday Lunch" },
    { key: "comfort-food", title: "Comfort Food" },
    { key: "baking-basics", title: "Baking Basics" },
    { key: "bread-and-dough", title: "Bread & Dough" },
    { key: "pastries", title: "Pastries" },
    { key: "cakes-and-desserts", title: "Cakes & Desserts" },
    { key: "cookies-and-small-sweets", title: "Cookies & Small Sweets" },
    { key: "chocolate-lovers", title: "Chocolate Lovers" },
    { key: "healthy-and-light", title: "Healthy & Light" },
    { key: "high-protein", title: "High Protein" },
    { key: "vegetarian", title: "Vegetarian" },
    { key: "vegan", title: "Vegan" },
    { key: "gluten-free", title: "Gluten Free" },
    { key: "one-pot-meals", title: "One Pot Meals" },
    { key: "soups-and-stews", title: "Soups & Stews" },
    { key: "salads", title: "Salads" },
    { key: "pasta-and-risotto", title: "Pasta & Risotto" },
    { key: "rice-and-grains", title: "Rice & Grains" },
    { key: "middle-eastern", title: "Middle Eastern" },
    { key: "italian-classics", title: "Italian Classics" },
    { key: "asian-inspired", title: "Asian Inspired" },
    { key: "street-food", title: "Street Food" },
    { key: "family-favorites", title: "Family Favorites" },
    { key: "hosting-and-holidays", title: "Hosting & Holidays" },
    { key: "meal-prep", title: "Meal Prep" },
    { key: "kids-friendly", title: "Kids Friendly" },
    { key: "late-night-cravings", title: "Late Night Cravings" },
  ];
  const map = new Map();
  for (const c of categories) {
    map.set(String(c.title).toLowerCase(), c.key);
  }
  return map;
}

function slugifyKey(input) {
  const trimmed = String(input || "").trim();
  if (!trimmed) return "";
  return trimmed
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/(^-|-$)/g, "");
}

function normalizeCategoriesFromRecipeData(data, titleToKey) {
  const rawCandidates = [];
  const sources = ["categories", "category", "tags", "categoryKeys"];
  for (const field of sources) {
    const value = data[field];
    if (!value) continue;
    if (typeof value === "string") {
      rawCandidates.push(value);
    } else if (Array.isArray(value)) {
      for (const item of value) {
        if (typeof item === "string") rawCandidates.push(item);
      }
    }
  }

  const normalized = [];
  const seen = new Set();
  for (const raw of rawCandidates) {
    const t = String(raw).trim();
    if (!t) continue;
    const byTitle = titleToKey.get(t.toLowerCase());
    const key = byTitle || slugifyKey(t);
    if (!key) continue;
    if (seen.has(key)) continue;
    seen.add(key);
    normalized.push(key);
  }

  normalized.sort(); // deterministic
  return normalized.slice(0, 5);
}

function normalizeIsPublic(value) {
  if (typeof value === "boolean") return { value, changed: false };
  if (typeof value === "string") {
    const lower = value.trim().toLowerCase();
    if (lower === "true") return { value: true, changed: true };
    if (lower === "false") return { value: false, changed: true };
  }
  return { value, changed: false };
}

exports.migrateRecipeCategories = functions.https.onRequest(async (req, res) => {
  const token =
    process.env.MIGRATION_TOKEN || functions.config().migration?.token || "";
  const authHeader = req.get("authorization") || "";
  const provided = authHeader.startsWith("Bearer ")
    ? authHeader.slice("Bearer ".length).trim()
    : "";
  if (!token || provided !== token) {
    res.status(401).json({ ok: false, error: "Unauthorized" });
    return;
  }

  const dryRun = String(req.query.dryRun || "false") === "true";
  const pageSize = Math.min(
    parseInt(req.query.pageSize || "400", 10) || 400,
    450,
  );
  const maxPages = parseInt(req.query.maxPages || "0", 10) || 0; // 0 = unlimited
  const logExamples = Math.min(
    parseInt(req.query.examples || "10", 10) || 10,
    25,
  );

  const titleToKey = buildCategoryTitleToKeyMap();
  const recipesRef = db.collection("recipes");

  let scanned = 0;
  let updated = 0;
  let skipped = 0;
  const examples = [];

  let lastDoc = null;
  let page = 0;
  while (true) {
    page += 1;
    if (maxPages > 0 && page > maxPages) break;

    let query = recipesRef
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(pageSize);
    if (lastDoc) query = query.startAfter(lastDoc);
    const snap = await query.get();
    if (snap.empty) break;
    lastDoc = snap.docs[snap.docs.length - 1];

    let batch = db.batch();
    let batchOps = 0;

    for (const doc of snap.docs) {
      scanned += 1;
      const data = doc.data() || {};
      const normalizedCategories = normalizeCategoriesFromRecipeData(
        data,
        titleToKey,
      );

      const isPublicNorm = normalizeIsPublic(data.isPublic);

      const existingCategories = Array.isArray(data.categories)
        ? data.categories.filter((x) => typeof x === "string")
        : [];
      const existingNorm = existingCategories
        .map(slugifyKey)
        .filter(Boolean)
        .sort()
        .slice(0, 5);

      const categoriesDifferent =
        existingNorm.length !== normalizedCategories.length ||
        existingNorm.some((v, i) => v !== normalizedCategories[i]);

      const shouldUpdateIsPublic = isPublicNorm.changed;
      const needsCategoriesField = !Array.isArray(data.categories);

      if (!categoriesDifferent && !shouldUpdateIsPublic && !needsCategoriesField) {
        skipped += 1;
        continue;
      }

      const patch = {
        categories: normalizedCategories,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      if (shouldUpdateIsPublic) {
        patch.isPublic = isPublicNorm.value;
      }

      if (!dryRun) {
        batch.set(doc.ref, patch, { merge: true });
        batchOps += 1;
        if (batchOps >= 450) {
          await batch.commit();
          batch = db.batch();
          batchOps = 0;
        }
      }

      updated += 1;
      if (examples.length < logExamples) {
        examples.push({
          id: doc.id,
          before: {
            isPublic: data.isPublic,
            categories: data.categories,
            category: data.category,
            tags: data.tags,
            categoryKeys: data.categoryKeys,
          },
          after: patch,
        });
      }
    }

    if (!dryRun && batchOps > 0) {
      await batch.commit();
    }

    console.log(
      `[MIGRATE_RECIPES] page=${page} scanned=${scanned} updated=${updated} skipped=${skipped} dryRun=${dryRun}`,
    );
  }

  res.json({
    ok: true,
    dryRun,
    scanned,
    updated,
    skipped,
    examples,
  });
});

exports.auditRecipeCategories = functions.https.onRequest(async (req, res) => {
  const token =
    process.env.MIGRATION_TOKEN || functions.config().migration?.token || "";
  const authHeader = req.get("authorization") || "";
  const provided = authHeader.startsWith("Bearer ")
    ? authHeader.slice("Bearer ".length).trim()
    : "";
  if (!token || provided !== token) {
    res.status(401).json({ ok: false, error: "Unauthorized" });
    return;
  }

  const key = String(req.query.key || "breakfast").trim();
  const title = String(req.query.title || "Breakfast").trim();

  const recipesRef = db.collection("recipes");

  async function runQuery(label, query) {
    const snap = await query.limit(5).get();
    return {
      label,
      count: snap.size,
      ids: snap.docs.map((d) => d.id),
      docs: snap.docs.map((d) => {
        const data = d.data() || {};
        return {
          id: d.id,
          isPublic: data.isPublic,
          isPublicType: typeof data.isPublic,
          categories: data.categories,
          categoriesType: Array.isArray(data.categories) ? "array" : typeof data.categories,
        };
      }),
    };
  }

  const qKey = await runQuery(
    "A_categories_contains_key",
    recipesRef.where("categories", "array-contains", key),
  );
  const qTitle = await runQuery(
    "B_categories_contains_title",
    recipesRef.where("categories", "array-contains", title),
  );

  res.json({
    ok: true,
    key,
    title,
    A: qKey,
    B: qTitle,
  });
});

function normalizeCategoriesFromRaw(raw, titleToKey) {
  const values = [];
  if (Array.isArray(raw)) {
    for (const item of raw) {
      if (typeof item === "string") values.push(item);
      else if (item && typeof item === "object") {
        const key = item.key || item.id;
        const title = item.title || item.name;
        if (typeof key === "string" && key.trim()) values.push(key);
        else if (typeof title === "string" && title.trim()) values.push(title);
      }
    }
  } else if (typeof raw === "string") {
    values.push(raw);
  }

  const seen = new Set();
  const out = [];
  for (const v of values) {
    const t = String(v || "").trim();
    if (!t) continue;
    const byTitle = titleToKey.get(t.toLowerCase());
    const key = byTitle || slugifyKey(t);
    if (!key || seen.has(key)) continue;
    seen.add(key);
    out.push(key);
    if (out.length >= 5) break;
  }
  return out;
}

// Backfill recipe categories from cookbook categories.
// Useful when old recipes never wrote categories, but cookbooks already have them.
exports.backfillRecipeCategoriesFromCookbooks = functions.https.onRequest(
  async (req, res) => {
    const token =
      process.env.MIGRATION_TOKEN || functions.config().migration?.token || "";
    const authHeader = req.get("authorization") || "";
    const provided = authHeader.startsWith("Bearer ")
      ? authHeader.slice("Bearer ".length).trim()
      : "";
    if (!token || provided !== token) {
      res.status(401).json({ ok: false, error: "Unauthorized" });
      return;
    }

    const dryRun = String(req.query.dryRun || "false") === "true";
    const pageSize = Math.min(
      parseInt(req.query.pageSize || "200", 10) || 200,
      300,
    );
    const maxPages = parseInt(req.query.maxPages || "0", 10) || 0; // 0 = unlimited
    const onlyIfMissing = String(req.query.onlyIfMissing || "true") !== "false";

    const titleToKey = buildCategoryTitleToKeyMap();
    const cookbooksRef = db.collection("cookbooks");
    const recipesRef = db.collection("recipes");

    let scannedCookbooks = 0;
    let scannedEntries = 0;
    let updatedRecipes = 0;
    let skippedRecipes = 0;
    const examples = [];

    let lastDoc = null;
    let page = 0;
    while (true) {
      page += 1;
      if (maxPages > 0 && page > maxPages) break;

      let query = cookbooksRef
        .orderBy(admin.firestore.FieldPath.documentId())
        .limit(pageSize);
      if (lastDoc) query = query.startAfter(lastDoc);
      const snap = await query.get();
      if (snap.empty) break;
      lastDoc = snap.docs[snap.docs.length - 1];

      for (const cookbookDoc of snap.docs) {
        scannedCookbooks += 1;
        const data = cookbookDoc.data() || {};
        const cookbookCategories = normalizeCategoriesFromRaw(
          data.categories ?? data.category,
          titleToKey,
        );
        if (cookbookCategories.length === 0) continue;

        // Entries are stored as a subcollection with doc id == recipeId.
        const entriesSnap = await cookbookDoc.ref.collection("entries").get();
        if (entriesSnap.empty) continue;

        for (const entry of entriesSnap.docs) {
          const recipeId =
            entry.id || (entry.data() || {}).recipeId || "";
          if (!recipeId) continue;
          scannedEntries += 1;

          const recipeRef = recipesRef.doc(recipeId);
          const recipeSnap = await recipeRef.get();
          if (!recipeSnap.exists) {
            skippedRecipes += 1;
            continue;
          }
          const recipeData = recipeSnap.data() || {};
          const existingRaw = recipeData.categories;
          const existing = Array.isArray(existingRaw)
            ? existingRaw.filter((x) => typeof x === "string")
            : [];

          const existingKeys = existing
            .map((x) => slugifyKey(String(x)))
            .filter(Boolean);

          if (onlyIfMissing && existingKeys.length > 0) {
            skippedRecipes += 1;
            continue;
          }

          const merged = [];
          const seen = new Set();
          for (const c of [...existingKeys, ...cookbookCategories]) {
            if (!c || seen.has(c)) continue;
            seen.add(c);
            merged.push(c);
            if (merged.length >= 5) break;
          }

          // No change needed.
          const same =
            merged.length === existingKeys.length &&
            merged.every((v, i) => v === existingKeys[i]);
          if (same) {
            skippedRecipes += 1;
            continue;
          }

          const patch = {
            categories: merged,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };

          if (!dryRun) {
            await recipeRef.set(patch, { merge: true });
          }

          updatedRecipes += 1;
          if (examples.length < 20) {
            examples.push({
              cookbookId: cookbookDoc.id,
              recipeId,
              before: existingRaw,
              after: merged,
            });
          }
        }
      }

      console.log(
        `[BACKFILL_FROM_COOKBOOKS] page=${page} scannedCookbooks=${scannedCookbooks} scannedEntries=${scannedEntries} updatedRecipes=${updatedRecipes} skippedRecipes=${skippedRecipes} dryRun=${dryRun} onlyIfMissing=${onlyIfMissing}`,
      );
    }

    res.json({
      ok: true,
      dryRun,
      onlyIfMissing,
      scannedCookbooks,
      scannedEntries,
      updatedRecipes,
      skippedRecipes,
      examples,
    });
  },
);

exports.onRecipeDocUploaded = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name || "";
  const bucketName = object.bucket;
  const contentType = object.contentType || "";
  const sizeBytes = object.size || 0;
  const md5Hash = object.md5Hash || "";
  const metadataContentType = object.metadata?.contentType || "";
  const lowerPath = filePath.toLowerCase();
  const sourceExt = lowerPath.includes(".") ? lowerPath.split(".").pop() || "" : "";
  const gcsUri = `gs://${bucketName}/${filePath}`;
  const isPdf =
    String(contentType).toLowerCase().includes("pdf") ||
    lowerPath.endsWith(".pdf") ||
    String(metadataContentType).toLowerCase().includes("pdf");
  let currentStage = "uploaded";

  console.log("[onRecipeDocUploaded] START", filePath, bucketName, contentType);
  console.log(
    `[IMPORT_START] recipeId=unknown path=${filePath} bucket=${bucketName} contentType=${contentType} size=${sizeBytes} md5=${md5Hash}`,
  );
  console.log(
    `[PDF_OCR_FIX] build=${IMPORT_FN_BUILD} ext=${sourceExt} contentType=${contentType} gcsUri=${gcsUri}`,
  );
  console.log(`[IMPORT_FN_VERSION] ${IMPORT_FN_VERSION} recipeId=unknown`);
  console.log(
    `[OCR_ROUTE] recipeId=unknown route=${isPdf ? "pdf_async" : "image"} contentType=${contentType} ext=${sourceExt}`,
  );
  console.log("[OCR_DETECT] contentType=", contentType, "filePath=", filePath, "isPdf=", isPdf);

  if (!filePath.startsWith("recipe_docs/")) {
    console.log("[onRecipeDocUploaded] ignoring", filePath);
    return;
  }

  const parts = filePath.split("/");
  if (parts.length < 3) {
    console.log("[onRecipeDocUploaded] invalid path", filePath);
    return;
  }

  const recipeId = parts[2];
  const ownerId = parts[1] || "";
  console.log("[onRecipeDocUploaded] recipeId =", recipeId);
  console.log(
    `[IMPORT_START] recipeId=${recipeId} path=${filePath} bucket=${bucketName} contentType=${contentType} size=${sizeBytes} md5=${md5Hash}`,
  );
  console.log(
    `[PDF_OCR_FIX] build=${IMPORT_FN_BUILD} ext=${sourceExt} contentType=${contentType} gcsUri=${gcsUri}`,
  );
  console.log(`[IMPORT_FN_VERSION] ${IMPORT_FN_VERSION} recipeId=${recipeId}`);
  console.log(
    `[OCR_ROUTE] recipeId=${recipeId} route=${isPdf ? "pdf_async" : "image"} contentType=${contentType} ext=${sourceExt}`,
  );

  const recipeRef = db.collection("recipes").doc(recipeId);
  console.log("[onRecipeDocUploaded] target doc path =", recipeRef.path);

  const logWrite = (label, payload) => {
    console.log(
      `[onRecipeDocUploaded] writing to path=${recipeRef.path} recipeId=${recipeId} label=${label} keys=${Object.keys(payload || {})}`,
    );
  };
  const stageWrite = (stage, payload) => {
    console.log(
      `[STAGE_WRITE] recipeId=${recipeId} stage=${stage} fieldsWritten=${Object.keys(payload || {}).join(",")}`,
    );
  };

  const startPayload = {
    importStatus: "uploading",
    importStage: "uploading",
    ocrStatus: "uploading",
    status: "uploading",
    progress: 10,
    debugStage: "ocr_start",
    needsReview: false,
    issues: [],
    errorMessage: admin.firestore.FieldValue.delete(),
    ...(DEBUG_IMPORT
      ? {
          importDebug: {
            stage: "uploaded",
            timestamps: {
              uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
          },
        }
      : {}),
    stageTimestamps: {
      uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
  };
  logWrite("start_uploading", startPayload);
  stageWrite("start", startPayload);
  await recipeRef.set(startPayload, { merge: true });
  logImportStage(recipeId, "uploaded", {});

  try {
    const {
      text: visionText,
      avgConfidence,
      lines,
      hasTwoColumns,
      columnDivider,
      width,
      height,
      ocrDebug,
      pagesCount,
      ocrGcsOutputPrefix,
    } = await extractTextWithVision(bucketName, filePath, contentType, isPdf, recipeId, ownerId);
    const ocrText = sanitizeText(visionText || "");
    const extractedChars = ocrDebug?.extractedChars ?? ocrText.length;
    const firstLineNoise = firstLineNoiseInfo(ocrText);
    const ocrMethod = isPdf ? "pdf_async" : "vision_image";
    const ocrSavePayload = {
      ocrRawText: ocrText,
      ocrStatus: "done",
      ocrMeta: {
        charCount: ocrText.length,
        previewFirst200: ocrText.slice(0, 200),
        contentType,
        ext: sourceExt,
        method: ocrMethod,
      },
      ocrLength: ocrText.length,
      ocrPreview: ocrText.slice(0, 400),
      ocrSourceType: isPdf ? "pdf" : "image",
      ocrPagesCount: pagesCount || 0,
      ocrGcsOutputPrefix: ocrGcsOutputPrefix || null,
      ocrDebug: {
        route: ocrDebug?.route || (isPdf ? "pdf_async" : "image"),
        contentType,
        sizeBytes,
        outputFilesCount: ocrDebug?.outputFilesCount ?? null,
        extractedChars,
        previewFirst200: ocrText.slice(0, 200),
        errorsCount: ocrDebug?.errorsCount ?? (ocrDebug?.errors || []).length,
      },
      importDebug: {
        version: IMPORT_FN_VERSION,
        lastStage: "ocr_extracted",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      stageTimestamps: {
        ocrAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    console.log("[OCR_SAVE] recipeId=", recipeId, "len=", (ocrText || "").length);
    console.log("[OCR_SAVE] preview=", JSON.stringify((ocrText || "").slice(0, 200)));
    logWrite("ocr_save", ocrSavePayload);
    stageWrite("ocr", ocrSavePayload);
    await recipeRef.set(ocrSavePayload, { merge: true });
    currentStage = "ocr_saved";
    logImportStage(recipeId, "ocr_saved", { ocrLen: ocrText.length });
    const ocrRawText = ocrText;
    const garbageCharRatio =
      ocrRawText.length === 0
        ? 1
        : (ocrRawText.match(/[^A-Za-z0-9א-תء-ي\s\.\,\-\:\;\(\)\[\]\{\}]/g) || []).length /
          ocrRawText.length;
    const cleanedText = ocrRawText;
    const detectedLangs = detectLanguages(cleanedText);
    const titleCandidates = titleCandidatesFromText(cleanedText);

    console.log("[onRecipeDocUploaded] OCR length =", cleanedText.length);
    console.log("[onRecipeDocUploaded] OCR preview =", cleanedText.slice(0, 200));

    if (!cleanedText.trim() || cleanedText.length < 50) {
      console.warn("[onRecipeDocUploaded] OCR empty/short; needs_review");
      const issueExt = sourceExt || (isPdf ? "pdf" : "image");
      const ocrIssue = isPdf ? "OCR_EMPTY_PDF" : "OCR_EMPTY_IMAGE";
      const payload = {
        importStatus: "needs_review",
        needsReview: true,
        issues: [ocrIssue, "OCR_EMPTY", `OCR returned 0 chars for ${issueExt}`],
        errorMessage: isPdf
          ? "We could not extract text from this PDF. Please try a clearer scan or photo."
          : "We could not extract text from this image. Please try a clearer scan or photo.",
        ocrRawText,
        ocrMeta: {
          charCount: ocrRawText.length,
          contentType,
          ext: sourceExt,
          method: ocrMethod,
        },
        importDebug: {
          version: IMPORT_FN_VERSION,
          lastStage: "ocr_empty",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        stageTimestamps: {
          ocrAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      logWrite("ocr_empty", payload);
      stageWrite("ocr_empty", payload);
      console.log(
        `[PDF_OCR_EMPTY] recipeId=${recipeId} chars=${ocrRawText.length} contentType=${contentType} ext=${sourceExt}`,
      );
      await recipeRef.set(payload, { merge: true });
      return;
    }

    const parsePayload = {
      importStatus: "ocr_done",
      importStage: "ocr_done",
      status: "ocr_done",
      debugStage: "ocr_done",
      ocrStatus: "done",
      progress: 55,
      ocrRawText,
      ocrLines: Array.isArray(lines)
        ? lines.slice(0, 500).map((l) => ({
            lineId: l.lineId,
            text: l.text,
            xCenter: l.xCenter,
            yCenter: l.yCenter,
            page: l.page,
          }))
        : [],
      ocrMeta: {
        engine: "vision_document",
        languageHints: LANGUAGE_HINTS,
        avgConfidence: avgConfidence || 0,
        garbageCharRatio,
        lineCount: lines?.length || 0,
        hasTwoColumns: !!hasTwoColumns,
        columnDivider: columnDivider || null,
        width,
        height,
        languages: detectedLangs,
      },
      titleCandidates,
      needsReview: false,
      issues: [],
      errorMessage: admin.firestore.FieldValue.delete(),
      "importDebug.stage": "ocr_done",
    };
    logWrite("ocr_done", parsePayload);
    stageWrite("ocr_done", parsePayload);
    await recipeRef.set(parsePayload, { merge: true });
    logImportStage(recipeId, "ocr_done", { ocrLen: ocrRawText.length });

    const sections = detectSectionCandidates(lines || [], hasTwoColumns, columnDivider);
    const stepDrafts = buildStepDrafts(sections.stepsLines);
    const needsReviewSteps = stepDrafts.length < 2;
    const stepIssues = needsReviewSteps ? ["Steps could not be reliably extracted"] : [];
    console.log("[STEP_SPLIT]", {
      stepsHeaderFound: sections.stepsHeaderFound,
      stepsStartIdx: sections.stepsHeaderIdx,
      candidateStepsLinesCount: sections.stepsLines.length,
      stepsExtractedCount: stepDrafts.length,
      needsReviewSteps,
    });

    const llmInputText =
      [...sections.ingredientsLines, "---", ...sections.stepsLines].join("\n").trim() ||
      cleanedText;

    currentStage = "llm_started";
    await recipeRef.set(
      {
        "importDebug.lastStage": "llm_started",
        "importDebug.version": IMPORT_FN_VERSION,
        "importDebug.updatedAt": admin.firestore.FieldValue.serverTimestamp(),
        "stageTimestamps.llmAt": admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    if (DEBUG_IMPORT) {
      await recipeRef.set(
        {
          "importDebug.stage": "llm_started",
          "importDebug.timestamps.llmAt": admin.firestore.FieldValue.serverTimestamp(),
          "importDebug.llm.inputChars": llmInputText.length,
          "importDebug.llm.model": LLM_MODEL,
        },
        { merge: true },
      );
      stageWrite("llm", {
        "importDebug.stage": "llm_started",
        "importDebug.timestamps.llmAt": "serverTimestamp",
        "importDebug.llm.inputChars": llmInputText.length,
      });
    }
    logImportStage(recipeId, "llm_started", { ocrLen: ocrRawText.length, llmInputLen: llmInputText.length });

    const llmResult = await parseRecipeWithLLM(llmInputText);
    const parsed = llmResult.parsed;
    const llmRawResponse = llmResult.rawResponse;
    const llmOutputLen = llmRawResponse ? llmRawResponse.length : 0;
    const gateDebug = llmResult.debug || {};
    if (DEBUG_IMPORT) {
      await recipeRef.set(
        {
          "importDebug.stage": "llm_done",
          "importDebug.timestamps.llmDoneAt": admin.firestore.FieldValue.serverTimestamp(),
          "importDebug.llm.inputChars": llmInputText.length,
          "importDebug.llm.outputChars": llmOutputLen,
          "importDebug.llm.model": LLM_MODEL,
          "importDebug.llm.parseOk": true,
          "importDebug.llm.outputCounts": {
            ingredients: gateDebug.beforeIng ?? 0,
            steps: gateDebug.beforeSteps ?? 0,
            tools: gateDebug.beforeTools ?? 0,
          },
        },
        { merge: true },
      );
      stageWrite("llm_done", {
        "importDebug.stage": "llm_done",
        "importDebug.llm.outputChars": llmOutputLen,
      });
    }
    logImportStage(recipeId, "llm_done", {
      ocrLen: ocrRawText.length,
      llmInputLen: llmInputText.length,
      afterIng: gateDebug.afterIng ?? null,
      afterSteps: gateDebug.afterSteps ?? null,
      afterTools: gateDebug.afterTools ?? null,
      needsReview: parsed.needsReview,
      issuesCount: parsed.issues?.length || 0,
    });

    const hallucinationIssues = [];
    const ingredients = (parsed.ingredients || []).reduce((acc, ing) => {
      const name = (ing && ing.name) || "";
      const evidence = (ing && ing.evidence) || "";
      if (!name) return acc;
      if (!evidence || !appearsInOcr(evidence, cleanedText)) {
        hallucinationIssues.push(`ingredient_not_in_ocr:${name}`);
        return acc;
      }
      acc.push({
        name,
        quantity: ing.quantity || "",
        unit: ing.unit || "",
        evidence,
      });
      return acc;
    }, []);

    const tools = (parsed.tools || []).reduce((acc, tool) => {
      const name = (tool && tool.name) || "";
      const evidence = (tool && tool.evidence) || "";
      if (!name) return acc;
      if (!evidence || !appearsInOcr(evidence, cleanedText)) {
        hallucinationIssues.push(`tool_not_in_ocr:${name}`);
        return acc;
      }
      acc.push({ name, evidence });
      return acc;
    }, []);

    const commonTools = [
      "oven",
      "pan",
      "pot",
      "bowl",
      "knife",
      "spatula",
      "whisk",
      "mixing bowl",
      "microwave",
      "skillet",
      "blender",
    ];
    if (tools.length === 0 && Array.isArray(sections.stepsLines)) {
      for (const line of sections.stepsLines) {
        const text = String(line.text || "").toLowerCase();
        for (const tool of commonTools) {
          if (text.includes(tool)) {
            tools.push({ name: tool, evidence: line.text });
          }
        }
      }
    }

    const steps = (parsed.steps || []).reduce((acc, step, idx) => {
      const text = (step && step.text) || "";
      const evidence = (step && step.evidence) || "";
      if (!text) return acc;
      if (!evidence || !appearsInOcr(evidence, cleanedText)) {
        hallucinationIssues.push(`step_not_in_ocr:${text.slice(0, 40)}`);
        return acc;
      }
      const durationMinutes = step?.durationMinutes;
      acc.push({
        text,
        durationSeconds:
          typeof durationMinutes === "number" && durationMinutes > 0
            ? durationMinutes * 60
            : null,
        order: acc.length,
        evidence,
      });
      return acc;
    }, []);

    // If LLM failed to extract steps, fallback to deterministic drafts
    let stepsFinal = steps;
    if (stepsFinal.length === 0 && stepDrafts.length > 0) {
      stepsFinal = stepDrafts.map((s, idx) => ({
        text: s.text,
        durationSeconds: s.durationSeconds ?? null,
        order: idx,
        evidence: s.evidenceLineIds.join(","),
      }));
    } else if (stepDrafts.length > 0) {
      // Strip durations not present in evidence
      stepsFinal = stepsFinal.map((s) => {
        const hasDuration = typeof s.durationSeconds === "number";
        if (!hasDuration) return s;
        const ev = s.evidence || "";
        const durationRe =
          /(\d+)\s*(hours?|hrs?|h\b)|(\d+)\s*(minutes?|mins?|min\b)|(\d+)\s*(seconds?|secs?|sec\b)/i;
        if (!durationRe.test(ev)) {
          issues.push("duration_removed_no_evidence");
          return { ...s, durationSeconds: null };
        }
        return s;
      });
    }

    const totalCandidates =
      (parsed.ingredients?.length || 0) +
      (parsed.tools?.length || 0) +
      (parsed.steps?.length || 0);
    const supportedCount = ingredients.length + tools.length + stepsFinal.length;
    const coverage =
      totalCandidates === 0 ? 0 : Number((supportedCount / totalCandidates).toFixed(3));

    const lowCoverage = coverage < 0.85;
    const garbageTooHigh = garbageCharRatio > 0.35;
    const firstLineBlocked = firstLineNoise.flagged;
    const hallucinationRate =
      totalCandidates === 0 ? 0 : Number((hallucinationIssues.length / totalCandidates).toFixed(3));
    const titleMissing = !parsed.title || String(parsed.title).trim().length === 0;
    const ingredientsMissing = ingredients.length === 0;
    const stepsMissing = stepsFinal.length === 0;
    const needsReview =
      parsed.needsReview ||
      lowCoverage ||
      garbageTooHigh ||
      hallucinationRate > 0 ||
      firstLineBlocked ||
      titleMissing ||
      ingredientsMissing ||
      stepsMissing ||
      needsReviewSteps;
    const issues = [
      ...(parsed.issues || []),
      ...(lowCoverage ? ["low_coverage"] : []),
      ...(garbageTooHigh ? ["garbage_chars_high"] : []),
      ...(hallucinationIssues.length > 0 ? hallucinationIssues : []),
      ...(firstLineBlocked ? ["first_line_noise"] : []),
      ...(titleMissing ? ["Title is missing. Please rename."] : []),
      ...(ingredientsMissing ? ["missing_ingredients"] : []),
      ...(stepsMissing ? ["missing_steps"] : []),
      ...(needsReviewSteps ? ["Steps could not be reliably extracted"] : []),
      ...(tools.length === 0 ? ["tools_missing"] : []),
    ];
    const beforeTotal =
      (gateDebug.beforeIng || 0) + (gateDebug.beforeSteps || 0) + (gateDebug.beforeTools || 0);
    const afterTotal = ingredients.length + stepsFinal.length + tools.length;
    const gateRemovedAll = beforeTotal > 0 && afterTotal === 0;
    if (gateRemovedAll) {
      issues.push("GATE_DROPPED_ALL");
      issues.push("gate_removed_all_content");
    }
    const hasStageIssue = issues.some((issue) =>
      String(issue || "").match(/^(OCR_EMPTY|GATE_DROPPED_ALL|OVERWRITE_AFTER_PARSE|NEEDS_REVIEW_STAGE_)/),
    );
    if (needsReview && !hasStageIssue) {
      issues.push("NEEDS_REVIEW_STAGE_GATE");
    }
    if (needsReview && (!issues || issues.length === 0)) {
      issues.push("UNKNOWN_IMPORT_FAILURE_NO_ISSUES");
    }
    if (ingredients.length === 0 && stepsFinal.length === 0) {
      needsReview = true;
      issues.push("NO_INGREDIENTS_OR_STEPS_PARSED");
    }
    if (DEBUG_IMPORT) {
      await recipeRef.set(
        {
          "importDebug.gate.issuesAdded": issues,
        },
        { merge: true },
      );
    }

    const existingSnap = await recipeRef.get();
    const existingData = existingSnap.data() || {};
    const existingIngredients = Array.isArray(existingData.ingredients)
      ? existingData.ingredients
      : null;
    const existingSteps = Array.isArray(existingData.steps) ? existingData.steps : null;
    const existingTools = Array.isArray(existingData.tools) ? existingData.tools : null;
    const pickArray = (nextArr, fallbackArr) => {
      if (Array.isArray(nextArr) && nextArr.length > 0) return nextArr;
      if (Array.isArray(fallbackArr)) return fallbackArr;
      return Array.isArray(nextArr) ? nextArr : [];
    };
    const finalIngredients = pickArray(ingredients, existingIngredients);
    const finalSteps = pickArray(stepsFinal, existingSteps);
    const finalTools = pickArray(tools, existingTools);

    const fallbackTitleCandidate =
      (titleCandidates || []).find((cand) => titleMatches(cand, cleanedText)) || null;
    const defaultTitle =
      (detectedLangs || []).includes("he") || (detectedLangs || []).includes("iw")
        ? "מתכון מיובא"
        : "Imported recipe";
    const title =
      firstLineBlocked || titleMissing
        ? fallbackTitleCandidate || defaultTitle
        : parsed.title ?? fallbackTitleCandidate ?? defaultTitle;

    currentStage = "gate_done";
    await recipeRef.set(
      {
        "importDebug.lastStage": "gate_done",
        "importDebug.version": IMPORT_FN_VERSION,
        "importDebug.updatedAt": admin.firestore.FieldValue.serverTimestamp(),
        "stageTimestamps.mappedAt": admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    if (DEBUG_IMPORT) {
      await recipeRef.set(
        {
          "importDebug.stage": "gate_done",
          "importDebug.timestamps.gateAt": admin.firestore.FieldValue.serverTimestamp(),
          "importDebug.gate": {
            before: {
              ing: gateDebug.beforeIng ?? null,
              steps: gateDebug.beforeSteps ?? null,
              tools: gateDebug.beforeTools ?? null,
              titlePresent: !!parsed.title,
            },
            after: {
              ing: gateDebug.afterIng ?? ingredients.length,
              steps: gateDebug.afterSteps ?? stepsFinal.length,
              tools: gateDebug.afterTools ?? tools.length,
              titlePresent: !!title,
            },
            issuesAdded: [],
          },
        },
        { merge: true },
      );
      stageWrite("gate", {
        "importDebug.stage": "gate_done",
        "importDebug.gate": "counts",
      });
    }
    logImportStage(recipeId, "gate_done", {
      ocrLen: ocrRawText.length,
      llmInputLen: llmInputText.length,
      afterIng: ingredients.length,
      afterSteps: stepsFinal.length,
      afterTools: tools.length,
      needsReview,
      issuesCount: issues.length,
    });

    console.log("[onRecipeDocUploaded] MAPPED", {
      ing: ingredients.length,
      steps: steps.length,
      tools: tools.length,
      needsReview,
      issues,
      coverage,
      hallucinationRate,
    });

    currentStage = "firestore_saved";
    const finalPayload = {
      title: title ?? null,
      preCookingNotes: parsed.preCookingNotes || "",
      ingredients: finalIngredients,
      tools: finalTools,
      steps: finalSteps,
      ocrRawText,
      importStatus: needsReview ? "needs_review" : "ready",
      importStage: needsReview ? "needs_review" : "ready",
      ocrStatus: needsReview ? "needs_review" : "done",
      status: needsReview ? "needs_review" : "ready",
      debugStage: needsReview ? "needs_review" : "ready",
      progress: needsReview ? 90 : 100,
      needsReview,
      issues,
      parseMeta: {
        needsReview,
        issues,
        coverage: {
          ingredients: ingredients.length,
          steps: steps.length,
        },
        garbageCharRatio,
        firstLineNoise,
        totalCandidates,
        supportedCount,
        titleMissing,
        ingredientsMissing,
        stepsMissing,
      },
      validationReport: {
        coverage,
        totalCandidates,
        supportedCount,
        hallucinationIssues,
        garbageCharRatio,
        firstLineNoise,
        languages: detectedLangs,
        hasTwoColumns,
        columnDivider,
        titleCandidates,
        hallucinationRate,
        titleMissing,
        ingredientsMissing,
        stepsMissing,
      },
      llmRawResponse,
      errorMessage: admin.firestore.FieldValue.delete(),
      importError: admin.firestore.FieldValue.delete(),
      importCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
      parsedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      importDebug: {
        version: IMPORT_FN_VERSION,
        lastStage: "firestore_saved",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      stageTimestamps: {
        savedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    };
    logWrite("final_write", finalPayload);
    stageWrite("final", finalPayload);
    await recipeRef.set(finalPayload, { merge: true });
    logImportStage(recipeId, "firestore_saved", {
      ocrLen: ocrRawText.length,
      llmInputLen: llmInputText.length,
      afterIng: finalIngredients.length,
      afterSteps: finalSteps.length,
      afterTools: finalTools.length,
      needsReview,
      issuesCount: issues.length,
    });

    const writtenSnap = await recipeRef.get();
    const written = writtenSnap.data() || {};
    const countList = (value) => (Array.isArray(value) ? value.length : 0);
    const writtenCounts = {
      ingredients: countList(written.ingredients),
      steps: countList(written.steps),
      tools: countList(written.tools),
    };
    console.log("[onRecipeDocUploaded] summary after write", {
      importStatus: written.importStatus,
      importStage: written.importStage,
      needsReview,
      title: written.title,
      ingredients: ingredients.length,
      steps: steps.length,
      updatedAt: written.updatedAt,
      titleLen: (written.title || "").length || 0,
      issuesCount: issues.length,
    });
    await new Promise((resolve) => setTimeout(resolve, 5000));
    const laterSnap = await recipeRef.get();
    const later = laterSnap.data() || {};
    const laterCounts = {
      ingredients: countList(later.ingredients),
      steps: countList(later.steps),
      tools: countList(later.tools),
    };
    const writtenTotal = writtenCounts.ingredients + writtenCounts.steps + writtenCounts.tools;
    const laterTotal = laterCounts.ingredients + laterCounts.steps + laterCounts.tools;
    if (writtenTotal > 0 && laterTotal === 0) {
      console.warn(
        "client_overwrite_suspected",
        JSON.stringify({ recipeId, writtenCounts, laterCounts }),
      );
      await recipeRef.set(
        {
          needsReview: true,
          importStatus: "needs_review",
          issues: admin.firestore.FieldValue.arrayUnion("OVERWRITE_AFTER_PARSE"),
          ...(DEBUG_IMPORT
            ? {
                "importDebug.stage": "overwrite_suspected",
                "importDebug.timestamps.overwriteAt": admin.firestore.FieldValue.serverTimestamp(),
              }
            : {}),
        },
        { merge: true },
      );
    }
    console.log("[onRecipeDocUploaded] SUCCESS for recipe", recipeId);
  } catch (err) {
    console.error("[onRecipeDocUploaded] ERROR", err);
    const errorMessage = err instanceof Error ? err.message : String(err);
    const stackSnippet =
      err instanceof Error && err.stack ? err.stack.split("\n").slice(0, 3).join("\n") : "";
    const errorEntry = {
      stage: currentStage,
      message: errorMessage,
      code: err?.code || null,
      stackSnippet,
    };
    const existingSnap = await recipeRef.get();
    const existingData = existingSnap.data() || {};
    const existingTitle = typeof existingData.title === "string" ? existingData.title : null;
    const existingIngredients = Array.isArray(existingData.ingredients)
      ? existingData.ingredients
      : [];
    const existingSteps = Array.isArray(existingData.steps) ? existingData.steps : [];
    const existingTools = Array.isArray(existingData.tools) ? existingData.tools : [];
    const errorPayload = {
      importStatus: "needs_review",
      importStage: "needs_review",
      ocrStatus: "done",
      status: "ready",
      debugStage: "failed",
      needsReview: true,
      issues: [`${currentStage} error: ${errorMessage}`],
      errorMessage,
      importError: errorMessage,
      importCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      title: existingTitle ?? null,
      ingredients: existingIngredients,
      steps: existingSteps,
      tools: existingTools,
      ...(DEBUG_IMPORT
        ? {
            "importDebug.stage": "error",
            "importDebug.timestamps.savedAt": admin.firestore.FieldValue.serverTimestamp(),
            "importDebug.errors": admin.firestore.FieldValue.arrayUnion(errorEntry),
          }
        : {}),
    };
    logWrite("error_failed", errorPayload);
    await recipeRef.set(errorPayload, {merge: true});
    logImportStage(recipeId, "error", {
      needsReview: true,
      issuesCount: errorPayload.issues.length,
    });
  }
});

// Create default private cookbook "Favorite Recipes" for every new user.
exports.createFavoriteCookbook = functions.auth.user().onCreate(async (user) => {
  const uid = user.uid;
  if (!uid) {
    console.error('AUTH_TRIGGER: missing uid on user creation');
    return;
  }
  const favoriteId = 'favorite-recipes';
  const docRef = db.collection('users').doc(uid).collection('playlists').doc(favoriteId);
  const payload = {
    id: favoriteId,
    name: 'Favorite Recipes',
    ownerId: uid,
    isPublic: false,
    isChefPlaylist: false,
    imageUrl: '',
    entries: [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  try {
    await docRef.set(payload, {merge: true});
    console.log(`AUTH_TRIGGER: created default cookbook "${payload.name}" for uid=${uid}`);
  } catch (err) {
    console.error(`AUTH_TRIGGER: failed to create favorite cookbook for uid=${uid}:`, err);
  }
});

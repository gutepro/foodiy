const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { ImageAnnotatorClient } = require("@google-cloud/vision");
const { Configuration, OpenAIApi } = require("openai");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

const sleep = (ms: number) => new Promise((res) => setTimeout(res, ms));
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

const sleep = (ms: number) => new Promise((res) => setTimeout(res, ms));

if (!admin.apps.length) {
  admin.initializeApp();
}

const openaiApiKey = process.env.OPENAI_API_KEY || functions.config().openai?.key;
console.log("[LLM] has key on init:", !!openaiApiKey);

const openai = new OpenAIApi(
  new Configuration({
    apiKey: openaiApiKey,
  })
);

type ParsedIngredient = { name: string; quantity: string; unit: string };
type ParsedTool = { name: string };
type ParsedStep = { text: string; durationMinutes: number };
type ParsedRecipe = {
  title: string;
  preNotes: string;
  ingredients: ParsedIngredient[];
  tools: ParsedTool[];
  steps: ParsedStep[];
};

type ParsedSections = {
  ingredients: string[];
  steps: string[];
  hadHeader: boolean;
};

type OcrLine = {
  id: string;
  text: string;
};

// Vision client
const visionClient = new ImageAnnotatorClient();

async function extractTextWithVision(
  bucketName: string,
  filePath: string,
  contentType: string
): Promise<{ text: string; avgConfidence: number; lines: OcrLine[] }> {
  const gcsUri = `gs://${bucketName}/${filePath}`;
  console.log("[extractTextWithVision] gcsUri =", gcsUri, "contentType =", contentType);

  let fullText = "";
  const detectScripts = (text: string) => {
    const hints: string[] = [];
    if (/[א-ת]/.test(text)) hints.push("he");
    if (/[ء-ي]/.test(text)) hints.push("ar");
    if (/[А-Яа-яЁёЀ-ӿ]/.test(text)) hints.push("ru");
    if (!hints.includes("en")) hints.push("en");
    return hints;
  };

  const run = async (languageHints: string[]) => {
    if (contentType === "application/pdf") {
      const outputPrefix = `vision_output/${filePath.replace(/[^a-zA-Z0-9_-]/g, "_")}_${Date.now()}/`;
      const outputUri = `gs://${bucketName}/${outputPrefix}`;
      const request = {
        inputConfig: {
          gcsSource: { uri: gcsUri },
          mimeType: "application/pdf",
        },
        features: [{ type: "DOCUMENT_TEXT_DETECTION" }],
        imageContext: { languageHints },
        outputConfig: { gcsDestination: { uri: outputUri }, batchSize: 20 },
      };
      const [operation] = await visionClient.asyncBatchAnnotateFiles({
        requests: [request],
      });
      await operation.promise();

      const bucket = admin.storage().bucket(bucketName);
      const [files] = await bucket.getFiles({ prefix: outputPrefix });
      let text = "";
      let pages = 0;
      for (const file of files) {
        if (!file.name.endsWith(".json")) continue;
        const [contents] = await file.download();
        const json = JSON.parse(contents.toString());
        const responses = json.responses || [];
        pages += responses.length;
        for (const response of responses) {
          const pageText =
            response.fullTextAnnotation?.text ||
            response.textAnnotations?.[0]?.description ||
            "";
          if (pageText) {
            text = text ? `${text}\n${pageText}` : pageText;
          }
        }
      }
      console.log(
        `[PDF_OCR] pages=${pages} textLength=${text.length} previewFirst200=${text.slice(0, 200)}`,
      );
      return text;
    }
    const [result] = await visionClient.textDetection({
      image: { source: { imageUri: gcsUri } },
      imageContext: { languageHints },
    });
    return (
      result.fullTextAnnotation?.text ||
      (result.textAnnotations && result.textAnnotations[0]?.description) ||
      ""
    );
  };

  try {
    if (contentType === "application/pdf") {
      fullText = await run(["he", "en"]);
    } else {
      const firstPass = await run(["en"]);
      const hints = detectScripts(firstPass || "");
      console.log("[extractTextWithVision] hints=", hints.join(","));
      fullText = firstPass;
      if (!fullText || fullText.length < 120) {
        const second = await run(hints);
        if (second.length > fullText.length) {
          fullText = second;
        }
      }
    }
    if (!fullText) {
      console.warn("[extractTextWithVision] no text for", gcsUri);
    } else {
      console.log("[extractTextWithVision] length", fullText.length);
    }
  } catch (err) {
    console.error("[extractTextWithVision] Vision error for", gcsUri, err);
    return "";
  }

  const text = fullText || "";
  // Approximate confidence and lines from annotation
  const lines: OcrLine[] = [];
  const avgConfidence = 0.0; // Vision v1 client does not expose avg; placeholder for now.

  return { text, avgConfidence, lines };
}

function detectLanguages(text: string): string[] {
  const langs = new Set<string>();
  if (/[א-ת]/.test(text)) langs.add("he");
  if (/[ء-ي]/.test(text)) langs.add("ar");
  if (/[А-Яа-яЁёЀ-ӿ]/.test(text)) langs.add("ru");
  if (/[A-Za-z]/.test(text)) langs.add("en");
  if (langs.size === 0) langs.add("unknown");
  return Array.from(langs);
}

function sanitizeText(raw: string): string {
  const cleaned = raw
    .replace(/[\u0000-\u001F\u007F\u0080-\u009F]/g, " ")
    .replace(/[~^`|]/g, " ")
    .replace(/Ø/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  return cleaned;
}

function splitSections(rawText: string): ParsedSections {
  const lines = rawText
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter((l) => l.length > 0);
  const headerRegex = /(steps|instructions|method|אופן הכנה|הכנה|שלבים)/i;
  let headerIndex = -1;
  for (let i = 0; i < lines.length; i++) {
    if (headerRegex.test(lines[i])) {
      headerIndex = i;
      break;
    }
  }
  if (headerIndex === -1) {
    return { ingredients: lines, steps: [], hadHeader: false };
  }
  const ingredients = lines.slice(0, headerIndex);
  const steps = lines.slice(headerIndex + 1);
  return { ingredients, steps, hadHeader: true };
}

async function parseRecipeWithLLM(text: string): Promise<ParsedRecipe> {
  console.log("[LLM] has key:", !!process.env.OPENAI_API_KEY);
  console.log("[LLM] input length:", text.length);

  try {
    if (!openaiApiKey) {
      throw new Error("Missing OpenAI API key");
    }

    const completion = await openai.createChatCompletion({
      model: "gpt-3.5-turbo",
      temperature: 0,
      messages: [
        {
          role: "system",
          content:
            "You are a chef assistant. Return ONLY valid JSON.",
        },
        {
          role: "user",
          content: `
Convert the following recipe text into STRICT JSON with this schema:
{
  "title": "string",
  "preCookingNotes": "string",
  "ingredients": [{ "name": "string", "quantity": "string", "unit": "string" }],
  "tools": [{ "name": "string" }],
  "steps": [{ "text": "string", "durationMinutes": 0 }]
}
Return ONLY JSON, no prose. Preserve the original language in all fields; do NOT translate.

Recipe text:
"""${text}"""
          `,
        },
      ],
    });

    const content = completion?.data?.choices?.[0]?.message?.content;
    console.log("[LLM] raw response received");

    if (!content) {
      throw new Error("LLM returned empty content");
    }

    return JSON.parse(content);
  } catch (err) {
    console.error("[LLM] error", err);
    throw err;
  }
}

export const onRecipeDocUploaded = functions.storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name || "";
    const bucketName = object.bucket;
    const contentType = object.contentType || "";

    console.log("[onRecipeDocUploaded] START", filePath, bucketName, contentType);

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

    const db = admin.firestore();
    const recipeRef = db.collection("recipes").doc(recipeId);

    await recipeRef.set(
      {
        importStatus: "processing",
        importStage: "ocr",
        ocrStatus: "processing",
        progress: 10,
        debugStage: "ocr_start",
      },
      { merge: true },
    );

    try {
      const { text: rawVisionText, avgConfidence, lines } =
        await extractTextWithVision(bucketName, filePath, contentType);
      const rawText = sanitizeText(rawVisionText || "");
      console.log("[onRecipeDocUploaded] OCR length =", rawText.length);
      console.log("[onRecipeDocUploaded] OCR preview =", rawText.slice(0, 200));

      if (!rawText.trim() || rawText.length < 40) {
        console.warn("[onRecipeDocUploaded] OCR empty/short; needs_review");
        await recipeRef.set(
          {
            importStatus: "needs_review",
            importStage: "needs_review",
            ocrStatus: "needs_review",
            debugStage: "ocr_empty",
            progress: 90,
            ocrRawText: rawText,
            ocrMeta: {
              engine: "vision",
              languageHints: ["he", "en"],
              avgConfidence: avgConfidence || 0,
              garbageCharRatio: 1,
              lineCount: 0,
            },
            parseMeta: {
              warnings: ["ocr_empty"],
              needsReviewReason: "ocr_empty",
            },
          },
          { merge: true },
        );
        return;
      }

      const garbageCharRatio =
        rawText.length === 0
          ? 1
          : (rawText.match(/[^A-Za-z0-9א-תء-ي\s\.\,\-\:\;\(\)\[\]\{\}]/g) || [])
              .length / rawText.length;
      const detectedLangs = detectLanguages(rawText);
      await recipeRef.set(
        {
          importStage: "parse",
          debugStage: "ocr_parsed",
          ocrStatus: "processing",
          progress: 60,
          ocrMeta: {
            engine: "vision",
            languageHints: ["he", "en"],
            languages: detectedLangs,
            length: rawText.length,
            avgConfidence: avgConfidence || 0,
            garbageCharRatio,
            lineCount: lines.length,
          },
          ocrRawText: rawText.slice(0, 20000),
        },
        { merge: true },
      );

      const sections = splitSections(rawText);
      const ingredients = sections.ingredients.map((line) => ({
        name: line,
        quantity: "",
        unit: "",
      }));
      const steps = sections.steps.map((line, idx) => ({
        text: line,
        durationSeconds: null,
        order: idx,
      }));
      console.log("[PARSE] before", {
        ing: ingredients.length,
        steps: steps.length,
        tools: 0,
      });

      const parseIssues: string[] = [];
      if (ingredients.length < 3) parseIssues.push("too_few_ingredients");
      if (steps.length < 3) parseIssues.push("too_few_steps");

      const needsReviewSections =
        !sections.hadHeader ||
        ingredients.length < 3 ||
        steps.length < 3 ||
        rawText.length < 80 ||
        garbageCharRatio > 0.35 ||
        (avgConfidence && avgConfidence < 0.4);

      const titleCandidate = "";
      const titleEvidence = "";
      const hasTitleEvidence =
        !!titleCandidate &&
        !!titleEvidence &&
        rawText.toLowerCase().includes(titleEvidence.toLowerCase());
      const needsReviewTitle = !hasTitleEvidence;
      const needsReview = needsReviewSections || needsReviewTitle;

      console.log("[PARSE] after", {
        ing: ingredients.length,
        steps: steps.length,
        tools: 0,
        issues: parseIssues,
      });

      console.log(
        "[TITLE_GATE]",
        JSON.stringify({
          titleCandidate,
          titleEvidence,
          hasTitleEvidence,
          needsReviewTitle,
        }),
      );

      await recipeRef.set(
        {
          importStage: needsReview ? "needs_review" : "ready",
          importStatus: needsReview ? "needs_review" : "ready",
          ocrStatus: needsReview ? "needs_review" : "done",
          debugStage: needsReview ? "needs_review" : "done",
          progress: needsReview ? 90 : 100,
          ingredients,
          steps,
          title: hasTitleEvidence ? titleCandidate : "",
          preCookingNotes: "",
          ocrRawText: rawText.slice(0, 20000),
          ocrMeta: {
            engine: "vision",
            languageHints: ["he", "en"],
            languages: detectedLangs,
            length: rawText.length,
            avgConfidence: avgConfidence || 0,
            garbageCharRatio,
            lineCount: lines.length,
            hadHeader: sections.hadHeader,
          },
          parseMeta: needsReview
            ? {
                warnings: (() => {
                  const arr = ["needs_review"];
                  arr.push(...parseIssues);
                  if (!hasTitleEvidence) arr.push("missing_explicit_title");
                  return arr;
                })(),
                needsReviewReason: needsReviewTitle
                  ? "missing_explicit_title"
                  : "low_confidence_or_missing_sections",
              }
            : admin.firestore.FieldValue.delete(),
          importError: needsReview
            ? admin.firestore.FieldValue.delete()
            : admin.firestore.FieldValue.delete(),
          status: needsReview ? "needs_review" : "done",
        },
        { merge: true },
      );

      console.log("[onRecipeDocUploaded] SUCCESS", recipeId);
    } catch (err) {
      console.error("[onRecipeDocUploaded] ERROR", err);
      await recipeRef.set(
        {
          importStatus: "failed",
          importStage: "failed",
          ocrStatus: "failed",
          debugStage: "failed",
          importError: err instanceof Error ? err.message : String(err),
        },
        { merge: true }
      );
    }
  });

// If you have other exports (e.g. createFavoriteCookbook), keep them below this line.

export const onRecipeCreatedSim = onDocumentCreated(
  {
    document: "recipes/{recipeId}",
    region: "us-central1",
    retry: false,
  },
  async (event: any) => {
    const data = event.data?.data?.();
    const recipeId = event.params?.recipeId;
    if (!data || !recipeId) return;
    const status = data.status || data.importStatus;
    const sourceFilePath = data.sourceFilePath || data.originalDocumentUrl;
    if (status !== "processing" || !sourceFilePath) {
      console.log("[onRecipeCreatedSim] skipping recipeId", recipeId, "status", status);
      return;
    }
    const db = admin.firestore();
    const ref = db.collection("recipes").doc(recipeId);
    const stages = [
      { progress: 10, debugStage: "function_started" },
      { progress: 30, debugStage: "downloading" },
      { progress: 60, debugStage: "ocr_running" },
      { progress: 90, debugStage: "parsing" },
    ];
    for (const stage of stages) {
      await ref.set(
        {
          progress: stage.progress,
          debugStage: stage.debugStage,
          status: "processing",
        },
        { merge: true },
      );
      await sleep(1000);
    }
    const extractedRecipe = {
      title: "OCR TEST",
      ingredients: [
        { name: "Test ingredient 1", quantity: "1", unit: "cup" },
        { name: "Test ingredient 2", quantity: "2", unit: "tsp" },
      ],
      steps: [
        { text: "Step 1: This is a simulated OCR result.", durationSeconds: null, order: 0 },
        { text: "Step 2: Replace with real OCR later.", durationSeconds: null, order: 1 },
      ],
      tools: [{ name: "Bowl" }],
      preCookingNotes: "Simulated OCR pipeline",
    };
    await ref.set(
      {
        progress: 100,
        debugStage: "done",
        status: "done",
        importStatus: "ready",
        importStage: "ready",
        importError: admin.firestore.FieldValue.delete(),
        title: extractedRecipe.title,
        ingredients: extractedRecipe.ingredients,
        steps: extractedRecipe.steps,
        tools: extractedRecipe.tools,
        preCookingNotes: extractedRecipe.preCookingNotes,
      },
      { merge: true },
    );
    console.log("[onRecipeCreatedSim] completed recipeId", recipeId);
  },
);

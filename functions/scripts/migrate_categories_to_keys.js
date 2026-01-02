/* eslint-disable no-console */
/**
 * One-time migration:
 * - Normalizes `recipes.categories` and `cookbooks.categories` to stable category keys.
 * - Also creates canonical system cookbooks at `/system_cookbooks/{categoryKey}`.
 *
 * Usage (local):
 *   1) export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
 *   2) (optional) export FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
 *   3) node scripts/migrate_categories_to_keys.js
 */

const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const CATEGORY_OPTIONS = [
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

const titleToKey = new Map(
  CATEGORY_OPTIONS.map((c) => [c.title.toLowerCase(), c.key]),
);
const knownKeys = new Set(CATEGORY_OPTIONS.map((c) => c.key));
const keyToTitle = new Map(CATEGORY_OPTIONS.map((c) => [c.key, c.title]));

function slugifyToKey(input) {
  const trimmed = String(input || "").trim();
  if (!trimmed) return "";
  const lower = trimmed.toLowerCase();
  if (knownKeys.has(lower)) return lower;
  const byTitle = titleToKey.get(lower);
  if (byTitle) return byTitle;
  return lower
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/(^-|-$)/g, "");
}

function extractCategoryStrings(raw) {
  if (!raw) return [];
  if (typeof raw === "string") return [raw];
  if (!Array.isArray(raw)) return [];
  const out = [];
  for (const item of raw) {
    if (typeof item === "string") {
      out.push(item);
      continue;
    }
    if (item && typeof item === "object") {
      const key = item.key || item.id;
      const title = item.title || item.name;
      if (key) out.push(String(key));
      else if (title) out.push(String(title));
    }
  }
  return out;
}

function normalizeCategoriesFromDocData(data) {
  const raw = data.categories ?? data.category ?? null;
  const strings = extractCategoryStrings(raw);
  const result = [];
  const seen = new Set();
  for (const value of strings) {
    const key = slugifyToKey(value);
    if (!key) continue;
    if (seen.has(key)) continue;
    result.push(key);
    seen.add(key);
    if (result.length >= 5) break;
  }
  return result;
}

async function paginateCollection(collectionName, pageSize, onPage) {
  let last = null;
  let page = 0;
  while (true) {
    let query = db.collection(collectionName).orderBy(admin.firestore.FieldPath.documentId()).limit(pageSize);
    if (last) query = query.startAfter(last);
    const snap = await query.get();
    if (snap.empty) break;
    page += 1;
    await onPage(snap, page);
    last = snap.docs[snap.docs.length - 1];
  }
}

async function migrateCategoriesInCollection(collectionName) {
  console.log(`[MIGRATE] collection=${collectionName} starting`);
  let updated = 0;
  let scanned = 0;
  await paginateCollection(collectionName, 400, async (snap, page) => {
    const batch = db.batch();
    let batchUpdates = 0;
    for (const doc of snap.docs) {
      scanned += 1;
      const data = doc.data() || {};
      const normalized = normalizeCategoriesFromDocData(data);
      if (!normalized.length) continue;
      const existing = extractCategoryStrings(data.categories);
      const existingNorm = existing.map(slugifyToKey).filter(Boolean);
      const same =
        existingNorm.length === normalized.length &&
        existingNorm.every((v, i) => v === normalized[i]);
      if (same) continue;
      batch.update(doc.ref, { categories: normalized });
      batchUpdates += 1;
      updated += 1;
    }
    if (batchUpdates > 0) {
      await batch.commit();
    }
    if (page % 5 === 0) {
      console.log(
        `[MIGRATE] collection=${collectionName} page=${page} scanned=${scanned} updated=${updated}`,
      );
    }
  });
  console.log(`[MIGRATE] collection=${collectionName} done scanned=${scanned} updated=${updated}`);
}

async function migrateSystemCookbooks() {
  console.log("[MIGRATE] system_cookbooks canonicalization starting");
  const snap = await db.collection("system_cookbooks").get();
  if (snap.empty) {
    console.log("[MIGRATE] system_cookbooks empty, creating canonical docs from CATEGORY_OPTIONS");
    const batch = db.batch();
    for (const c of CATEGORY_OPTIONS) {
      batch.set(db.collection("system_cookbooks").doc(c.key), {
        title: c.title,
        categories: [c.key],
        isSystem: true,
        ownerName: "Foodiy",
      }, { merge: true });
    }
    await batch.commit();
    console.log("[MIGRATE] system_cookbooks created");
    return;
  }

  const batch = db.batch();
  let moves = 0;
  for (const doc of snap.docs) {
    const data = doc.data() || {};
    const rawKey = String(doc.id || "");
    const stripped = rawKey.startsWith("system::") ? rawKey.replace(/^system::/, "") : rawKey;
    const keyCandidate = normalizeCategoriesFromDocData({ categories: [stripped], category: data.title }).at(0) || slugifyToKey(stripped) || slugifyToKey(data.title);
    if (!keyCandidate) continue;
    const canonicalRef = db.collection("system_cookbooks").doc(keyCandidate);
    const title = data.title || data.name || keyToTitle.get(keyCandidate) || keyCandidate;
    batch.set(canonicalRef, { ...data, title, categories: [keyCandidate], isSystem: true }, { merge: true });
    if (doc.id !== keyCandidate) {
      batch.delete(doc.ref);
      moves += 1;
    }
  }
  await batch.commit();
  console.log(`[MIGRATE] system_cookbooks canonicalization done (moved/deleted=${moves})`);
}

async function main() {
  console.log("[MIGRATE] starting categories->keys migration");
  await migrateSystemCookbooks();
  await migrateCategoriesInCollection("recipes");
  await migrateCategoriesInCollection("cookbooks");
  console.log("[MIGRATE] complete");
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error("[MIGRATE] failed", e);
    process.exit(1);
  });


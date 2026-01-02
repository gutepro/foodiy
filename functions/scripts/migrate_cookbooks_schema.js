/* eslint-disable no-console */
/**
 * One-time backfill for /cookbooks documents to the canonical schema:
 * - title (fallback: name)
 * - coverImageUrl (fallback: imageUrl)
 * - viewsCount (default: 0)
 *
 * Usage:
 *   cd functions
 *   node scripts/migrate_cookbooks_schema.js
 *
 * Auth:
 * - Uses Application Default Credentials.
 * - Set GOOGLE_APPLICATION_CREDENTIALS to a service-account JSON path, or run where ADC is available.
 */

const admin = require("firebase-admin");

function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function isNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

async function main() {
  if (admin.apps.length === 0) {
    admin.initializeApp();
  }

  const db = admin.firestore();
  const cookbooksRef = db.collection("cookbooks");

  let scanned = 0;
  let updated = 0;
  let skipped = 0;
  const examples = [];

  let lastDoc = null;
  const pageSize = 250;

  while (true) {
    let query = cookbooksRef.orderBy(admin.firestore.FieldPath.documentId()).limit(pageSize);
    if (lastDoc) query = query.startAfter(lastDoc);
    const snap = await query.get();
    if (snap.empty) break;

    for (const doc of snap.docs) {
      scanned++;
      const data = doc.data() || {};
      const updates = {};

      const title = isNonEmptyString(data.title)
        ? data.title.trim()
        : isNonEmptyString(data.name)
          ? data.name.trim()
          : "";
      if (!isNonEmptyString(data.title) && title) {
        updates.title = title;
      }

      const coverImageUrl = isNonEmptyString(data.coverImageUrl)
        ? data.coverImageUrl.trim()
        : isNonEmptyString(data.imageUrl)
          ? data.imageUrl.trim()
          : "";
      if (!isNonEmptyString(data.coverImageUrl) && coverImageUrl) {
        updates.coverImageUrl = coverImageUrl;
      }

      if (!isNumber(data.viewsCount)) {
        // Keep it deterministic. We do not attempt to infer.
        updates.viewsCount = 0;
      }

      if (Object.keys(updates).length === 0) {
        skipped++;
        continue;
      }

      updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();
      await doc.ref.set(updates, { merge: true });
      updated++;

      if (examples.length < 10) {
        examples.push({
          id: doc.id,
          before: {
            title: data.title,
            name: data.name,
            coverImageUrl: data.coverImageUrl,
            imageUrl: data.imageUrl,
            viewsCount: data.viewsCount,
          },
          after: updates,
        });
      }
    }

    lastDoc = snap.docs[snap.docs.length - 1];
    console.log(`[cookbooks schema] progress scanned=${scanned} updated=${updated} skipped=${skipped}`);
  }

  console.log(`[cookbooks schema] DONE scanned=${scanned} updated=${updated} skipped=${skipped}`);
  console.log(`[cookbooks schema] examples=${JSON.stringify(examples, null, 2)}`);
}

main().catch((err) => {
  console.error("[cookbooks schema] FAILED", err);
  process.exitCode = 1;
});


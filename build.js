/*
 * build.js — turns src/page.html into the two things we ship.
 *
 *   index.html         full HTML document, relative asset paths  → deploy this
 *   dist/artifact.html bare fragment, portrait inlined as base64 → publish this
 *
 * Why two: the Artifact host supplies its own <html>/<head>/<body>, so the
 * artifact build must NOT carry a document skeleton — but a real website must,
 * or browsers drop into quirks mode and the layout breaks. The artifact also
 * can't reach sibling files over the network, so its portrait is inlined.
 *
 * Run:  node build.js
 */

const fs = require("fs");
const path = require("path");

const SRC = path.join(__dirname, "src", "page.html");
const PORTRAIT = path.join(__dirname, "src", "assets", "portrait.jpg");
const OUT_SITE = path.join(__dirname, "index.html");
const OUT_ART = path.join(__dirname, "dist", "artifact.html");

const DESCRIPTION =
  "Tushar Wararkar — buyer, sourcing and procurement engineer for chemicals, oil and gas. " +
  "End-to-end chemical procurement and tender lifecycle ownership. Mumbai, India.";

const FAVICON =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E" +
  "%3Crect width='32' height='32' rx='6' fill='%230E6A4E'/%3E" +
  "%3Ccircle cx='16' cy='16' r='3.4' fill='%23EEF1ED'/%3E" +
  "%3Cellipse cx='16' cy='16' rx='13' ry='5.2' fill='none' stroke='%23EEF1ED' stroke-width='1.6' " +
  "transform='rotate(-24 16 16)'/%3E" +
  "%3Cellipse cx='16' cy='16' rx='13' ry='5.2' fill='none' stroke='%23EEF1ED' stroke-width='1.6' " +
  "transform='rotate(46 16 16)'/%3E%3C/svg%3E";

const fragment = fs.readFileSync(SRC, "utf8");

if (!fragment.includes("__PORTRAIT_SRC__")) {
  throw new Error("src/page.html: __PORTRAIT_SRC__ token is missing.");
}

// --- artifact build: portrait inlined so the shared link is self-contained ---
const portraitDataUri =
  "data:image/jpeg;base64," + fs.readFileSync(PORTRAIT).toString("base64");
const artifact = fragment.replace(/__PORTRAIT_SRC__/g, portraitDataUri);

// --- site build: relative path, plus a document skeleton ---
const site = fragment.replace(/__PORTRAIT_SRC__/g, "assets/portrait.jpg");

const splitAt = site.lastIndexOf("</style>");
if (splitAt === -1) {
  throw new Error("src/page.html: expected a </style> block to split head from body.");
}
const head = site.slice(0, splitAt + "</style>".length).trim();
const body = site.slice(splitAt + "</style>".length).trim();

const titleMatch = head.match(/<title>([\s\S]*?)<\/title>/i);
const title = titleMatch ? titleMatch[1].trim() : "Tushar Wararkar";

const document = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="${DESCRIPTION}">
<meta name="author" content="Tushar Wararkar">
<meta name="color-scheme" content="light dark">
<meta property="og:type" content="website">
<meta property="og:title" content="${title} — Sourcing &amp; Procurement Engineer">
<meta property="og:description" content="${DESCRIPTION}">
<meta name="twitter:card" content="summary">
<link rel="icon" href="${FAVICON}">
${head}
</head>
<body>
${body}
</body>
</html>
`;

fs.mkdirSync(path.dirname(OUT_ART), { recursive: true });
fs.mkdirSync(path.join(__dirname, "assets"), { recursive: true });
fs.copyFileSync(PORTRAIT, path.join(__dirname, "assets", "portrait.jpg"));
fs.writeFileSync(OUT_SITE, document, "utf8");
fs.writeFileSync(OUT_ART, artifact, "utf8");

const kb = (s) => (s.length / 1024).toFixed(1) + " KB";
console.log(`index.html          ${kb(document)}  (assets/portrait.jpg alongside)`);
console.log(`dist/artifact.html  ${kb(artifact)}  (portrait inlined)`);

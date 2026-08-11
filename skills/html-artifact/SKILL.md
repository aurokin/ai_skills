---
name: html-artifact
description: Create or update a self-contained HTML artifact for a plan, spec, report, findings, summary, comparison, or set of UI mock variants. Use when the user asks to communicate through an HTML document or artifact, or mentions HTML without a product implementation context. Do not use for HTML that ships as part of a product.
---

# HTML Artifact

Create one self-contained HTML file for communication and review, not product code. Use the material already in the conversation or the documents the user provides.

## Build the document

Keep the file at or below 512 KB.

- Write it like a spec, not a landing page. Make it dense and scannable. Avoid heroes, decorative chrome, marketing copy, and em dashes.
- Default to true black (`#000`), white primary text, and dark gray for secondary surfaces or accents.
- Make it mobile-readable with a responsive viewport and no fixed-width layout.
- Use semantic HTML, inline CSS, inline SVG, and data-URL images. Use HTTPS images only when embedding them is impractical and the source is safe to disclose.
- Use an inline classic script only when interactivity materially helps. Keep scripted pages useful without JavaScript. Assume the sandbox blocks storage, fetch, workers, frames, forms, and popups.
- In script-free files, give external links `target="_blank"` and `rel="noopener noreferrer"`. If any script exists, omit `target="_blank"`.

Never include external or module scripts, inline event handlers, `javascript:` URLs, forms, frames, embeds, objects, applets, meta refresh, linked stylesheets, secrets, private URLs, or local filesystem paths.

## Render variants directly

When the user asks for UI variants:

- Render real styled variants instead of describing them.
- Label them `A`, `B`, `C`, and so on for easy selection.
- Lay them out for direct comparison.
- Keep one file across iterations so any published URL stays stable.

## Validate and deliver

1. Write the HTML to the requested path. If none is given, choose a descriptive `.html` filename in the working directory.
2. Check the file size and inspect it for prohibited elements and sensitive content.
3. Report the local path.

Keep the artifact local unless the user asks for a hosted URL or has already given standing permission to publish HTML artifacts in the current environment.

When publishing is authorized:

1. Run `npx postplan upload <file-path>`.
2. Report the returned Postplan URL with the local path.
3. Re-upload the same absolute path to update the existing URL. Use `npx postplan upload <file-path> --new` only when the user wants a separate draft.

If validation fails, fix the markup and retry. If upload requires authentication, ask the user to run `postplan auth login`, then retry. Never open a browser or claim the document is hosted before upload succeeds. Do not verify it in a browser unless the user asks.

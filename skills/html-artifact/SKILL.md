---
name: html-artifact
description: Create or update a self-contained HTML artifact for a plan, spec, report, findings, summary, comparison, or set of UI mock variants. Use when the user asks to communicate through an HTML document or artifact, or mentions HTML without a product implementation context. Do not use for HTML that ships as part of a product.
---

# HTML Artifact

Create one self-contained HTML file for communication and review, not product code. Use the material already in the conversation or the documents the user provides.

## Build the document

- Write it like a spec, not a landing page. Make it dense and scannable. Avoid heroes, decorative chrome, marketing copy, and em dashes.
- Visualize information when it can make the material easier to understand or more compelling. Choose the form that best fits the content.
- Keep visuals information-dense. Do not invent data or add visuals merely to decorate the page.
- Default to true black (`#000`), white primary text, and dark gray for secondary surfaces or accents.
- Make it mobile-readable with a responsive viewport and no fixed-width layout.
- Use semantic HTML, inline CSS, inline SVG, and data-URL images. Use HTTPS images only when embedding them is impractical and the source is safe to disclose.

## Receiving Feedback

Only add feedback controls when the user explicitly asks to collect responses inside the artifact. Otherwise, keep the artifact read-only.

When requested:

- Place each input beside the section it refers to.
- Keep feedback in memory only. Do not persist or transmit it.
- Provide separate controls to copy all feedback and export it, with a selectable-text fallback when clipboard access is unavailable.
- For a small amount of feedback, use lightweight inline controls rather than building a larger feedback system.

## Render variants directly

When the user asks for UI variants:

- Render real styled variants instead of describing them.
- Label them `A`, `B`, `C`, and so on for easy selection.
- Lay them out for direct comparison.
- Keep one file across iterations.

## Validate and deliver

1. Write the HTML to the requested path. If none is given, choose a descriptive `.html` filename in a .tmp subfolder within the working directory.
2. Report the local path.

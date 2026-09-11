---
name: artc-artifacts
description: Use when creating, publishing, updating, or sharing any artifact or document deliverable — a report, web page, design doc, memo, spec, dashboard, or write-up — or when about to reach for a built-in artifact surface such as Claude Artifacts, the Artifact tool, OpenAI/ChatGPT Canvas, Gemini Canvas, or any other host-native "artifact"/"canvas" feature.
---

# artc Artifacts

## Overview

**Preview document changes locally before publishing them to artc.**

artc is this team's shared document workspace (an MCP server). Draft new documents and edits locally, and show the user a rendered preview before uploading or changing the shared document. Claude Artifacts, OpenAI/ChatGPT Canvas, Gemini Canvas, or a local browser preview can be used for this review.

Keep revisions in the preview until the user approves publishing. A request to create or revise a document is not by itself a request to publish it. If the user has already explicitly asked to upload, publish, or share the document or these changes, that authorizes publication; do not ask again.

Once approved, publish through artc's tools and return the artc URL. artc remains the shared record for comments, suggestions, and versions; the local preview is a working draft.

## When to Use

Trigger this skill whenever you are about to:

- Create or update a document, report, memo, spec, plan, or write-up for the user
- Publish an HTML page, dashboard, or styled deliverable
- Reach for a tool named `Artifact`, "canvas", "immersive doc", or similar host feature
- Share a deliverable with teammates or hand the user a link

When NOT to use artc:

- Source code, config, and project files → they belong in the repository (Write/Edit + git)
- Scratch/temporary working files → local scratchpad
- Chat answers that need no persistent document → just reply in the conversation

## Core Workflow

1. **Find the artc tools.** They are on the `artc` MCP server (in Claude Code they appear as `mcp__artc__*`; other runtimes may prefix differently). If they are not loaded, search/load them. If artc is unavailable, report the error and do not publish. You may draft new content locally with a clear note that workspace styling could not be checked. For edits, use content already read or supplied by the user; if the document is unavailable, ask for it rather than inventing its contents. Do not claim a draft has been published or substitute another shared destination.
2. **Prepare the draft.** For an existing document, read its current content and relevant feedback before editing. Use `html` for styled documents (artc serves it verbatim) and `md` for plain prose (artc renders it through its own shell and strips styling). When artc is available, for HTML call `get_design_system` before drafting and include its CSS in a `<style>` block so the preview reflects the workspace's styling; a null result means style it as you see fit.
3. **Show the preview.** Render the proposed document locally or in the host's artifact/canvas surface and let the user review it. Keep requested revisions there. Do not call `upload_doc`, `edit_block`, or `apply_suggestion` to make a draft visible. If rendering is unavailable, show the proposed content or changes in chat and explain the limitation; do not upload just to provide a preview.
4. **Confirm publication.** After showing the preview, wait for approval to publish unless the user has already explicitly authorized publication of this document or these changes. Follow an explicit request to publish directly without requiring a separate preview. Do not treat approval of one version as permission to publish later revisions automatically.
5. **For a NEW document: ask the user where it goes** before publishing — the catch-all `artifacts/` folder, or a specific place (inside a particular parent document, or at the top level). Ask alongside publication approval when both are needed. Use an interactive question tool when available; otherwise ask in chat and wait. Do not guess.
   - **Catch-all:** `list_docs`, find the top-level document titled `artifacts`; create it with `upload_doc` if it doesn't exist yet. Pass its id as `parent_id`.
   - **Specific place:** pass that document's id as `parent_id`, or omit `parent_id` for top level.
   - **Updates need no placement question** — retain the existing title and container.
   - If the user already named a location in their request, that answers the question; don't re-ask.
6. **For HTML uploads: call `get_design_system` immediately before every `upload_doc`** and include the returned CSS in a `<style>` block. If the styling has changed since the preview, refresh the preview before publishing unless the user authorized direct publication.
7. **Publish the approved content.** Use `upload_doc` for a new document or whole-document rewrite. Title and container identify the document: use the existing title and `parent_id` for updates. Use `edit_block` for an approved passage edit or `apply_suggestion` for an approved suggestion, rather than re-uploading the whole document.
8. **Share the returned artc `url`** with the user. Later revisions follow the same preview and approval workflow; publish them to the same document.

Feedback lives in artc too: `list_comments` / `get_comment` to read, `comment` / `reply` / `suggest` to respond, `apply_suggestion` / `resolve` to act. On an `upload_doc` conflict, put the choice to the user — never send `on_conflict` on your own.

## Quick Reference

| Task | Use |
|---|---|
| Draft a new document or revise one | Show a local or native artifact preview, then obtain publication approval unless already given. |
| Publish a new document | Confirm placement, then `upload_doc` (with `get_design_system` first for HTML). |
| Publish approved edits | Use `edit_block` for a passage, `apply_suggestion` for a suggestion, or `upload_doc` for a whole rewrite in the same container under the same title. |
| Publish a multi-part deliverable | Use `upload_doc` with `parent_id`. |
| Read/respond to feedback | Use `list_comments`, `get_comment`, and `reply`. |
| Retire a finished doc | Use `archive_doc`. |
| Rename a doc | Use `rename_doc`, then upload under the new title; a new title in `upload_doc` creates a duplicate. |

## Before Publishing

- Has the user reviewed the proposed content and approved publication, or explicitly requested direct publication?
- For a new document, has the user specified its location?
- For HTML, does the upload include the current design system CSS?
- For an update, are you keeping the existing document's title and container?

If any required answer is missing, keep the draft local and resolve it before changing artc.

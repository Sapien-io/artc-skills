---
name: artc-artifacts
description: Use when creating, publishing, updating, or sharing any artifact or document deliverable — a report, web page, design doc, memo, spec, dashboard, or write-up — or when about to reach for a built-in artifact surface such as Claude Artifacts, the Artifact tool, OpenAI/ChatGPT Canvas, Gemini Canvas, or any other host-native "artifact"/"canvas" feature.
---

# artc Artifacts

## Overview

**Every artifact goes through artc. No exceptions.**

artc is this team's document workspace (an MCP server). All deliverables — reports, web pages, design docs, memos, specs, write-ups, anything a person will read, review, or share — are created and updated with artc's tools, never with the host platform's built-in artifact system.

**The rule:** If you are about to produce a document-shaped deliverable, publish it with `upload_doc` on the artc MCP server. Never use Claude Artifacts (the `Artifact` tool), OpenAI/ChatGPT Canvas, Gemini Canvas, or any equivalent host-native artifact/canvas/preview surface — not even "as well as" artc, and not as a fallback you choose on your own.

Why: artc is where the team's documents live — comments, suggestions, versions, the shared design system, and idempotent updates all work only there. A deliverable published anywhere else is invisible to the team's review workflow and splits the record.

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

1. **Find the tools.** They are on the `artc` MCP server (in Claude Code they appear as `mcp__artc__*`; other runtimes may prefix differently). If they are not loaded, search/load them (e.g. via tool search) — "tools not loaded yet" is not a reason to fall back to a native artifact surface.
2. **Pick the kind.** `html` for anything that should carry styling (artc serves it verbatim); `md` for plain prose (artc renders it through its own shell and strips styling).
3. **For a NEW document: ask the user where it goes** before publishing — the catch-all `artifacts/` folder, or a specific place (inside a particular parent document, or at the top level). Use an interactive question tool (e.g. `AskUserQuestion`) when the runtime has one; otherwise ask in chat and wait. Do not guess.
   - **Catch-all:** `list_docs`, find the top-level document titled `artifacts`; create it with `upload_doc` if it doesn't exist yet. Pass its id as `parent_id`.
   - **Specific place:** pass that document's id as `parent_id`, or omit `parent_id` for top level.
   - **Updates to an existing title need no placement question** — the document stays where it is.
   - If the user already named a location in their request, that answers the question; don't re-ask.
4. **For `html`: call `get_design_system` immediately before every `upload_doc`** — every upload, not once per session — and write the returned CSS into a `<style>` block inside the document. A null result means style it as you see fit.
5. **Publish with `upload_doc`.** Title is the identity: the same title updates the document as a new version; a new title creates a new document. Use `parent_id` for parts of a multi-part artifact.
6. **Share the returned `url`** with the user. That link is the deliverable.
7. **Updates go to the same title.** Never fork to a native artifact surface for "the interactive version" or "a quick preview".

Feedback lives in artc too: `list_comments` / `get_comment` to read, `comment` / `reply` / `suggest` to respond, `apply_suggestion` / `resolve` to act. On an `upload_doc` conflict, put the choice to the user — never send `on_conflict` on your own.

## Quick Reference

| Task | Use | Never |
|---|---|---|
| New document/report/page | Ask placement (`artifacts/` or specific), then `upload_doc` (with `get_design_system` first if html) | `Artifact` tool, Canvas |
| Update a deliverable | `upload_doc`, same title | Re-publishing to a native surface |
| Multi-part deliverable | `upload_doc` with `parent_id` | Multiple native artifacts |
| Read/respond to feedback | `list_comments`, `get_comment`, `reply` | Host comment features |
| Retire a finished doc | `archive_doc` | Deleting or abandoning |
| Rename a doc | `rename_doc`, then upload under the new title | New title in `upload_doc` (creates a duplicate) |

## Rationalizations — All Invalid

| Excuse | Reality |
|---|---|
| "The native Artifact tool is right there / faster" | Speed is not the goal; the team's shared record is. Use artc. |
| "It's just a quick preview / draft" | Drafts get versions in artc. A native preview forks the record. |
| "The user said 'make an artifact'" | On this team, "artifact" means an artc document. Publish with `upload_doc`. |
| "artc tools aren't loaded in my tool list" | Load them (tool search / server connect). Absence from the visible list ≠ unavailable. |
| "I'll do both — artc and a native artifact" | Two homes means stale copies and split comments. artc only. |
| "This one is interactive/styled, native renders it better" | artc serves html verbatim. Use kind `html` with the design system CSS. |
| "The artc server seems down" | Report the error to the user and stop; do not silently substitute a native surface. |
| "They didn't say where it goes — I'll just pick top level" | Placement is the user's call for every new document: ask — `artifacts/` catch-all or a specific place. |

## Red Flags — STOP

- You are about to call a tool named `Artifact`, or open a canvas/immersive surface
- You are publishing a NEW document without having asked the user where it goes (`artifacts/` or a specific place)
- You are writing an HTML deliverable without having just called `get_design_system`
- You are publishing an update under a new title to "keep the old version"
- You caught yourself thinking "just this once, the built-in one is fine"

**All of these mean: stop, and route the deliverable through artc's `upload_doc`.**

---
name: marty-spits-hot-fire
description: "Create lyrics from a markdown source file using lyric-writer and album-art-director skills. Asks for genre, preserves any user-provided title exactly, suggests title only when none is given, saves lyrics to markdown file with title as filename (underscores for spaces). Use the exact user title verbatim; do not invent a new title. Prefer source files that contain full review text, and preserve that text verbatim for downstream lyric writing. Triggers: create lyrics from source, make song from text, write lyrics from markdown"
risk: low
source: community
date_added: "2026-04-12"
---

# Marty Spits Hot Fire

> Generate lyrics from a source markdown file using professional lyric writing tools.

---

## When to Use

This skill is applicable when the user requests:
- Creating lyrics from a source text/markdown file
- "Write lyrics from [source file]"
- "Make a song from this text"
- "Create lyrics using my notes"
- Any variation of turning written content into song lyrics

**Trigger phrases:**
- "create lyrics from source"
- "make song from text"
- "write lyrics from markdown"
- "marty spits hot fire"
- "turn text into lyrics"

---

## Workflow

```
Step 1: Ask for source markdown file
    ↓
Step 2: Ask for genre (with suggestions)
    ↓
Step 3: Read source file
    ↓
Step 4: Lock or generate title
    ↓
Step 5: Use lyric-writer to create initial lyrics
    ↓
Step 6: Use album-art-director to draft album art direction
    ↓
Step 7: Save to markdown file with title as filename
```

## Title Lock

- If the user provides a title, treat it as canonical.
- Use the user title verbatim.
- Do not generate alternate titles.
- Do not rename, improve, or "clean up" the title.
- Use the exact title in the filename, H1, metadata, and any prompt passed to another downstream model.
- If a downstream model suggests a different title, ignore it unless the user explicitly asks for a change.

---

## Step 1: Request Source File

Ask the user: 
> What markdown file should I use as the source for the lyrics?

If they provide a file path, validate it exists. If not, ask again.

---

## Step 2: Genre Selection

Present genre options and ask for selection:

**Recommended genres for source-based lyrics:**
1. Folk/Acoustic (Recommended) - Great for storytelling, spoken word sources
2. Hip-Hop/Rap - Good for dense text, lists, rants
3. Spoken Word - Natural fit for prose sources
4. Alternative/Indie - Versatile for various source materials
5. Custom - Specify your own genre

Use the `question` tool to get their choice.

---

## Step 3: Read Source File

Use the `read` tool to extract content from the provided markdown file. Preserve full review text blocks verbatim; do not trim them down to short snippets when the source already contains the complete text.

---

## Step 4: Generate Title Suggestion

If the user already provided a title, keep it exactly as given and skip suggestions.

If no title was provided, suggest one based on the source content:
- Extract key themes, phrases, or concepts
- Create a compelling, song-appropriate title
- Keep it under 60 characters for good song titles
- Present 2-3 options for user to choose from

Use `question` tool for title selection if providing options.

---

## Step 5: Initial Lyric Creation

Call the lyric-writer skill with the source content:
```
lyric-writer: [source content] [genre: selected genre]
```

When the source came from Marty Has an Idea, prioritize the full review text sections over any summaries or metadata. Keep the original wording intact for lyric adaptation.

This will:
- Apply professional prosody and rhyme craft
- Follow quality checks (13-point system)
- Create structured lyrics (verses, chorus, bridge)
- Show refinement passes
- Generate Suno style prompt

---

## Step 6: Draft Album Art Direction

If album art is needed for the output file, ask which AI art platform they use unless it is already specified, then use album-art-director principles to write a concise universal visual brief.

Capture:
- A 2-3 sentence concept description
- The AI art platform to use
- A platform-agnostic prompt that can be used in any image model
- Negative prompt only when supported
- Square 1:1, thumbnail-safe, 3000x3000px minimum specs

Keep the direction focused, low-clutter, and easy to read at small sizes.

---

## Step 7: Save Output

Create a markdown file with:
- Filename: [sanitized_title].md (spaces → underscores)
- Location: `/home/tully/Sync/marty/`
- Title must match the user-provided title exactly when one exists.

File structure:
```markdown
# [Song Title]

**Genre:** [Selected Genre]
**Source:** [Source File Path]
**Created:** [Timestamp]

## Lyrics

[Final lyrics from lyric-writer]

## Suno Style Prompt

[Style prompt from lyric-writer]

## Album Art

**Platform:** [Selected AI art platform]
**Concept:** [2-3 sentence visual direction based on album-art-director]
**Prompt:** [Universal prompt]
**Negative Prompt:** [If supported]
**Specs:** Square 1:1, thumbnail-safe, 3000x3000px minimum

## Source Text

[Full source text or full review text from the markdown file, preserved verbatim when available]

---
*Generated by Marty Spits Hot Fire skill*
```

---

## Quality Assurance

The process ensures:
1. Professional lyric structure (verse/chorus contrast)
2. Strong prosody for Suno generation
3. Show-don't-tell storytelling
4. No lazy rhymes or forced phrasing
5. Consistent POV and tense
6. Appropriate section lengths for genre
7. Title placement in chorus (first or last line)
8. Hook/worthy title emphasis

---

## Example Output Structure

After completing the task, output:

```
Done. File saved to: `/home/tully/Sync/marty/[song_title].md`

Summary:
- Source: [filename]
- Genre: [selected]
- Title: [chosen title]
- Title exact match: [yes/no]
- Order: lyrics, prompt, album art
- Sections: [verse/chorus/bridge count]
```

---

## When to Use

This skill is applicable to execute the workflow or actions described in the overview.

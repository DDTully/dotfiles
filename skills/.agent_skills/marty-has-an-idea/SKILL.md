---
name: marty-has-an-idea
description: "Extract and document details from a product page or review URL. Ask the user what review tone to target: extremely positive, neutral, negative, or unhinged. Prefer the main product page and its review section, and always capture the full review text verbatim for downstream lyric writing. Fall back to the direct review URL if needed. Triggers: analyze this review, extract review details, document this review, save this review, marty has an idea"
risk: low
source: community
date_added: "2026-04-12"
---

# Marty Has an Idea

> Extract and document details from a product page or review URL, preserving full review text for later lyric writing.

---

## When to Use

This skill is applicable when the user requests:
- Analyzing a specific review
- Extracting product details from a product page or review page
- "Capture the main item name"
- "Save this review"
- "Document this review"
- Framing the extracted review as extremely positive, neutral, negative, or unhinged
- "marty has an idea"

**Trigger phrases:**
- "analyze this review"
- "extract review details"
- "capture the product"
- "save this review"
- "document this review"
- "marty has an idea"

---

## Workflow

```
Step 1: Ask review tone first
    ↓
Step 2: Ask for a product page, ASIN, or review URL if needed
    ↓
Step 3: Prefer the main product page and its review section
    ↓
Step 4: Extract product information and visible review snippets
    ↓
Step 5: Find other reviews and linked review pages
    ↓
Step 6: Write markdown file with shortened name
```

---

## Step 1: Clarify Tone First

Before fetching, ask the user:

1. **Review Tone**: Extremely Positive, Neutral, Negative, or Unhinged?
2. **Purpose**: Entertainment/Fun, Research/Analysis, Content Creation, or Other?
3. **Source Type**: Product page, ASIN, or review URL?
4. **Output Format**: Compact Report, Detailed Report, or Just the main review?

Use the `question` tool if needed.

If the user already provided a source URL, keep it and continue.

---

## Step 2: Request URL

If no source was provided, ask the user:

> Please provide the product page, ASIN, or review URL you'd like me to analyze.

---

## Step 3: Fetch the Review Page

Use `webfetch` to retrieve the main product page first when possible:

```
webfetch(url: [product page or ASIN URL], format: markdown)
```

If the user only provides a direct customer-review URL and it is blocked, derive the ASIN from the URL and fetch the main product page instead.

---

## Step 4: Extract Information

From the fetched content, capture the full text verbatim whenever it is visible. Do not paraphrase or reduce a review to a short snippet if the complete text is available.

Capture:
| Field | Description |
|-------|-------------|
| Product Name | Full product name (main item title) |
| Product Details | Size, quantity, variant, specifications |
| Brand | Manufacturer/seller |
| Review Tone | User-selected tone for the report |
| Rating | Product star rating |
| Review Count | Number of reviews |
| Warning | Any safety warnings or important notices |
| Review Snippet | The main review text or best visible snippet matching the selected tone |
| Full Review Text | The complete review text copied verbatim, if visible |
| Review Author | Reviewer name or "Amazon Customer" |
| Review Date | When review was posted |
| Review Rating | Stars given by reviewer |
| Helpful Votes | Number of "helpful" votes |

---

## Step 5: Find Other Reviews

Scan the product page for other reviews with different sentiment that may be interesting:

- Notable positive reviews
- Other reviews with different complaints
- Funny or sarcastic reviews
- Updated reviews (with "UPDATE:")
- Review snippets shown on the product page
- Linked review pages reachable from the review summary

If the user selected a tone, prioritize full review text that matches that tone. Keep the exact wording whenever it is visible, because the content may be reused later for lyric writing.

---

## Step 6: Write Markdown File

### File Naming Convention

Create a shortened product name:
- Remove brand names, sizes, quantities
- Remove special characters
- Use underscores for spaces
--Maximum 50 characters

Examples:
- "OXO_Good_Grips_Upright_Sweep_Set"
- "Happy_Belly_Cheese_Crackers"
- "Westmark_Melon_Slicer"

```
[shortened_name].md
```

### Directory

Write to `/home/tully/Sync/marty/`

### Template

```markdown
# [Product Name]

**Source:** [URL]  
**Extracted:** [Date]  
**Review Tone:** [Extremely Positive / Neutral / Negative / Unhinged]  
**Overall Rating:** [X.X]/5 stars ([Y] reviews)

---

## Product Details

| Field | Value |
|-------|-------|
| Name | [Product Name] |
| Brand | [Brand] |
| Details | [Size, quantity, variant] |
| ASIN | [ASIN if available] |
| Review Tone | [Selected tone] |
| Rating | [X.X]/5 stars |
| Reviews | [Count] |

---

## Warnings

[Any warnings from the product page]

---

## Primary Review

> **[Review Rating] stars** - *[Review Title]*

*[Author]* - *[Date]*  
*[Full Review Content, verbatim]*

*Helpful: [X] people found this helpful*

---

## Other Reviews

### Positive Notes
- [Notable positive review 1]
- [Notable positive review 2]

### Other Notes
- [Other review 1]
- [Other review 2]

### Updates
- [Any updated reviews]

---

## Source

- URL: [Original URL]
- Platform: [Amazon/Walmart/Other]
- Selected tone: [Extremely Positive / Neutral / Negative / Unhinged]

---

*Extracted: [Timestamp]*
```

---

## Example Output Structure

After completing the task, output:

```
Done. File saved to: `/home/tully/Sync/marty/[shortened_product_name].md`

Summary:
- Product: [Full name]
- Rating: [X.X]/5 stars
- Reviews captured: [N]
- Key takeaway: [Brief description]
```

---

## When to Use

This skill is applicable to execute the workflow or actions described in the overview.

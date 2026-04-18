---
name: marty-has-an-idea
description: "Extract and document details from a product page, review URL, or product information request. Ask one clarifying question at a time, then collect the requested data from the main product page when possible. For review mode, ask which review tone to target: extremely positive, neutral, negative, or unhinged. For product information mode, collect all available product fields by default. Preserve full review text or product detail text verbatim for downstream lyric writing or reference. Triggers: analyze this review, extract review details, extract product details, collect product information, document this review, save this review, marty has an idea"
risk: low
source: community
date_added: "2026-04-12"
---

# Marty Has an Idea

> Extract and document details from a product page, review URL, or product information request, preserving verbatim source text for later use.

---

## When to Use

This skill is applicable when the user requests:
- Analyzing a specific review
- Extracting product details from a product page or review page
- Collecting specific product information from a product page
- Capturing the main item name or key specs
- Saving or documenting a review
- Saving or documenting product information
- Framing extracted content as extremely positive, neutral, negative, or unhinged
- "marty has an idea"

**Trigger phrases:**
- "analyze this review"
- "extract review details"
- "extract product details"
- "collect product information"
- "capture the product"
- "save this review"
- "document this review"
- "document product info"
- "marty has an idea"

---

## Workflow

```
Step 1: Ask one clarifying question at a time
    ↓
Step 2: If needed, ask for the source URL / ASIN / product page
    ↓
Step 3: Fetch the main product page when possible
    ↓
Step 4: Extract the requested information verbatim
    ↓
Step 5: Add supporting details only after the primary answer is captured
    ↓
Step 6: Write markdown file with shortened name
```

---

## Step 1: Clarify Intent First

Never bundle clarifying questions. Ask the smallest missing piece of information, wait for the reply, then continue.

Suggested order:
1. If the user did not already provide a source, ask for the product page, ASIN, or review URL.
2. If the source is still ambiguous, ask exactly one mode question: "Review Details or Product Information?"
3. If Review Details is chosen, ask for the review tone: Extremely Positive, Neutral, Negative, or Unhinged.
4. Only ask for purpose or output-format details if the user explicitly wants them.

If the user already provided a source URL, keep it and continue. If the user already stated the mode, do not ask it again.

### If Review Details is chosen
Ask:
- **Review Tone**: Extremely Positive, Neutral, Negative, or Unhinged?

### If Product Information is chosen
Default to collecting everything visible, including name, brand, model, size, quantity, variant, specs, materials, ingredients, dimensions, features, warnings, compatibility, warranty, price, and availability.

Only ask for a narrower focus if the user explicitly requests less than a full capture.

---

## Step 2: Request URL

If no source was provided, ask the user:

> Please provide the product page, ASIN, or review URL you'd like me to analyze.

---

## Step 3: Fetch the Page

Use `webfetch` to retrieve the main product page first when possible:

```
webfetch(url: [product page or ASIN URL], format: markdown)
```

If the user only provides a direct customer-review URL and it is blocked, derive the ASIN from the URL and fetch the main product page instead.

Prefer the main product page because it usually contains the richest product details, plus reviews and specs.

---

## Step 4: Extract Information

From the fetched content, capture the full text verbatim whenever it is visible. Do not paraphrase or reduce text to a short snippet if the complete text is available.

### Review Details Mode
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

### Product Information Mode
Capture:

| Field | Description |
|-------|-------------|
| Product Name | Full product name (main item title) |
| Brand | Manufacturer/seller |
| Model / SKU / ASIN | Any visible identifiers |
| Category | Visible product category or type |
| Priority Fields | All available product fields by default, or any narrower focus the user explicitly requested |
| Product Details | Size, quantity, variant, materials, ingredients, dimensions, specs |
| Feature Bullets | Visible feature list from the page |
| Warnings | Safety notices or important notices |
| Compatibility | Device/material/system compatibility if visible |
| Warranty | Warranty or guarantee details if visible |
| Price / Availability | If visible on the page |
| Rating | Product star rating |
| Review Count | Number of reviews |
| Full Product Text | Full product description or detail text copied verbatim, if visible |

---

## Step 5: Find Supporting Details

### Review Details Mode
Scan the product page for other reviews with different sentiment that may be interesting:

- Notable positive reviews
- Other reviews with different complaints
- Funny or sarcastic reviews
- Updated reviews (with "UPDATE:")
- Review snippets shown on the product page
- Linked review pages reachable from the review summary

If the user selected a tone, prioritize full review text that matches that tone. Keep the exact wording whenever it is visible.

### Product Information Mode
Scan for additional product information and capture everything visible that helps complete the product profile:

- Spec tables
- Bullet-point features
- Variants or size options
- FAQs
- Compatibility notes
- Warning labels or notices
- Material or ingredient lists
- Warranty/guarantee text
- Related product descriptions if they clarify the item
- Price, availability, and platform metadata when visible

Capture all visible product details by default, not just a narrow subset.

---

## Step 6: Write Markdown File

### File Naming Convention

Create a shortened product name:
- Remove brand names, sizes, quantities
- Remove special characters
- Use underscores for spaces
- Maximum 50 characters

Examples:
- `OXO_Good_Grips_Upright_Sweep_Set`
- `Happy_Belly_Cheese_Crackers`
- `Westmark_Melon_Slicer`

```
[shortened_name].md
```

### Directory

Write to `/home/tully/Sync/marty/`

### Template: Review Details Mode

```markdown
# [Product Name]

**Source:** [URL]  
**Extracted:** [Date]  
**Mode:** Review Details  
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

### Template: Product Information Mode

```markdown
# [Product Name]

**Source:** [URL]  
**Extracted:** [Date]  
**Mode:** Product Information  
**Priority Fields:** All available product fields

---

## Product Details

| Field | Value |
|-------|-------|
| Name | [Product Name] |
| Brand | [Brand] |
| Model / SKU / ASIN | [Visible identifiers] |
| Category | [Category] |
| Details | [Size, quantity, variant, materials, ingredients, dimensions] |
| Feature Bullets | [Visible feature bullets] |
| Compatibility | [Visible compatibility notes] |
| Warranty | [Visible warranty or guarantee] |
| Warnings | [Warnings or notices] |
| Price / Availability | [If visible] |
| Rating | [X.X]/5 stars |
| Reviews | [Count] |

---

## Requested Product Info

- [Requested field 1]: [Value]
- [Requested field 2]: [Value]
- [Requested field 3]: [Value]

---

## Product Description

*[Full product description or detail text, verbatim when visible]*

---

## Source

- URL: [Original URL]
- Platform: [Amazon/Walmart/Other]
- Selected fields: All available product fields

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
- Mode: [Review Details / Product Information]
- Rating: [X.X]/5 stars
- Captured: [N]
- Key takeaway: [Brief description]
```

---

## When to Use

This skill is applicable to execute the workflow or actions described in the overview.

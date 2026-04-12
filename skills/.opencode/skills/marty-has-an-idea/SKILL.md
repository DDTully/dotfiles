---
name: marty-has-an-idea
description: "Extract and document details from a negative review URL. Captures product name, details, warnings, the main review, and other reviews. Triggers: analyze this review, extract review details, document this review, save this negative review, marty has an idea"
risk: low
source: community
date_added: "2026-04-12"
---

# Marty Has an Idea

> Extract and document details from a negative product review URL.

---

## When to Use

This skill is applicable when the user requests:
- Analyzing a specific negative review
- Extracting product details from a review page
- "Capture the main item name"
- "Save this review"
- "Document this negative review"
- "marty has an idea"

**Trigger phrases:**
- "analyze this review"
- "extract review details"
- "capture the product"
- "save this negative review"
- "document this review"
- "marty has an idea"

---

## Workflow

```
Step 1: Ask for review URL (required input)
    ↓
Step 2: Fetch the review page
    ↓
Step 3: Extract product information
    ↓
Step 4: Find other reviews on the page
    ↓
Step 5: Write markdown file with shortened name
```

---

## Step 1: Request URL

This skill **requires** a URL to a product review page. Ask the user:

> Please provide the URL to the negative review you'd like me to analyze.

Use the `question` tool if needed.

---

## Step 2: Fetch the Review Page

Use `webfetch` to retrieve the review page content:

```
webfetch(url: [provided URL], format: markdown)
```

---

## Step 3: Extract Information

From the fetched content, capture:

| Field | Description |
|-------|-------------|
| Product Name | Full product name (main item title) |
| Product Details | Size, quantity, variant, specifications |
| Brand | Manufacturer/seller |
| Rating | Product star rating |
| Review Count | Number of reviews |
| Warning | Any safety warnings or important notices |
| Negative Review | The main negative review text |
| Review Author | Reviewer name or "Amazon Customer" |
| Review Date | When review was posted |
| Review Rating | Stars given by reviewer |
| Helpful Votes | Number of "helpful" votes |

---

## Step 4: Find Other Reviews

Scan the page for other reviews (both positive and negative) that may be interesting:

- Notable positive reviews
- Other negative reviews with different complaints
- Funny or sarcastic reviews
- Updated reviews (with "UPDATE:")

---

## Step 5: Write Markdown File

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
**Overall Rating:** [X.X]/5 stars ([Y] reviews)

---

## Product Details

| Field | Value |
|-------|-------|
| Name | [Product Name] |
| Brand | [Brand] |
| Details | [Size, quantity, variant] |
| ASIN | [ASIN if available] |
| Rating | [X.X]/5 stars |
| Reviews | [Count] |

---

## Warnings

[Any warnings from the product page]

---

## Main Review

> **[Review Rating] stars** - *[Review Title]*

*[Author]* - *[Date]*  
*[Review Content]*

*Helpful: [X] people found this helpful*

---

## Other Reviews

### Positive Notes
- [Notable positive review 1]
- [Notable positive review 2]

### Other Complaints
- [Other negative review 1]
- [Other negative review 2]

### Updates
- [Any updated reviews]

---

## Source

- URL: [Original URL]
- Platform: [Amazon/Walmart/Other]

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
- Key complaint: [Brief description]
```

---

## When to Use

This skill is applicable to execute the workflow or actions described in the overview.
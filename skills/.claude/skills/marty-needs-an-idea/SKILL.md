---
name: marty-needs-an-idea
description: "Find mundane products with oddly specific review comments on Amazon, Walmart, and other retail sites. Ask the user what review tone to target: extremely positive, neutral, negative, or unhinged. Write findings to a timestamped markdown file. Triggers: find oddly specific reviews, funny reviews, mundane product reviews, worst product reviews, hilarious amazon reviews, walmart terrible reviews"
risk: low
source: community
date_added: "2026-04-12"
---

# Marty Needs an Idea

> Find and document oddly specific reviews for mundane products.

---

## When to Use

This skill is applicable when the user requests:

- Finding funny/oddly specific product reviews
- Searching for the best, worst, neutral, or unhinged Amazon/Walmart reviews
- Content creation: finding amusing customer praise or complaints
- "mundane products with oddly specific review comments"
- Any variation of finding bizarre product reviews

**Trigger phrases:**

- "oddly specific"
- "find mundane products"
- "negative review"
- "worst purchase"
- "hilarious reviews"
- "funny amazon reviews"
- "walmart reviews"
- "marty needs an idea"

---

## Workflow

```
    Step 1: Ask review tone first
    ↓
    Step 2: Build a broad candidate pool across categories, platforms, and query shapes
    ↓
Step 3: Exclude previously covered items and same-category repeats
    ↓
Step 4: Open the main product page and use its visible review summaries/snippets
    ↓
Step 5: Rank for novelty, specificity, and category spread
    ↓
Step 6: Write timestamped markdown file
    ↓
Step 7: Format with prettier (if available)
```

---

## Step 1: Clarify Tone First

Before searching, ask the user:

1. **Review Tone**: Extremely Positive, Neutral, Negative, or Unhinged?
2. **Purpose**: Entertainment/Fun, Research/Analysis, Content Creation, or Other?
3. **Categories**: Household Basics, Personal Care, Office/School Supplies, Any Mundane Products, or Specific Category?
4. **Specific Product Name**: A product name to target, or leave it open-ended.
5. **Output Format**: List with Links, Detailed Report, Just Examples, or Search Strategy?

Use the `question` tool to get these answers, or proceed with reasonable defaults if not specified.

---

## Step 2: Search Strategy

### Anti-Repeat Rules

Before accepting any result, prefer items that are different from recent picks in at least two ways:

- Product category
- Platform
- Price band or use case
- Review angle or complaint type

If the user did not provide exclusions, still avoid clustering on the same few evergreen products. Keep a candidate bank of at least 8 to 12 results, then select the most varied final set.

### Primary Search Queries

Run multiple web searches in parallel with variations, using different category buckets and intent shapes:

```
Query variations:
- "[category] oddly specific review amazon"
- "[category] oddly specific review walmart"
- "[category] funny review specific complaint"
- "[category] best ever review amazon"
- "[category] worst purchase review amazon"
- "[category] neutral review oddly specific"
- "[category] unhinged review mundane product"
- "[category] review snippet"
- "site:amazon.com [category] reviews"
- "site:walmart.com [category] reviews"
```

### Pattern-Based Searches

Also search for specific phrases that indicate oddly specific reviews:

- "tastes like" + "negative"
- "looks like" + "terrible"
- "waste of money" + specific producttype
- "save yourself" + "use a [alternative]"
- "I have tasted better" + "sawdust/cardboard"

### Category Rotation

Spread searches across a rotating set of mundane categories so the output does not keep repeating the same items:

- Pantry and snacks
- Cleaning supplies
- Bathroom basics
- Office and school supplies
- Small kitchen tools
- Laundry and storage
- Personal care and grooming
- Pet supplies
- Automotive accessories
- Gardening and household hardware

### Review Tone Targets

Adjust search terms based on the user's chosen tone:

- **Extremely Positive**: add phrases like "love this", "best ever", "changed my life", "would buy again"
- **Neutral**: add phrases like "does the job", "as expected", "nothing special", "works fine"
- **Negative**: add phrases like "waste of money", "cardboard", "broke immediately", "save yourself"
- **Unhinged**: add phrases like "I did not expect", "absolutely not", "what is happening", "this product has seen things"

---

## Step 3: Exclude Previously Covered Items

If the user provides a list of already-covered products or links:

- Parse the exclusions
- Skip any search results matching those ASINs/product IDs
- Note exclusions in the final report

---

## Step 4: Compile Findings

For each finding, capture:

| Field        | Description                                       |
| ------------ | ------------------------------------------------- |
| Product Name | Full product name                                 |
| Platform     | Amazon/Walmart/Other                              |
| Product Page | Main product page URL                             |
| Link         | Direct product URL                                |
| Review Quote | The oddly specific review text or visible snippet |
| Specifics    | Details that make it oddly specific               |
| Rating       | Product rating and review count                   |
| Helpfulness  | Number of "helpful" votes                         |

Every finding must include at least one clickable product link and at least one clickable source URL. Never leave placeholders like "Amazon listing commonly cited" in the final report.

If the exact product page is unavailable or discontinued, use the best available clickable fallback and label it clearly, such as:

- official product page
- Amazon/Walmart search results page for the product
- archived page or article that quotes the page

### Categories to Find

1. **Food Products** with vivid taste comparisons or praise
2. **Kitchen Gadgets** that fail spectacularly
3. **Cleaning Tools** with specific complaints
4. **Small Appliances** with bizarre failures
5. **Store-brand Products** that disappoint
6. **Personal care items** with unusually exact reactions
7. **Office and school supplies** with weirdly detailed failures
8. **Pet products** with surprisingly specific praise or complaints

### Common Themes to Look For

- Vivid sensory comparisons (tastes like X)
- Hyperbolic specificity (exact measurements, times, percentages)
- Social impact focus (affects co-workers, family)
- Inefficiency comedy (worse than manual method)
- Design flaws with exact consequences
- Product-page review snippets that surface the complaint without needing a locked review URL
- Rare, specific use cases that are unlikely to overlap with the last run

### Selection Rules

When multiple candidates are available, prefer the set that:

- Covers more categories
- Mixes platforms instead of using only one retailer
- Includes at least one non-obvious product
- Avoids returning the same flagship examples unless the user explicitly requested them

---

## Step 5: Write Markdown File

### File Naming Convention

```
YYYY-MM-DD_HH-MM-SS_oddly_specific_reviews.md
```

Generated using:

```bash
date +"%Y-%m-%d_%H-%M-%S"
```

### Directory

Write to `/home/tully/Sync/marty/` (working directory)

### Template

```markdown
# Detailed Report: Oddly Specific Reviews for Mundane Products

**Date Compiled:** [Timestamp]  
**Purpose:** [User's stated purpose]
**Review Tone:** [Extremely Positive / Neutral / Negative / Unhinged]
**Requested Product Name:** [Exact product name, if provided]

---

## Executive Summary

[Brief description of findings]

---

## Product Links & Findings

### 1. [Category Name]

#### [Product Name]

- [Platform] Product Page: [Main page URL]
- [Platform] Direct Link: [Direct URL]
- Source URLs:
  - [Search result or article URL 1]
  - [Search result or article URL 2]
- Review: "_[Review quote]_"
- Specifics: [What makes it oddly specific]
- Rating: [X.X/5 stars] ([Y] reviews)

[... additional products ...]

---

## Analysis of Patterns

### Common Themes in Oddly Specific Reviews:

1. [Theme 1]
2. [Theme 2]
   [...]

### Product Categories Most Prone to These Reviews:

1. [Category 1]
2. [Category 2]
   [...]

---

## Recommendations for Content Use

### Suggested Formats:

- **Social media series:** "Most Oddly Specific [Platform] Review of the Week"
- **Video compilation:** Dramatic readings with product demonstrations
- **Article:** "[When Mundane Products Inspire Extreme Opinions]"
- **Podcast segment:** Analyzing why certain products inspire such vivid reactions

---

## Sources

- Search terms used: [list]
- Platforms: [list]
- Date range: [range]
- Product/source URLs: [list the actual clickable URLs used for each finding]
- Hard requirement: every final report entry must include live clickable links, even when the product page is only available as a search result or archive.

---

_Report compiled using web search methodology - [Date]_
```

---

## Step 6: Format with Prettier

If prettier is installed, format the markdown:

```bash
prettier --write /home/tully/Sync/marty/[filename].md
```

If prettier is not available, skip this step - the markdown is still valid.

---

## Example Output Structure

After completing the task, output:

```
Done. File saved to: `/home/tully/Sync/marty/[timestamp]_oddly_specific_reviews.md`
```

Include a brief summary of:

- Number of products found
- Most notable finding
- Categories covered

---

## When to Use

This skill is applicable to execute the workflow or actions described in the overview.
description: "Find mundane products with oddly specific review comments on Amazon, Walmart, and other retail sites. Prefer main product pages and their review summaries/snippets over direct review URLs. Use category rotation and anti-repeat selection to surface fresh ideas. Write findings to a timestamped markdown file. Triggers: find oddly specific reviews, funny negative reviews, mundane product reviews, worst product reviews, hilarious amazon reviews, walmart terrible reviews"

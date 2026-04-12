---
name: marty-needs-an-idea
description: "Find mundane products with oddly specific negative review comments on Amazon, Walmart, and other retail sites. Write findings to a timestamped markdown file. Triggers: find oddly specific reviews, funny negative reviews, mundane product reviews, worst product reviews, hilarious amazon reviews, walmart terrible reviews"
risk: low
source: community
date_added: "2026-04-12"
---

# Marty Needs an Idea

> Find and document oddly specific negative reviews for mundane products.

---

## When to Use

This skill is applicable when the user requests:
- Finding funny/oddly specific negative product reviews
- Searching for the worst Amazon/Walmart reviews
- Content creation: finding amusing customer complaints
- "mundane products with oddly specific negative review comments"
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
Step 1: Ask user intent
    ↓
Step 2: Web search for oddly specific negative reviews
    ↓
Step 3: Exclude previously covered items (if any provided)
    ↓
Step 4: Compile findings with links
    ↓
Step 5: Write timestamped markdown file
    ↓
Step 6: Format with prettier (if available)
```

---

## Step 1: Clarify Intent

Before searching, ask the user:

1. **Purpose**: Entertainment/Fun, Research/Analysis, Content Creation, or Other?
2. **Categories**: Household Basics, Personal Care, Office/School Supplies, Any Mundane Products, or Specific Category?
3. **Output Format**: List with Links, Detailed Report, Just Examples, or Search Strategy?

Use the `question` tool to get these answers, or proceed with reasonable defaults if not specified.

---

## Step 2: Search Strategy

### Primary Search Queries

Run multiple web searches in parallel with variations:

```
Query variations:
- "oddly specific negative review amazon mundane product"
- "worst purchase ever amazon review funny"
- "tastes like looks like negative review amazon"
- "mundane product oddly specific negative review walmart"
- "hilarious amazon reviews 1 star funny"
- "worst product everwalmart review"
- "funny negative review specific complaint"
```

### Pattern-Based Searches

Also search for specific phrases that indicate oddly specific reviews:
- "tastes like" + "negative"
- "looks like" + "terrible"
- "waste of money" + specific producttype
- "save yourself" + "use a [alternative]"
- "I have tasted better" + "sawdust/cardboard"

---

## Step 3: Exclude Previously Covered Items

If the user provides a list of already-covered products or links:
- Parse the exclusions
- Skip any search results matching those ASINs/product IDs
- Note exclusions in the final report

---

## Step 4: Compile Findings

For each finding, capture:

| Field | Description |
|-------|-------------|
| Product Name | Full product name |
| Platform | Amazon/Walmart/Other |
| Link | Direct product URL |
| Review Quote | The oddly specific negative review text |
| Specifics | Details that make it oddly specific |
| Rating | Product rating and review count |
| Helpfulness | Number of "helpful" votes |

### Categories to Find

1. **Food Products** with vivid taste comparisons (cardboard, soap, sawdust, etc.)
2. **Kitchen Gadgets** that fail spectacularly
3. **Cleaning Tools** with specific complaints
4. **Small Appliances** with bizarre failures
5. **Store-brand Products** that disappoint

### Common Themes to Look For

- Vivid sensory comparisons (tastes like X)
- Hyperbolic specificity (exact measurements, times, percentages)
- Social impact focus (affects co-workers, family)
- Inefficiency comedy (worse than manual method)
- Design flaws with exact consequences

---

## Step 5: Write Markdown File

### File Naming Convention

```
YYYY-MM-DD_HH-MM-SS_oddly_specific_negative_reviews.md
```

Generated using:
```bash
date +"%Y-%m-%d_%H-%M-%S"
```

### Directory

Write to `/home/tully/Sync/marty/` (working directory)

### Template

```markdown
# Detailed Report: Oddly Specific Negative Reviews for Mundane Products

**Date Compiled:** [Timestamp]  
**Purpose:** [User's stated purpose]

---

## Executive Summary

[Brief description of findings]

---

## Product Links & Findings

### 1. [Category Name]

#### [Product Name]
- [Platform] Link: [URL]
- Review: "*[Review quote]*"
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
- **Article:** "[When Mundane Products Fail Spectacularly]"
- **Podcast segment:** Analyzing why certain products inspire such vivid criticism

---

## Sources

- Search terms used: [list]
- Platforms: [list]
- Date range: [range]

---

*Report compiled using web search methodology - [Date]*
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
Done. File saved to: `/home/tully/Sync/marty/[timestamp]_oddly_specific_negative_reviews.md`
```

Include a brief summary of:
- Number of products found
- Most notable finding
- Categories covered

---

## When to Use

This skill is applicable to execute the workflow or actions described in the overview.
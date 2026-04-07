---
name: kcs-article-writing
description: "Writing KCS (Knowledge-Centered Service) v6 compliant knowledge articles. Use when creating, editing, reviewing, or auditing knowledge base articles following the KCS v6 content standard from the Consortium for Service Innovation."
category: workflow-bundle
risk: safe
source: personal
date_added: "2026-04-07"
---

# KCS v6 Article Writing

## Overview

KCS (Knowledge-Centered Service) v6 is a methodology for integrating knowledge capture, validation, improvement, and reuse into the support workflow. This skill covers writing and reviewing knowledge articles compliant with the KCS v6 content standard.

KCS articles represent the collective experience of an organization — captured in the moment, written from the requestor's perspective, and refined through reuse.

> Source: KCS® methodology is a registered service mark of the Consortium for Service Innovation.
> Reference: https://library.serviceinnovation.org/KCS

---

## When to Use This Skill

Use this skill when:

- Writing a new KCS knowledge article from scratch
- Editing or improving an existing article for KCS compliance
- Reviewing an article against the content standard
- Auditing a knowledge base for article quality
- Helping a knowledge worker understand what makes a good article
- Drafting article templates or content standard documentation

---

## Core KCS Principles (Non-Negotiable)

All article writing must reflect these four KCS principles:

1. **Abundance** — Knowledge shared freely creates more value. Do not hoard knowledge; capture everything worth capturing.
2. **Create Value** — Articles should serve the requestor. Value is defined by the customer, not the author.
3. **Demand Driven** — Create and improve articles in response to actual demand. Do not pre-author content that has not been requested.
4. **Trust** — Trust knowledge workers to capture and improve articles. Do not over-engineer review gates.

---

## The KCS Article: Core Concepts

KCS articles capture the reusable part of a support interaction. They are **not** case notes or incident records — those belong in the system of record. Articles contain only reusable knowledge: no customer names, contact info, entitlements, or case-specific details.

Articles are modular. Aim for **one page or less**. A single issue may reference multiple articles. Link to related articles rather than duplicating content.

KCS articles serve multiple content types:
- Simple Q&A / how-to
- Technical issues (simple and complex)
- Configuration issues
- Interoperability issues
- Defects
- Diagnostic procedures
- Process instructions

---

## Article Structure: The Four Required Fields

Every KCS article uses the same simple structure regardless of content type. Resist adding extra fields or templates — keep it simple and iterate based on experience.

### 1. Issue (Required)

The issue is written **in the requestor's words and phrases**. It describes what they are trying to do, what is not working, or what they are looking for.

**Rules:**
- Write from the requestor's perspective, not the responder's
- Use the customer's language and terminology
- Do not include environment details in the issue statement
- Avoid compound statements — one issue per statement
- Write in present tense
- Use explicit subjects ("Documents do not print" not "Won't print")
- Remove filler phrases: "I want to", "The customer is trying to", "The customer is getting"

**Error message format:**
```
Error: "<exact error message text>"
```

**Ordering multiple issue statements** (least specific to most specific):
```
Cannot print a file
Error printing file to network printer
Error: "Invalid page layout for this printer driver. (24301)"
```

**Good:**
```
Issue: Error: "Comu.dll triggered an error in an invalid page"
```

**Bad:**
```
Issue: 3Com NIC X1000 has the following error message: Comu.dll triggered an error in an invalid page in the module Comu.dll.
```

---

### 2. Environment (Required)

Describes the product(s), platform(s), versions, or business process context relevant to the issue. The environment remains the same after the issue is resolved.

**Rules:**
- Be precise — use standard product names, versions, and formats
- Do not put multiple environments in a single statement
- Add new environment statements to existing articles as variants are discovered
- Do not confuse a change in environment with the cause
- Format: `<Vendor> <Product>, version <Version Number>`

**Good:**
```
Environment:
- OS X Yosemite version 10.10.5
- Microsoft Office 2016
- MacBook Air
```

**Changes in environment** (record what changed, not what caused it):
```
Change: Upgrade from Release 3.2 to 4.0
```

**Bad:**
```
Change: It worked before we replaced an XBTVA with an XBTVM
```

---

### 3. Resolution (Required unless WIP)

The answer, fix, or steps taken to resolve the issue.

**Rules:**
- Write as a present-tense list of commands, as if reading steps aloud
- Number multi-step procedures
- One fix per statement; use tabs for readability
- Do not include "if-then" logic — that indicates two separate articles are needed
- Label workarounds explicitly: `Workaround: ...`
- Use hyperlinks to maintained references where helpful
- If the resolution requires elevated access or special tools the requestor cannot use, state: "Contact your support center for assistance" and put the restricted steps in an **Internal Resolution** field not visible to the requestor

**Good:**
```
Resolution:
1. Open the application settings
2. Navigate to Print > Advanced
3. Uncheck "Enable background printing"
4. Click Save and retry
```

**Bad:**
```
If the error occurs on startup, try restarting the service, but if that doesn't work you may need to reinstall the driver.
```

---

### 4. Cause (Optional)

The underlying root cause of the issue. Not all articles need a cause.

**Rules:**
- Omit for simple Q&A and how-to articles
- Include when it helps distinguish between two articles with the same issue but different causes
- Only one cause per article — if there are multiple causes, split into multiple articles
- Consider adding a **Cause Test** field to describe how to validate the cause before applying the resolution

**Good:**
```
Cause: Printer driver version 4.1 does not support duplex printing on this hardware model.
Cause Test: Check driver version in Device Manager > Printers.
```

---

## Metadata: Article State

Every article has three state attributes that control its lifecycle.

### Article Confidence

| State | Meaning |
|---|---|
| **WIP (Work in Progress)** | Issue captured, resolution not yet known. Temporary — delete or promote when the case closes. |
| **Not Validated** | Resolution exists but confidence is low, OR created by a KCS Candidate not yet licensed to validate. |
| **Validated** | Resolution is confirmed accurate and the article complies with the content standard. |
| **Archived** | No longer relevant. Removed from search but preserved for linked incident history. |

**WIP guidance:** WIPs prevent duplicate work on open issues. When a case closes, either promote the WIP to Not Validated/Validated, or delete it if nothing reusable was captured.

**Not Validated is okay.** It captures collective experience. Reuse drives review — do not review Not Validated articles in the absence of demand.

---

### Article Audience

| Audience | Who Sees It |
|---|---|
| **Internal** | Employees only |
| **Within a Domain** | A specific product group, department, or topic domain |
| **Partners** | Trusted non-employees acting as an extension of the org |
| **Customers** | Registered users of products or services |
| **Public** | Anyone; often indexed by search engines |

**Target state for mature KCS:** 90% of articles available externally at or before case closure. Do not block external visibility by requiring internal reuse thresholds as a permanent gate.

---

### Article Governance

| Governance | Who Can Modify |
|---|---|
| **Experience Based** | Any licensed KCS user (based on their license level) |
| **Compliance Based** | Restricted to designated individuals; used for policy, legal, or regulatory content |

---

## KCS Roles and What They Can Do

| Role | Can Create | Can Validate | Can Publish Externally |
|---|---|---|---|
| **KCS Candidate** | Not Validated only | No | No |
| **KCS Contributor** | Not Validated, Validated | Yes | No |
| **KCS Publisher** | Not Validated, Validated | Yes | Yes |
| **KCS Coach / KDE** | All | Yes | Yes |

---

## Writing Style Guide

### Complete Thoughts, Not Complete Sentences

KCS articles prioritize findability and usability over grammar perfection. Incomplete sentences are acceptable if the meaning is clear.

- **Good:** `Documents do not print to network printer`
- **Avoid:** `The customer has reported that they are unable to print their documents to the network printer`

### Verb Tense

- **Issue field:** Present tense describing the current problem state
- **Resolution field:** Present tense imperative — tell the reader what to do, not what you did

**Good:** `Open the settings panel and select Save`
**Bad:** `I opened the settings panel and selected Save`

### Vocabulary

- Use terms familiar to the **intended audience**, not internal jargon
- Use standard product and platform names consistently
- Support trademark protection by using exact vendor names

### International English

When articles may be translated or read by non-native speakers:
- Prefer short sentences
- Avoid idioms and colloquialisms
- Use consistent terminology throughout
- Prefer active voice

---

## What NOT to Include in an Article

The following belong in the system of record (case/incident), not in the knowledge article:

- Customer or company names
- Contact information
- Account or entitlement details
- Case-specific timestamps or ticket numbers
- Personally identifiable information
- Anything that does not generalize beyond this one requestor

---

## Article Quality Checklist

Use this checklist when reviewing or writing an article:

**Issue field**
- [ ] Written in the requestor's words and context
- [ ] No environment details embedded in the issue
- [ ] Present tense, explicit subject
- [ ] No filler phrases ("customer is trying to", etc.)
- [ ] Error messages formatted as `Error: "<text>"`
- [ ] Multiple issue statements ordered generic → specific

**Environment field**
- [ ] Uses standard product/version naming
- [ ] Each environment statement is distinct
- [ ] Changes in environment noted separately from causes
- [ ] Precise enough to distinguish from similar articles

**Resolution field**
- [ ] Written in present tense as actionable steps
- [ ] Multi-step procedures are numbered
- [ ] No if-then branching (split into separate articles if needed)
- [ ] Workarounds labeled explicitly
- [ ] Internal steps hidden from external audience if needed

**Cause field (if present)**
- [ ] Single cause only
- [ ] Cause is distinct from the environment change
- [ ] Cause Test included if helpful

**Article State**
- [ ] Confidence set appropriately (WIP / Not Validated / Validated)
- [ ] Audience set to the broadest appropriate level
- [ ] Governance set (Experience Based vs. Compliance Based)
- [ ] No customer-specific information present

**Overall**
- [ ] One page or less (link to more detail rather than inline it)
- [ ] No duplicate content — links to existing articles where possible
- [ ] Reusable by the intended audience without this customer's context

---

## Good vs. Bad Article Examples

### Bad Article

```
Issue: Customer John at ACME Corp called in on 3/15. He's using some version of
Windows and Office and is getting a printing error. We tried a few things.

Environment: Windows, Office

Resolution: We had him uncheck background printing in the advanced settings and
that fixed it for him. If that doesn't work try reinstalling the driver.

Cause: Not sure, maybe driver issue
```

Problems: Customer-specific data, vague environment, past tense, if-then resolution, weak cause.

---

### Good Article

```
Issue: Error: "Printer not responding" when printing from Office applications

Environment:
- Microsoft Office 2016
- Windows 10 version 21H2
- HP LaserJet Pro M404

Resolution:
1. Open Word or Excel
2. Go to File > Options > Advanced
3. Under Print, uncheck "Print in background"
4. Click OK
5. Retry the print job

Cause: Background printing conflicts with HP LaserJet Pro M404 driver version 3.x.
Cause Test: Check driver version in Device Manager > Printers > Properties > Driver tab.

Confidence: Validated
Audience: Customers
Governance: Experience Based
```

---

## Workflow: Capture in the Moment

KCS articles are captured **during** the support interaction, not after. The knowledge worker:

1. **Searches first** before creating a new article (searching is creating — if no article exists, the search terms become the seed for the new article)
2. **Creates a WIP** at the first search if no article is found
3. **Captures the issue in the requestor's context** as they understand it
4. **Adds resolution** as the issue is resolved
5. **Sets confidence and audience** appropriate to their license level
6. **Links the article** to the incident/case in the system of record

---

## Common Mistakes and How to Fix Them

| Mistake | Fix |
|---|---|
| Issue written from the responder's POV | Rewrite using the requestor's words |
| Environment terms embedded in the issue | Move to the Environment field |
| Past tense resolution | Rewrite as present tense commands |
| If-then branching in the resolution | Split into two articles differentiated by environment |
| Multiple causes in one article | Split into separate articles |
| Customer name or case number in article | Remove; keep in the case record |
| Article held internal when it should be external | Review audience setting; promote to external |
| WIP left open after case closes | Promote or delete |
| Article reviewed without a reuse event | Stop — review only on demand |

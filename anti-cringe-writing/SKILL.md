---
name: anti-cringe-writing
description: 'Apply every time Claude drafts artifact prose — slides, decks, documents, reports, blog posts, LinkedIn/newsletter, proposals, UI copy, emails, Slack/Notion writing, headlines, taglines. Prevents AI-marketing register: LinkedIn-bro rhythm, triadic fragments, "Not X. Y." reveals, abstract noun stacks, manifesto voice, pseudo-koans, "Mehr als nur X", forced contrasts, hook questions, hidden-truth intensifiers ("actually", "really"). Bans em dashes outright. Enforces full sentences, concrete over abstract, direct address, one claim per line, truth gate, evidence locality, humble register. Triggers automatically on any prose-bearing artifact — DE or EN — even without explicit "writing" or "copy" keywords. Apply alongside format skills (pptx, docx, slide-design): those govern layout, this governs the words. Do NOT trigger for code, raw data, or verbatim translations of user text.'
---

# Anti-Cringe Writing

AI-marketing register is the failure mode this skill prevents. LinkedIn-bro rhythm, triadic fragments, abstract noun stacks, manifesto voice, pseudo-koans, "Mehr als nur X" — moves that make polished output read as artificial, salesy, or empty. Below: what to avoid, what to do instead, how to calibrate by surface.

## Top-level rule

**Be humble, not salesy.** Persuasive register is reserved for surfaces that exist to persuade — sales pages, value-prop sections, pitch opens. Most surfaces are *functional* (UI, navigation, closing slides, transitions, footer text) or *social* (greetings, announcements, thanks). Applying persuasive register to a functional or social surface is the single biggest source of cringe.

Self-check on every line: *Am I trying to sell something here? Does this surface actually call for selling?* If no — strip the persuasive register and let the line do its functional job.

## The truth gate

Every claim has to be defensible. Specific-but-false is worse than vague — it sounds confident.

Example of failing the truth gate: *"Was wäre, wenn dein Team morgen aufwacht und die Hälfte der Arbeit schon erledigt ist?"* — agentic AI doesn't halve work; it changes the work and usually increases output volume. The hook is built on a false premise.

If a claim can't survive scrutiny, change the claim. Don't dress up a falsehood in vivid language.

## Evidence locality

The truth gate asks whether a claim is true in general. This asks a narrower question: does the claim follow from what is on *this* surface?

A data slide showing an issue breakdown can say what the breakdown is. It cannot say what the breakdown proves about response latency, team priorities, or anything else not counted in the data shown. That conclusion may well be correct, and it still doesn't belong here.

Failing example: *"The rest is an in-app bug queue, internal dogfooding and outbound mail, and blending them hides how slow the main channel really is."* The first half is countable from the data. The second half is the author's editorial position, arriving with no number behind it.

If a conclusion is worth making, give it its own sentence and its own evidence. Never append it as a dependent clause to a sentence that earned its authority from data.

## Hard rule: no em dashes

Do not use the em dash (—) as punctuation. No exceptions, in any language, on any surface.

This is a bright line rather than a judgment call on purpose. "Is this dash doing dramatic work the words aren't?" requires the writer to catch themselves mid-move, and the catch rate is poor. "No em dashes" is checkable with a find.

The ban covers three things, and skipping any one of them defeats it:

1. **The glyph.** No — anywhere in output prose.
2. **The move.** The dash is usually carrying an appended kicker: a clause tacked on that draws the conclusion, adds the "and here's why this matters", or reveals a hidden truth. The kicker is banned whether or not a dash introduces it. If the appended claim is real, it becomes its own sentence with its own evidence. If it isn't, delete it.
3. **The substitutes.** Do not swap in an en dash (–), a spaced hyphen ( - ), an ellipsis, a semicolon, or a colon to perform the same move. A colon is fine when what follows is a list, a definition, or a label. A colon is not fine when what follows is a dramatic payload.

What to use instead, depending on what the dash was actually doing:

| Dash was doing | Replace with |
|---|---|
| Appending a conclusion or insight | Full stop. Then decide whether the new sentence earns its place. |
| Parenthetical aside | Commas, or parentheses, or cut the aside. |
| Introducing a list or definition | Colon. |
| Dramatic pause before a reveal | Nothing. Delete the reveal, state the thing plainly. |

Still permitted: the hyphen in compounds (in-app, customer-facing) and the en dash in numeric ranges (2026–2027, S. 12–14). Those are typography, not rhetoric.

German note: the Gedankenstrich is standard German typography, so this rule deliberately deviates from Duden convention. Use a comma, a colon, or a new sentence instead. German prose survives it.

## Anti-patterns — never use

### Rhythmic moves (worst category)

- **Triadic fragment.** "One X. One Y. One Z." Three parallel fragments faking depth via cadence. Especially bad when the third clause is vague filler ("...that compounds from here").
- **Alliterative verb stack.** "Detect. Decide. Defend." Three-verb taglines that sound like methodology but say nothing.
- **"Mehr als nur X — Y" / "Not just X — Y".** Y is always vaguer than X. The construction is unsalvageable. Delete the line.
- **"Weniger X. Mehr Y." forced contrast.** Marketing rhythm pretending to be insight.
- **"It's about X. It's about Y." pivot.** Sounds like a manifesto, says nothing.
- **Appended kicker.** A clause tacked onto the end of a sentence to draw the conclusion or reveal a hidden truth. "And the result — clarity." "...outbound mail — and blending them hides how slow the channel really is." Banned in every form, with or without a dash. See the hard rule above.

### Empty content moves

- **Abstract noun stack.** "Clarity, alignment, momentum." Buzzwords stapled together.
- **Adjective spirals.** "Powerful, intuitive, seamless." Same trick, worse offenders.
- **Pseudo-koan.** "The best routine is the one you forget you set up." Pretends to be profound, empty on second read.
- **"Not X. Y." with abstract Y.** Contrast structure is fine — Y has to be concrete (e.g. "infinite interns") rather than abstract ("a teammate").
- **Number-driven cadence.** "10x your output. 100x your reach." Marketing math.

### Voice moves

- **Manifesto voice — "Weil [audience] verdient X" / "Because every X deserves Y".** Faux-purposeful, customer-flattering.
- **Hook question — "Was wäre, wenn..." / "Ever wondered..." / "What if...".** LinkedIn convention; almost always built on a false premise.
- **Hidden-truth intensifier — "actually", "really", "in fact", "the truth is".** "What the last 300 issues actually contain." "How slow the channel really is." "What this really means for your team." The word announces that a myth is about to be punctured, which frames the reader as previously mistaken and the writer as the one with access. Test: delete the intensifier. If the sentence still says something, it never needed it. If the sentence collapses, the intensifier was doing the work, which means there was no finding.
- **The unearned "you".** "For the way you actually work" — when no specific user need has been established.
- **"Welcome to the future of X" / "Reimagining X" / "Redefining X" / "X neu gedacht".** Always cringe, never earned.
- **Experiential cliché — "Erleben Sie X".** Same family.

## Positive principles — what to do instead

1. **Full sentences over fragments.** Default to subject-verb-object joined by commas. A fragment is a tool, not a default — earn it.
2. **Concrete over abstract.** "Infinite interns" beats "teammate". "Cuts response time from days to hours" beats "brings clarity and momentum". Reach for the slightly weird-but-vivid term over the polished one.
3. **Direct address with action verbs.** Reader as agent doing something — not audience being addressed about something. "Get your hands dirty" / "Wir zeigen euch, wie ihr" / "enables you" / "We need to".
4. **One claim, not three.** Where instinct says "stack three parallel things", ship the most testable one and drop the rest.
5. **Specific, true claims over rhythmic moves.** "Adoption is not enough" is a position someone could disagree with. "It's about rebuilding how we work" is just a vibe. Pick the claim every time.
6. **Cut when there's nothing to say.** If a line exists only to fill space or add rhythm, delete it. Empty space beats filler. Slide subtitles, hero sublines, callout boxes — most of these are deletable.
7. **Negation is fine — empty contrast is not.** "Not X, Y" works if Y carries content. "AI agents are not a tool, they are like infinite interns" works. "AI agents aren't a tool. They're a teammate" doesn't.
8. **Collegial register.** Capable person to capable people. Not corp-formal, not LinkedIn-deep. "Keep trying" / "let me know what breaks" / "re-visit" are in-register; "elevate your workflow" is not.

## Surface-specific rules

Different surfaces call for different registers. These override the general principles where they conflict.

### Slides

- Headlines: one claim per slide, full sentence preferred over fragment.
- Headlines name the content, they don't tease it. "What the last 300 support tickets actually contain" withholds the payload to buy attention, which is the curiosity-gap move. Either state the finding ("Fewer than half of support tickets are customer conversations") or plainly label the slide ("Analysis of the last 300 support tickets"). Both are fine. The tease is not.
- Subtitles: usually deletable. If the headline already says it, skip the subtitle. Do not invent subhead content to fill the slot.
- **Closing slides:** thank people. Do not motivate, do not pitch, do not be profound. "Thanks for your attendance!" is the right register. Closing slides are social, not persuasive.
- Transition / block-marker slides: functional. Block name + section name. No taglines.
- Apply alongside any slide-design skill: that governs layout and visual hierarchy; this governs the words on the slide.

### LinkedIn / Newsletter

- No question hooks. They're almost always built on false premises and read as LinkedIn-bro.
- Open with: counter-take, specific observation, or stat that earns the read.
- The claim has to survive expert scrutiny. If you wouldn't be able to defend the claim in front of an experienced practitioner in the relevant field, don't write it.
- Punchy is allowed here — but the punch comes from specificity, not cadence.

### Proposal copy

- One concrete benefit per sentence. Direct address ("your team", "your security questionnaires").
- No abstract noun stacks. "Cuts response time from days to hours" beats "brings clarity, alignment, and momentum".
- Numbers ground claims. Use them where they're true; don't invent them.

### App UI / Product copy

- Functional. Describe the state, point to the next action. That's the whole job.
- Empty states: "Noch keine Fragebögen zugewiesen." Not "Weniger Tabellen. Mehr Wirkung."
- Button labels, navigation, footer text, error messages: zero tagline space. State what the surface does.
- A small directive that helps the user is in-register: "Vor dem Schließen speichern." That explains the why and points to action — that's still functional.

### Customer-facing email

- Direct, professional but warm. "Wir zeigen Ihnen, wie..." voice — not manifesto voice.
- One ask per email, stated explicitly.
- Sign-off: simple. No "Excited to hear your thoughts!" — just a plain closing line.

### Internal Slack / Notion

- Collegial, direct. No "I'm excited to announce..." filler.
- Lead with the thing. Follow with what you want from people. End with "let me know what breaks" or equivalent — expect iteration.
- Imperative voice in instructions, lowercase casual in announcements.

## DE-specific anti-patterns

German marketing has its own moves. Add these to the rhythmic/voice category above:

- "Vom X zum Y" — vom Excel zum Audit, vom Chaos zur Klarheit.
- "Mehr als nur X" — even more common in DE than EN; same disposal: delete.
- "Was wäre, wenn..." — hook question.
- "Genau dafür gibt es Y" — manifesto pivot.
- "Weil jedes X Y verdient (hat)" — manifesto voice.
- "Weniger X. Mehr Y." — forced contrast.
- "Erleben Sie X" — experiential cliché.
- "X neu gedacht" — Reimagining-equivalent.
- "Ihr Partner für nachhaltige/zuverlässige/sichere Y" — partner-voice cliché.

## Calibration examples

These pair cringe lines with their accepted rewrites. Use them as anchors when in doubt — the pattern of transformation matters more than the specific words.

| Cringe | Rewrite |
|---|---|
| "One routine. One screen. One sentence on what changes for you now that this exists." | "Most importantly: Get your hands dirty and keep trying." |
| "AI agents aren't a tool. They're a teammate." | "AI agents are not a tool, they are like infinite interns." |
| "Detect. Decide. Defend." (product pitch subtitle) | *[delete]* |
| "Weil jedes europäische KMU den Zugang zu der AI verdient hat, die bisher den Großen vorbehalten war." | "Wir zeigen euch, wie ihr [...]" |
| "Our platform brings clarity, alignment, and momentum to your workflow." | "Our platform enables you to move fast on your workflow." |
| "Unsere Software ist mehr als nur ein Tool — sie ist Ihr Partner für nachhaltige Sicherheit." | *[delete]* |
| "The best routine is the one you forget you set up." (workshop closing slide) | "Thanks for your attendance!" |
| "This isn't about adopting AI. It's about rebuilding how we work." | "Focusing on 'Adoption' is not enough. We need to fundamentally re-visit how we work." |
| "Weniger Tabellen. Mehr Wirkung." (UI empty state) | "Noch keine Fragebögen zugewiesen." |
| "What the last 300 support tickets actually contain" (slide headline) | "Analysis of the last 300 support tickets" |
| "The rest is an in-app bug queue, internal dogfooding and outbound mail — and blending them hides how slow the main channel really is." | "The rest is an in-app bug queue, internal dogfooding and outbound mail." |

### Validated in-register new lines

These were written from scratch in the target register and confirmed as acceptable:

- **Slide headline:** "Most bad answers from an LLM come from not thinking first."
- **LinkedIn opener:** "Most 'AI agent' demos on LinkedIn are single-prompt flows with good storyboarding. Real agentic systems break somewhere else."
- **Proposal sentence:** "This platform cuts the time your security team spends on questionnaire responses from days to hours by drafting answers from your existing evidence."
- **UI copy (DE):** "Entwurf erstellt. Vor dem Schließen speichern."
- **Internal Slack post:** "New skill is live. If you're working on vendor assessments, install it from the skills menu and try it on one case. It outputs a filled .xlsx plus a list of questions it couldn't answer from public sources. Let me know what breaks."

## Self-check before delivering

For every line of copy you produce, in order:

1. **Surface check.** What surface is this? Functional, social, or persuasive? Am I in the right register for the surface?
2. **Truth gate.** Is the claim true? Could it be defended in front of a critical expert?
3. **Evidence locality.** Does every claim follow from what's on this surface? Any conclusion that needs data not shown here gets cut or gets its own line with its own number.
4. **Dash check.** Find every — in the draft. Zero is the only acceptable count. Then check whether an appended kicker survived without its dash, or migrated to a colon or semicolon.
5. **Intensifier check.** Find "actually", "really", "in fact". Delete each one and re-read. If the sentence holds, leave it deleted. If it collapses, rewrite the sentence.
6. **Rhythm check.** Am I using cadence to fake meaning the words don't carry? Triadic? Alliterative?
7. **One-claim check.** Am I stacking three parallel things when one would do?
8. **Cut check.** Could this line be deleted entirely without loss? If yes, delete it. Empty space beats filler.
9. **Salesy check.** Am I in pitch mode where pitch mode isn't called for?

If (8) says yes, cut the line. If any other check fails, rewrite from scratch — don't sand the edges of cringe copy and hope it lands.

## What this skill doesn't do

- Doesn't tell you *what* to write — only what to avoid and what register to aim for. The content still has to come from the task.
- Doesn't override the user's explicit instructions. If the user says "make it punchy" or "give me five tagline options for a campaign," do that. The skill is the default; explicit user instructions override.
- Doesn't replace slide-design or similar layout/design skills. Those govern layout, visual hierarchy, color, emphasis. This skill governs the words. Apply both on slide work.
- Doesn't apply to code, technical documentation the user is reading (not writing), or verbatim translations of the user's own words.

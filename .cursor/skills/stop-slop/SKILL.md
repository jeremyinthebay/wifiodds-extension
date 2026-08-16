---
name: stop-slop
description: Remove AI writing patterns from prose. Use when drafting, editing, or reviewing text to eliminate predictable AI tells, including Chrome Web Store copy, docs, and agent-written prose in this repo.
metadata:
  trigger: Writing prose, editing drafts, reviewing content for AI patterns
  author: Hardik Pandya (https://hvpandya.com)
  source: https://github.com/hardikpandya/stop-slop
  pinned: 8da1f030185bdfe8471220585162991eaeb970e9
---

# Stop Slop

Eliminate predictable AI writing patterns from prose.

Canonical skill: [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) (MIT), pinned to `main` at `8da1f030185bdfe8471220585162991eaeb970e9`. The Jeremy extras below are local to this repo.

## Core Rules

1. **Cut filler phrases.** Remove throat-clearing openers, emphasis crutches, and all adverbs. See [references/phrases.md](references/phrases.md).

2. **Break formulaic structures.** Avoid binary contrasts, negative listings, dramatic fragmentation, rhetorical setups, false agency. See [references/structures.md](references/structures.md).

3. **Use active voice.** Every sentence needs a human subject doing something. No passive constructions. No inanimate objects performing human actions ("the complaint becomes a fix").

4. **Be specific.** No vague declaratives ("The reasons are structural"). Name the specific thing. No lazy extremes ("every," "always," "never") doing vague work.

5. **Put the reader in the room.** No narrator-from-a-distance voice. "You" beats "People." Specifics beat abstractions.

6. **Vary rhythm.** Mix sentence lengths. Two items beat three. End paragraphs differently. No em dashes.

7. **Trust readers.** State facts directly. Skip softening, justification, hand-holding.

8. **Cut quotables.** If it sounds like a pull-quote, rewrite it.

## Jeremy extras (this repo)

These sit on top of the canonical rules. They apply to prose agents write here: docs, PR text, comments, and future Store copy drafts. Do not change extension product code or the live Store listing unless a later task asks for that.

1. **No keyword-stuffed brand lists in Chrome Web Store copy.** Name the sites the listing is actually describing. Do not dump airline or booking-site brands to chase search ranking.

2. **Unknown is not zero.** Missing evidence is unknown. It is not a 0% chance, not "worse," not a last-place rank. Unscored airlines stay unscored and keep their relative order.

3. **Next-gen odds are not the Streaming score.** Per-flight next-gen odds are historical evidence for a specific United or Alaska flight when a tracker publishes it. Streaming score is a 0-100 rating of an airline's WiFi across its whole fleet today. It does not predict the WiFi on a specific flight. Do not treat one number as the other.

4. **No Unicode em dash.** Do not use U+2014 (`—`) or U+2013 (`–`). Use a comma, colon, hyphen-minus, or period.

5. **No "honest" as a virtue word.** Cut "honest," "honestly," "honest record," "honest fix," "honest engineering read." State the fact. Do not use the word to claim credibility.

## Quick Checks

Before delivering prose:

- Any adverbs? Kill them.
- Any passive voice? Find the actor, make them the subject.
- Inanimate thing doing a human verb ("the decision emerges")? Name the person.
- Sentence starts with a Wh- word? Restructure it.
- Any "here's what/this/that" throat-clearing? Cut to the point.
- Any "not X, it's Y" contrasts? State Y directly.
- Three consecutive sentences match length? Break one.
- Paragraph ends with punchy one-liner? Vary it.
- Em-dash anywhere? Remove it. Same for Unicode en dash.
- Vague declarative ("The implications are significant")? Name the specific implication.
- Narrator-from-a-distance ("Nobody designed this")? Put the reader in the scene.
- Meta-joiners ("The rest of this essay...")? Delete. Let the essay move.
- Chrome Web Store copy listing brands the text is not describing? Cut the catalog.
- Unknown evidence written as 0%, worse, or last? Call it unknown.
- Next-gen odds used as if they were a Streaming score, or the reverse? Separate the two.
- "Honest" used as a virtue label? Delete it and keep the fact.

## Scoring

Rate 1-10 on each dimension:

| Dimension | Question |
|-----------|----------|
| Directness | Statements or announcements? |
| Rhythm | Varied or metronomic? |
| Trust | Respects reader intelligence? |
| Authenticity | Sounds human? |
| Density | Anything cuttable? |

Below 35/50: revise.

## Examples

See [references/examples.md](references/examples.md) for before/after transformations.

## License

MIT. Canonical source: https://github.com/hardikpandya/stop-slop

Copyright (c) 2025 Hardik Pandya

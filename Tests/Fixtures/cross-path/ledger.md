# Cross-path divergence ledger (IU-59+)

Documented inequalities on `Tests/Fixtures/cross-path/corpus.tsv`. Rows stay in the corpus (anti-shrink). Unexplained diffs remain test failures (ADR-20 / ADR-24).

| ID | Corpus | Unicode path | Custom path | Why not NFC-equal | Follow-up |
|----|--------|--------------|-------------|-------------------|-----------|
| XP-001 | CP-18 `so'ham` | `सोहम्` (ICU drops `'` and writes final म्) | `सोहम` (apostrophe kept in glyphs; reconstruct includes inherent *a*) | Script difference, not ignorable NFC | [IU-GAP-001 #111](https://github.com/HKdAlex/BBText/issues/111) |

**XP-002 resolved (IU-60):** CP-19 `an ka` — `IndicSandhi` drops dental *n* before space + isnx consonant (`an ka` → `a ka`), matching custom `LineConversion`. Row stays in the corpus with an empty divergence column.

Do **not** “fix” remaining diffs by calling `prepareIAST` on the custom path.
Do **not** drop corpus rows.
Do **not** treat `k a` as a join golden.

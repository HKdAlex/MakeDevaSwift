# Cross-path divergence ledger (IU-59+)

Documented inequalities on `Tests/Fixtures/cross-path/corpus.tsv`. Rows stay in the corpus (anti-shrink). Unexplained diffs remain test failures (ADR-20 / ADR-24).

| ID | Corpus | Unicode path | Custom path | Why not NFC-equal | Follow-up |
|----|--------|--------------|-------------|-------------------|-----------|
| *(none open)* | | | | | |

**XP-001 resolved (IU-GAP-001 / [#111](https://github.com/HKdAlex/BBText/issues/111)):** CP-18 `so'ham` — `decodeUnicode` now honors C virama comma (`0x2C`) after the `ma` letterform, reconstructing `so'ham` → ICU `सोहम्`. Same as Unicode `convertLine`. Row stays with an empty divergence column.

**XP-002 resolved (IU-60):** CP-19 `an ka` — `IndicSandhi` drops dental *n* before space + isnx consonant (`an ka` → `a ka`), matching custom `LineConversion`. Row stays in the corpus with an empty divergence column.

Do **not** “fix” remaining diffs by calling `prepareIAST` on the custom path.
Do **not** drop corpus rows.
Do **not** treat `k a` as a join golden.

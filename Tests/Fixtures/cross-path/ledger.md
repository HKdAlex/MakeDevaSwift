# Cross-path divergence ledger (IU-59+)

Documented inequalities on `Tests/Fixtures/cross-path/corpus.tsv`. Rows stay in the corpus (anti-shrink). Unexplained diffs remain test failures (ADR-20 / ADR-24).

| ID | Corpus | Unicode path | Custom path | Why not NFC-equal | Follow-up |
|----|--------|--------------|-------------|-------------------|-----------|
| *(none open)* | | | | | |

**XP-001 resolved (IU-GAP-001 / [#111](https://github.com/HKdAlex/BBText/issues/111)):** CP-18 `so'ham` — `decodeUnicode` now honors C virama comma (`0x2C`) after the `ma` letterform, reconstructing `so'ham` → ICU `सोहम्`. Same as Unicode `convertLine`. Row stays with an empty divergence column.

**XP-002 resolved (IU-60):** CP-19 `an ka` — `IndicSandhi` drops dental *n* before space + isnx consonant (`an ka` → `a ka`), matching custom `LineConversion`. Row stays in the corpus with an empty divergence column.

**IU-GAP-003 / [#117](https://github.com/HKdAlex/BBText/issues/117):** BBT anusvara is IAST `ṁ` (U+1E41) → Devanagari `ं`, not `ṃ` and not candrabindu. Decode maps `M`→`ṁ` and restores `h` in splice-anusvara `haM`. Unicode-path `IndicSandhi` drops the space after coda `ś`/`ṣ`/`s` (`pāṇḍavāś caiva`). CP-20/21 retargeted to `saṁ`; CP-27–CP-30 (`oṁ`, `haṁ`, `vande 'haṁ`, `pāṇḍavāś caiva`) NFC-match. Not ledgered.

**IU-GAP-004 Class A / [#120](https://github.com/HKdAlex/BBText/issues/120):** trailing C vowelsign `u`/`ū` (`0x75`/`0x55`) after no-splice `fonta` clusters. CP-31–CP-34 (`madhusūdanaḥ`, `arjuna`, `kṣudraṁ`, `puṁsaḥ`) NFC-match. Floor 34. Word-space / hyphen glue (B/C) stays on #120 — not ledgered.

Do **not** “fix” remaining diffs by calling `prepareIAST` on the custom path.
Do **not** drop corpus rows.
Do **not** treat `k a` as a join golden.

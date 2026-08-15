# Cross-path divergence ledger (IU-59+)

Documented inequalities on `Tests/Fixtures/cross-path/corpus.tsv`. Rows stay in the corpus (anti-shrink). Unexplained diffs remain test failures (ADR-20 / ADR-24).

| ID | Corpus | Unicode path | Custom path | Why not NFC-equal | Follow-up |
|----|--------|--------------|-------------|-------------------|-----------|
| *(none open)* | | | | | |

**XP-001 resolved (IU-GAP-001 / [#111](https://github.com/HKdAlex/BBText/issues/111)):** CP-18 `so'ham` — `decodeUnicode` now honors C virama comma (`0x2C`) after the `ma` letterform, reconstructing `so'ham` → ICU `सोहम्`. Same as Unicode `convertLine`. Row stays with an empty divergence column.

**XP-002 resolved (IU-60):** CP-19 `an ka` — `IndicSandhi` drops dental *n* before space + isnx consonant (`an ka` → `a ka`), matching custom `LineConversion`. Row stays in the corpus with an empty divergence column.

**IU-GAP-003 / [#117](https://github.com/HKdAlex/BBText/issues/117):** BBT anusvara is IAST `ṁ` (U+1E41) → Devanagari `ं`, not `ṃ` and not candrabindu. Decode maps `M`→`ṁ` and restores `h` in splice-anusvara `haM`. Unicode-path `IndicSandhi` drops the space after coda `ś`/`ṣ`/`s` (`pāṇḍavāś caiva`). CP-20/21 retargeted to `saṁ`; CP-27–CP-30 (`oṁ`, `haṁ`, `vande 'haṁ`, `pāṇḍavāś caiva`) NFC-match. Not ledgered.

**IU-GAP-004 Class A / [#120](https://github.com/HKdAlex/BBText/issues/120):** trailing C vowelsign `u`/`ū` (`0x75`/`0x55`) after no-splice `fonta` clusters. CP-31–CP-34 (`madhusūdanaḥ`, `arjuna`, `kṣudraṁ`, `puṁsaḥ`) NFC-match. Floor 34.

**IU-GAP-004 Class B/C / [#120](https://github.com/HKdAlex/BBText/issues/120):** Unicode-path coda-nasal + vowel space-drop (`viṣīdantam idaṁ`, `śrī-bhagavān uvāca`). CP-35–CP-36. Floor 36. Anusvara `ṁ` is not coda `m`. Not `k a`.

**IU-GAP-005 / [#122](https://github.com/HKdAlex/BBText/issues/122):** decode honors C wide long-ī `aiafter` rewritten to `L` (`0x4C`; ḷ vowelsign is `0x7D`). Unicode-path coda-consonant space-drop (`tam ka`). CP-37–CP-39. Floor 39.

**IU-GAP-006 Class A / [#125](https://github.com/HKdAlex/BBText/issues/125):** decode honors C repha at the FontTables splice (`R` `0x52`), collapsed rbefore+M (`'<'` `0x3C`), virama+repha (`0x2C` `R`), C `yafter` (`Y` `a`), and pending `i` applied to the vowel-bearing cluster after a fontc half-consonant. CP-40–CP-44 (`janārdana`, `indriyāṇi`, `kāryaṁ`, `kurvanti`, `kuryāṁ`). Floor 44.

**IU-GAP-006 Class D / [#125](https://github.com/HKdAlex/BBText/issues/125):** Unicode `isnx` drops dental `n` only after a standalone vowel (`an ka` → `a ka`). Onset+vowel coda `n` is kept (`devān bh`, `vidvān yuktaḥ`, `śreyān sva-dharmo`); not coda-consonant glue. CP-45–CP-47. Floor 47.

**IU-GAP-006 Class C / [#125](https://github.com/HKdAlex/BBText/issues/125):** ASCII hyphen already NFC-matches (`dharma-kṣetre`). Leftover on hyphen-compound *lines* was C `yafter` attaching as a new `ya` (`सांखयानां` vs `सांख्यानां`). Decode now drops inherent `a` before leftover `Y` `a` so `khya` is a conjunct. CP-48–CP-56. Floor 56.

**IU-GAP-006 Class B / [#125](https://github.com/HKdAlex/BBText/issues/125):** Unicode-path coda-cons + vowel space-drop matching C `convertline` (`k a` → `ka`, `hy a` → `hya`, `tad e` → `tade`). Not HKIndic pairwise. `an ka` → `a ka`. `ka ma` keeps the space. CP-57–CP-63. Floor 63.

**IU-GAP-007 / [#131](https://github.com/HKdAlex/BBText/issues/131):** trailing C repha applies to the whole conjunct including a preceding fontc half-consonant (`t`+`mA`+`R` → `rtmA`, `N`+`ya`+`0x3C` → `rNyaM`). Unicode IAST `l̐` ingests as `lw` (coda `l` + anunasika); reconstruct maps `lw` → `l̐` so ICU is `ल्̐`. C Harvard-Kyoto `V` → `wl` is a different letter order and is not used on the Unicode ingest path. CP-64–CP-68. Floor 68.

**IU-GAP-008 / [#136](https://github.com/HKdAlex/BBText/issues/136):** C `yafter` leftover vowelsign `e`/`ai` (`0x65`/`0x45`) on `sāṅkhyaiḥ` / `śuddhyed`. Coda `d` leftover virama + space before `br` (`tasmād brahmaṇi`); `dy` still clusters. `l̐` + space + `l` does not swallow the next syllable (`vāl̐ la`). CP-69–CP-74. Floor 74.

**IU-GAP-009 / [#140](https://github.com/HKdAlex/BBText/issues/140):** C `dB`/`dg`/`dr`/`db`/`dD` conjuncts glue (`bhavatād bhaktir`, `bhaved grāhyam`, `aiśvaryād rūpam`, `tasmād baka`, `etad dhi`, `niścayād dhairyāt`). Leftover fontc `d` virama keeps space before `br`/`bhr`/non-`dh` `d` (`tasmād brahmaṇi`, `sthānād bhraṣṭāḥ`, `vidyād duḥkha`, `balavad dṛḍham`). Unicode prep drops the space for `dD` so ICU `ddh` matches C ḍh. Not HKIndic pairwise. CP-75–CP-83. Floor 83.

Do **not** “fix” remaining diffs by calling `prepareIAST` on the custom path.
Do **not** drop corpus rows.
Do **not** restore HKIndic pairwise joins.

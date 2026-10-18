# MakeDevaSwift

Swift Package Manager port of the legacy **makedeva** / **devaline** C toolchain —
IAST → RM Devanagari glyph codes (custom font encoding) **and** Unicode Devanagari.

## Layout

| Target | Role |
|--------|------|
| `MakeDevaCore` | Syllable/line conversion, prose layout, BBT encoding, `MakeDevaUnicode` |
| `MakeDevaCLI` | `makedeva` command-line driver (Unicode ingest via `bbt_uni2bbt`) |
| `MakeDevaCoreTests` | Unit + Unicode golden fixtures |
| `MakeDevaParityTests` | Functional parity vs C golden output (slow) |

## Dual output (ADR-23 / wayfinder #49)

```
normalized Unicode IAST
  → {Output mode}
      → Unicode:  MakeDevaUnicode.convertLine  (structural prep → literal Sanskrit spelling)
      → Custom:   ingest (bbt_uni2bbt + charconv + digraphs) → LineConversion
```

### Unicode path — merge-resolve entry API

```swift
import MakeDevaCore

// Full line: structural prep + literal IAST → Unicode
let deva = MakeDevaUnicode.convertLine("kṛṣṇa")   // → कृष्ण

// Prep only (IAST → IAST), Unicode branch — IndicSandhi (isnx, coda glue, avagraha)
let prepared = MakeDevaUnicode.prepareIAST("k  g") // → "kg" (coda+consonant glue)
```

Goldens: `Tests/Fixtures/unicode-devanagari/cases.tsv`

### Glyph → Unicode decode (IU-58)

Custom-path RM Devanagari **glyph bytes** (from `LineConversion`) decode to Unicode
Devanagari without calling `prepareIAST` (ADR-23).

```swift
let glyphs = LineConversion.convertLine("kRSNa").glyphs
let deva = MakeDevaUnicode.decodeUnicode(glyphs)  // → कृष्ण
```

**Mapping ownership**

| Layer | Authority |
|-------|-----------|
| Glyph clusters | Swift `FontTables` ← `devaline.c` `fontu`/`fonta`/`fontc`/… |
| Not used | `devaconv.c` `olddeva[]` (legacy *old* font, different encoding) |
| Unicode rendering | MakeDeva ASCII → IAST → literal Unicode spelling |

`0x20` inside FontTables code arrays is a vowel-sign splice point (not emitted).
Trailing `0x2C` after a letterform is C virama (not Latin comma).
Goldens: `Tests/Fixtures/glyph-decode/cases.tsv`

Cross-path E2E (`Unicode(prepare(ℓ)) ≡ decodeUnicode(customPath(ℓ))`) is IU-59.

### Custom path

`LineConversion` keeps C parity. Unicode input files are converted at ingest with
`BBTEncoding.unicodeToBBT` (C `bbt_uni2bbt`). **No** shared `prepareIAST` on this path.

## Shared structural prep

Requires a checkout of [BBText](https://github.com/HKdAlex/BBText) so
`packages/bbtext-indic-sandhi` resolves:

| Layout | `Package.swift` path |
|--------|----------------------|
| `…/MakeDevaReserve/MakeDevaSwift` (this tree) | `../../BBText/packages/bbtext-indic-sandhi` |
| Sibling repos | change to `../BBText/packages/bbtext-indic-sandhi` |

## Build & test

```bash
swift build
swift test --filter MakeDevaCoreTests          # fast unit + Unicode goldens
swift test --filter MakeDevaParityTests        # full C parity batch (minutes)
```

## Tracker

[BBText engine unification #22](https://github.com/HKdAlex/BBText/issues/22) ·
Unicode path [#26](https://github.com/HKdAlex/BBText/issues/26) ·
Glyph decode [#58](https://github.com/HKdAlex/BBText/issues/58) ·
Wayfinder [#49](https://github.com/HKdAlex/BBText/issues/49)

## EN BG qualification repair (#20, BBText #184)

Unicode conversion now maps Sanskrit IAST literally using Unicode logical order.
General-purpose ICU Latin-Devanagari was unsuitable: `ddh` was accepted as a
retroflex alias, explicit nasals were assimilated, and avagraha was consumed.
`SanskritUnicode` owns spelling only; MakeDeva C remains the structural/custom
font authority. Unknown characters remain visible rather than being dropped.
No custom-font generation, layout tables or C parity goldens were changed.

The reverse decoder now accepts combined vowel + anusvara/repha at a font-table
splice. This restores `ktuṁ`, `rde`, and related clusters. Six full-book spacing
differences are fixed in companion BBText PR #192 (IndicSandhi); this branch's
book qualification tests require that BBText version.

Explicit oracle corrections: Unicode fixture `pāṇḍava` is now `पाण्डव` (previous
`पांडव` was ICU output); glyph fixture and assertion `so'ham` now retain `ऽ`.
These are spelling corrections, not refreshed C output goldens.

One bounded legacy limitation remains: C devaline.c:1576 lifts anusvara before
avagraha for print positioning. Decoding `tejo'ṁśa` gives `तेजोंऽश`; the source-led
Unicode path gives `तेजोऽंश`. BG 10.41 retains this explicit cross-path exception.
Do not alter source IAST or infer that the two orders are canonically equivalent.
All 760 EN BG roman blocks are checked against an independent ebook witness;
that witness itself contains omissions/encoding differences and is evidence,
never replacement content. Focused editorial acceptance remains separate.

Encoding reference: [Unicode 17, Devanagari](https://www.unicode.org/versions/Unicode17.0.0/core-spec/chapter-12/#G1226).

## SB prose digit termination (#22)

The custom glyph loop now passes ASCII digits through exactly as the C SHELL
punctuation branch does. Previously the syllable scanner stopped before a digit
without advancing the outer loop, causing unbounded output growth. Reverse
glyph decoding retains those digit bytes as Unicode Devanagari digits.

Regression coverage includes all ten digits, leading/trailing digits, punctuation,
verse/prose modes and the public custom Unicode path. Full Swift tests pass
(169 core tests plus 52 parity tests). This repairs termination; it does not
certify malformed source tails or resolve the remaining #20 spelling/spacing
comparisons. No source text or C comparison fixtures changed.

## SB batch custom-path losses (#20)

The Unicode IAST input adapter now maps right curly apostrophe U+2019 to the
existing ASCII avagraha control, and NBSP U+00A0 to the existing word-space
control. Previously these non-ASCII characters reached `LineConversion`, which
only handles the legacy controls, and were dropped. `so’ham` lost its avagraha;
`ka ma` lost its word boundary. The adapter does not call Unicode structural prep.
The existing C boundary rules still decide whether a word space is emitted.

Reverse glyph decoding now recognizes collapsed repha/anusvara marks inside a
FontTables splice as well as after a letterform. C `devaline.c:1060–1072` combines
these signs into `<`/`>` (`=` for the corresponding mark without anusvara).
For example, generated `rhaM` bytes `68 3C 22` previously reconstructed as empty
text. Vowel-bearing variants and the full `devarṣir haṁsayānena` example have
explicit regression cases. Glyph generation, layout tables, C parity fixtures,
and the reader's Unicode conversion path are unchanged.

This is a bounded repair, not complete cross-path certification. Unicode
structural prep still treats NBSP/curly-apostrophe boundaries differently from
their ASCII equivalents, and other reverse-glyph/spacing differences remain.
Keep their complete source-pinned exception inventory; agreement does not grant
Sanskrit editorial acceptance. Reconcile affected consumers and candidate pins
before using a new converter revision.

Validation checkpoint: 172 core tests and 52 existing C-parity tests pass. A
complete 14,546-block EN SB 2–12 API replay keeps every reader Unicode line
exactly unchanged. It changes 729 custom-path blocks: 50 disagreements resolve,
649 change from character to spacing-only differences, and 175 character plus
833 spacing-only differences remain. All 13,488 prior agreements remain agreements.
This does not repin any canonical candidate or grant editorial acceptance.

### Legacy BBT nasal-l spelling (2026-10-18)

Unicode U+1E3B (`ḻ`) is interpreted using the established BBT convention:
`bbtToUnicode[0x8f]` maps this character, `charconv[15]` maps to `V`, and
`makedeva.c:1059` expands `V` to `wl` (commented “l candra bindu”).
Both Unicode and custom ingest now preserve this mark and consonant. Unicode
structural preparation expands it before spacing rules; prepared literal conversion
also supports it. This is distinct from the existing explicit `l̐` spelling.
NFC/decomposed input is tested. All 175 core and 52 existing C-parity tests pass.
The 25 affected SB passages require an explicit changed-output inventory and
editorial review; this repair does not itself qualify the books.

### Distance-spliced anusvara reverse decoding (2026-10-18)

C `devaline.c:1137–1162` can consume a single distance suffix while positioning
anusvara, emitting distance bytes, the mark and any remaining distance. Reverse
decode now recognizes this exact shape. Previously `hariṁ gehāt` decoded as
`हं गिहात्`: the missed ra left short-i pending across the word boundary.
The real conversion regression now yields `हरिं गेहात्`; 176 core tests pass.
This changes only reverse decoding, not glyph generation or reader Unicode.
Full corpus replay is required before candidate refresh.

### Glyph decoding is not a lossless text round-trip

The legacy C lookahead (`devaline.c:1576–1587`) attaches anusvara after avagraha
to the preceding vowel for typesetting. The real shared pipeline produces the
same glyph bytes for `brahmaṇoṁ 'śena` and `brahmaṇo 'ṁśena`, although literal
Unicode correctly distinguishes `ब्रह्मणोंऽशेन` and `ब्रह्मणोऽंशेन`.
A regression test proves this collision. Do not globally swap decoded marks to
force agreement: that would corrupt the first input. Preserve source IAST and
use the literal Unicode path for logical text; glyph reverse decoding remains
a diagnostic aid with this explicit limitation. Source-aware reconstruction or
a provenance sidecar would be needed for a guaranteed round-trip.

### Trailing-ya repha and next-cluster short-i (2026-10-18)

Reverse decoding retains the full preceding consonant cluster when C emits
`yafter`, so repha applies to the whole conjunct (`rddhyā` → `र्द्ध्या`,
`rṣṭya` → `र्ष्ट्य`). It also treats short-i only as a prefixed sign, as
C `devaline.c:1046` emits it, never as a splice vowel belonging to a preceding
fixed-vowel cluster (`śṛṅgidaṁṣṭriṇām` → `शृङ्गिदंष्ट्रिणाम्`). Both defects
were reproduced in failing real-path regressions; all 179 core tests pass.
Glyph generation and literal reader Unicode are unchanged.

### Preserve reverse ASCII consonant-token identity (2026-10-18)

Glyph reconstruction distinguishes two tokens `g`+`h` from one aspirated `G`.
Unicode decoding now converts separately across lower-case stop+h boundaries
and concatenates the logical results, rather than flattening both into the
same IAST digraph. No separator or invisible code point is injected. This
preserves `ग्ह` versus `घ` and `त्ह` versus `थ`; glyph generation is unchanged.
`makeDevaASCIIToIAST` remains a display spelling helper, not a lossless token IR.

The old `E4 2C 22 68 22 6D 61 52` fixture mislabeled dead dental d+h as धर्म.
It now expects द्हर्म, retaining the exact glyph bytes. A second fixture uses
the actual aspirated bytes `44 61 6D 61 52` → धर्म. C fontc d and fonta D
confirm the distinction; all 181 core tests pass.

### Prose semicolons in Unicode comparison

`MakeDevaUnicode.customPathUnicode` retains semicolons as literal Unicode
separators and converts each surrounding span through the legacy glyph path.
The C-compatible raw glyph converter cannot represent this separator as byte
0x3B: that slot is `xr__`. Feeding a semicolon directly into its consonant scan
can lose adjacent letters. The Unicode comparison API therefore does not claim
a single-font printable glyph buffer. Print/custom-font callers still need a
mixed-font punctuation representation or an explicit unsupported-input diagnostic;
this remains tracked under #20. Ordinary Unicode `convertLine` preserves these
source punctuation marks independently.

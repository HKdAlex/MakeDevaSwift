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

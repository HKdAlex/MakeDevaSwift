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
      → Unicode:  MakeDevaUnicode.convertLine  (structural prep → ICU)
      → Custom:   ingest (bbt_uni2bbt + charconv + digraphs) → LineConversion
```

### Unicode path — merge-resolve entry API

```swift
import MakeDevaCore

// Full line: whitespace prep + ICU Latin-Devanagari
let deva = MakeDevaUnicode.convertLine("kṛṣṇa")   // → कृष्ण

// Prep only (IAST → IAST), Unicode branch — whitespace collapse only
let prepared = MakeDevaUnicode.prepareIAST("k  g") // → "k g"
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
| Unicode rendering | MakeDeva ASCII → IAST → ICU `Latin-Devanagari` |

`0x20` inside FontTables code arrays is a vowel-sign splice point (not emitted).
Trailing `0x2C` after a letterform is C virama (not Latin comma).
Goldens: `Tests/Fixtures/glyph-decode/cases.tsv`

Cross-path E2E (`ICU(prepare(ℓ)) ≡ decodeUnicode(customPath(ℓ))`) is IU-59.

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

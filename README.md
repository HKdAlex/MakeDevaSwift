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

// Full line: structural prep + ICU Latin-Devanagari
let deva = MakeDevaUnicode.convertLine("kṛṣṇa")   // → कृष्ण

// Prep only (IAST → IAST), Unicode branch
let prepared = MakeDevaUnicode.prepareIAST("k g") // → "kg"
```

Goldens: `Tests/Fixtures/unicode-devanagari/cases.tsv`

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
Wayfinder [#49](https://github.com/HKdAlex/BBText/issues/49)

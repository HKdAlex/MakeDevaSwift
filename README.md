# MakeDevaSwift

Swift Package Manager port of the legacy **makedeva** / **devaline** C toolchain — IAST transliteration to RM Devanagari glyph codes (custom font encoding) and, in progress, Unicode Devanagari output.

## Layout

| Target | Role |
|--------|------|
| `MakeDevaCore` | Syllable/line conversion, prose layout, BBT encoding tables |
| `MakeDevaCLI` | `makedeva` command-line driver |
| `MakeDevaCoreTests` | Unit + integration tests |
| `MakeDevaParityTests` | Functional parity vs C golden output (slow) |

## Build & test

```bash
swift build
swift test --filter MakeDevaCoreTests          # fast unit tests
swift test --filter MakeDevaParityTests        # full C parity batch (minutes)
```

## Shared IAST sandhi (#32 / BBText `bbtext-indic-sandhi`)

Requires a checkout of [BBText](https://github.com/HKdAlex/BBText) so `packages/bbtext-indic-sandhi` resolves:

| Layout | `Package.swift` path |
|--------|----------------------|
| `…/MakeDevaReserve/MakeDevaSwift` (this tree) | `../../BBText/packages/bbtext-indic-sandhi` |
| Sibling repos `parent/BBText` + `parent/MakeDevaSwift` | change to `../BBText/packages/bbtext-indic-sandhi` |

Unicode-path entry points call shared space-closing:

```swift
import MakeDevaCore

let prepared = MakeDevaUnicode.prepareIAST("k g")   // → "kg"
let line = MakeDevaUnicode.convertLine(iastLine)    // sandhi + Unicode (ICU in #26)
```

Custom-encoding `LineConversion` keeps legacy C parity until goldens are refreshed.

## Tracker

Part of [BBText engine unification #22](https://github.com/HKdAlex/BBText/issues/22) · Unicode path [#26](https://github.com/HKdAlex/BBText/issues/26)

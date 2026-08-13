import Foundation

/// Glyph → Unicode Devanagari decode (IU-58 / [#58](https://github.com/HKdAlex/BBText/issues/58)).
///
/// ## Mapping ownership
///
/// | Layer | Authority | Location |
/// |-------|-----------|----------|
/// | Custom glyph bytes | `LineConversion` / `SyllableConversion` (C `convertline` / `convertsyllable`) | this package |
/// | Glyph clusters | Swift `FontTables` ported from `devaline.c` `fontu`/`fonta`/`fontc`/… | `Data/FontTables.swift` |
/// | **Not used** | `devaconv.c` `olddeva[]` (legacy *old* Devanagari font, different encoding) | C-only clipboard tool |
/// | Unicode rendering | ICU `Latin-Devanagari` after MakeDeva-ASCII → IAST | `MakeDevaUnicode.transliteratePreparedIAST` |
///
/// `0x20` inside `FontTables` code arrays is a **vowel-sign splice point**, not an emitted
/// glyph (`SyllableConversion` only emits bytes `> 0x20`). Inter-syllable `0x20` in the
/// glyph buffer is a word space from `LineConversion`.
///
/// Trailing `0x2C` (`,`) after a letterform is C virama (`vowelsign` when the syllable
/// vowel is space). Decode drops inherent *a* so `m` + virama → `म्`, matching ICU.
/// Clusters that embed `0x2C` (e.g. `dharma`) are consumed by FontTables reverse first.
///
/// `ṛ`/`ṝ`/`ḷ` after a no-splice `fonta` cluster (e.g. `D` → `44 61 7B`) are trailing
/// vowelsign bytes `0x7B`/`0x7C`/`0x7D`, not splice and not repha (`0x52`).
///
/// Does **not** call `prepareIAST` (ADR-23: no shared prep on the custom path).
public enum MakeDevaGlyphDecode {
    /// Decode RM Devanagari glyph codes to Unicode Devanagari.
    public static func decodeUnicode(_ glyphs: [UInt8]) -> String {
        let ascii = reconstructMakeDevaASCII(glyphs)
        let iast = makeDevaASCIIToIAST(ascii)
        return MakeDevaUnicode.transliteratePreparedIAST(iast)
    }

    /// Reconstruct MakeDeva ASCII (Harvard-Kyoto-like) from glyph codes.
    public static func reconstructMakeDevaASCII(_ glyphs: [UInt8]) -> String {
        var out = ""
        var i = 0
        var pendingI = false

        while i < glyphs.count {
            let b = glyphs[i]

            if b == FontConstants.CODE_Nothing || b == FontConstants.CODE_HalfLine {
                i += 1
                continue
            }
            if b == FontConstants.CODE_EndVerseLine || b == FontConstants.CODE_EndProseLine {
                out.append("\n")
                i += 1
                continue
            }
            if b == FontConstants.CODE_EmDash {
                out.append("-")
                i += 1
                continue
            }
            if b == UInt8(ascii: " ") {
                out.append(" ")
                i += 1
                continue
            }
            if b == UInt8(ascii: "/") {
                i += 1
                if i < glyphs.count, glyphs[i] == UInt8(ascii: "/") {
                    out.append(".")
                    i += 1
                } else {
                    out.append(",")
                }
                continue
            }
            if b == UInt8(ascii: "-") {
                out.append("-")
                i += 1
                continue
            }
            if b == UInt8(ascii: "'") {
                out.append("'")
                i += 1
                continue
            }
            if b == UInt8(ascii: "M") {
                out.append("M")
                i += 1
                continue
            }
            if b == UInt8(ascii: "*") {
                out.append("w")
                i += 1
                continue
            }
            if b == UInt8(ascii: ":")
                || (b == UInt8(ascii: "H") && clusterMatch(glyphs, at: i) == nil)
            {
                out.append("H")
                i += 1
                continue
            }

            if b == UInt8(ascii: "i") {
                pendingI = true
                i += 1
                continue
            }

            if let (consumed, ascii) = standaloneVowelMatch(glyphs, at: i) {
                out.append(ascii)
                i += consumed
                pendingI = false
                continue
            }

            if let match = clusterMatch(glyphs, at: i) {
                var consumed = match.consumed
                var vowel = match.vowel
                if match.vowelClass == .inherentA, vowel == "a" || vowel == nil {
                    (vowel, consumed) = applyAiafter(glyphs, at: i, consumed: consumed, vowel: vowel)
                }
                // fonta rows with no 0x20 splice (e.g. "D" = 0x44 0x61) emit ṛ/ṝ/ḷ as
                // a following vowelsign (0x7B/0x7C/0x7D), not a splice byte.
                if vowel == nil || vowel == "a", i + consumed < glyphs.count {
                    switch glyphs[i + consumed] {
                    case 0x7B:
                        vowel = "R"
                        consumed += 1
                    case 0x7C:
                        vowel = "Y"
                        consumed += 1
                    case 0x7D:
                        vowel = "L"
                        consumed += 1
                    default:
                        break
                    }
                }
                var cons = match.transliteration
                if i + consumed < glyphs.count, glyphs[i + consumed] == UInt8(ascii: "R"),
                   standaloneVowelMatch(glyphs, at: i + consumed) == nil
                {
                    cons = "r" + cons
                    consumed += 1
                }
                var syllable = cons
                if pendingI {
                    syllable.append("i")
                    pendingI = false
                } else if let v = vowel, v != " " {
                    syllable.append(v)
                } else if match.vowelClass == .inherentA, vowel != " " {
                    // Inherent *a* unless C already emitted virama (splice vowel " ").
                    syllable.append("a")
                }
                out.append(syllable)
                i += consumed
                continue
            }

            // C `vowelsign=','` (devaline.c) after a letterform: dead consonant, not punctuation.
            // Punctuation comma is encoded as `/` (handled above). FontTables clusters that
            // include 0x2C are consumed by `clusterMatch` first.
            if b == UInt8(ascii: ",") {
                if out.last == "a" {
                    out.removeLast()
                }
                i += 1
                continue
            }

            // Unmatched distance/kerning prefix — skip (D030…D270).
            if isDistanceCode(b) {
                i += 1
                continue
            }

            i += 1
        }

        return out
    }

    // MARK: - Standalone vowels (SyllableConversion.handleStandaloneVowel)

    private static func standaloneVowelMatch(_ glyphs: [UInt8], at i: Int) -> (Int, String)? {
        let rest = glyphs.count - i
        func at(_ offset: Int) -> UInt8? {
            let j = i + offset
            return j < glyphs.count ? glyphs[j] : nil
        }

        // Longest first.
        if rest >= 3, at(0) == 0x40, at(1) == 0x41, at(2) == UInt8(ascii: "E") { return (3, "O") }
        if rest >= 3, at(0) == 0x40, at(1) == 0x41, at(2) == UInt8(ascii: "e") { return (3, "o") }
        if rest >= 3, at(0) == 0x61, at(1) == 0x6C, at(2) == 0x7B { return (3, "L") }
        if rest >= 2, at(0) == 0x40, at(1) == 0x41 { return (2, "A") }
        if rest >= 2, at(0) == UInt8(ascii: "w"), at(1) == UInt8(ascii: "R") { return (2, "I") }
        if rest >= 2, at(0) == 0x5B, at(1) == 0x25 { return (2, "R") }
        if rest >= 2, at(0) == 0x5C, at(1) == 0x23 { return (2, "Y") }
        if rest >= 2, at(0) == UInt8(ascii: "W"), at(1) == UInt8(ascii: "e") { return (2, "E") }
        if rest >= 1, at(0) == 0x40 { return (1, "a") }
        if rest >= 1, at(0) == UInt8(ascii: "w") { return (1, "i") }
        if rest >= 1, at(0) == UInt8(ascii: "o") { return (1, "u") }
        if rest >= 1, at(0) == UInt8(ascii: "O") { return (1, "U") }
        if rest >= 1, at(0) == UInt8(ascii: "W") { return (1, "e") }
        if rest >= 1, at(0) == UInt8(ascii: "V") { return (1, "oM") }
        return nil
    }

    // MARK: - FontTables reverse (emitted bytes)

    private enum VowelClass: Sendable, Equatable {
        case inherentA
        case fixed(Character)
        case none
    }

    private struct ClusterMatch {
        let transliteration: String
        let vowel: Character?
        let vowelClass: VowelClass
        let consumed: Int
    }

    private struct ReverseEntry {
        let prefix: [UInt8]
        let suffix: [UInt8]
        let hasSplice: Bool
        let transliteration: String
        let vowelClass: VowelClass
    }

    private static let reverseEntries: [ReverseEntry] = buildReverseEntries()

    private static func buildReverseEntries() -> [ReverseEntry] {
        var entries: [ReverseEntry] = []

        func addC(_ table: [FontInfoC], vowel: VowelClass) {
            for row in table {
                let (prefix, suffix, splice) = splitEmitted(row.code)
                guard !prefix.isEmpty || !suffix.isEmpty else { continue }
                entries.append(
                    ReverseEntry(
                        prefix: prefix,
                        suffix: suffix,
                        hasSplice: splice,
                        transliteration: row.transliteration,
                        vowelClass: vowel
                    )
                )
            }
        }

        addC(FontTables.fontu, vowel: .fixed("u"))
        addC(FontTables.fontuu, vowel: .fixed("U"))
        addC(FontTables.fontR, vowel: .fixed("R"))
        addC(FontTables.fontY, vowel: .fixed("Y"))
        addC(FontTables.fontL, vowel: .fixed("L"))
        addC(FontTables.fontv, vowel: .none)
        addC(FontTables.fontc, vowel: .none)

        for row in FontTables.fonta {
            let (prefix, suffix, splice) = splitEmitted(row.code)
            guard !prefix.isEmpty || !suffix.isEmpty else { continue }
            entries.append(
                ReverseEntry(
                    prefix: prefix,
                    suffix: suffix,
                    hasSplice: splice,
                    transliteration: row.transliteration,
                    vowelClass: .inherentA
                )
            )
        }

        // Longest emitted span first; splice entries can consume one extra vowel byte.
        return entries.sorted {
            $0.prefix.count + $0.suffix.count + ($0.hasSplice ? 1 : 0)
                > $1.prefix.count + $1.suffix.count + ($1.hasSplice ? 1 : 0)
        }
    }

    /// Bytes `<= 0x20` in FontTables codes are splice/control, not emitted glyphs.
    private static func splitEmitted(_ code: [UInt8]) -> (prefix: [UInt8], suffix: [UInt8], splice: Bool) {
        if let space = code.firstIndex(where: { $0 <= UInt8(ascii: " ") }) {
            let prefix = Array(code[..<space].filter { $0 > UInt8(ascii: " ") })
            let suffix = Array(code[(space + 1)...].filter { $0 > UInt8(ascii: " ") })
            return (prefix, suffix, true)
        }
        return (code.filter { $0 > UInt8(ascii: " ") }, [], false)
    }

    private static let spliceVowel: [UInt8: Character] = [
        0x41: "A",
        0x49: "I",
        0x69: "i",
        0x75: "u",
        0x55: "U",
        0x65: "e",
        0x45: "E",
        0x7B: "R",
        0x7C: "Y",
        0x7D: "L",
        0x2C: " ",
    ]

    private static func clusterMatch(_ glyphs: [UInt8], at i: Int) -> ClusterMatch? {
        var best: ClusterMatch?
        var bestLen = 0

        for entry in reverseEntries {
            if let match = matchEntry(entry, glyphs: glyphs, at: i), match.consumed > bestLen {
                best = match
                bestLen = match.consumed
            }
        }
        return best
    }

    private static func matchEntry(_ entry: ReverseEntry, glyphs: [UInt8], at i: Int) -> ClusterMatch? {
        guard matches(entry.prefix, glyphs: glyphs, at: i) else { return nil }
        var j = i + entry.prefix.count
        var vowel: Character?
        var vowelClass = entry.vowelClass

        if entry.hasSplice {
            if j < glyphs.count, let v = spliceVowel[glyphs[j]] {
                vowel = v
                j += 1
                if v != " " { vowelClass = .fixed(v) }
            } else if case .inherentA = entry.vowelClass {
                vowel = "a"
            }
            guard matches(entry.suffix, glyphs: glyphs, at: j) else { return nil }
            j += entry.suffix.count
        } else {
            switch entry.vowelClass {
            case .inherentA:
                vowel = "a"
            case .fixed(let v):
                vowel = v
            case .none:
                vowel = nil
            }
        }

        // After a solid inherent-a cluster, a following 'A'/'e'/'E' may lengthen (rA is splice;
        // namo is ma + A + e on a later standalone path). Do not steal 0x41 when it begins
        // another cluster (fonta "N" already consumed its 0x41).

        let resolved: Character?
        switch vowelClass {
        case .inherentA:
            resolved = vowel ?? "a"
        case .fixed(let v):
            resolved = v
        case .none:
            resolved = nil
        }

        return ClusterMatch(
            transliteration: entry.transliteration,
            vowel: resolved,
            vowelClass: vowelClass,
            consumed: j - i
        )
    }

    private static func matches(_ pattern: [UInt8], glyphs: [UInt8], at i: Int) -> Bool {
        guard i + pattern.count <= glyphs.count else { return false }
        for (offset, byte) in pattern.enumerated() where glyphs[i + offset] != byte {
            return false
        }
        return true
    }

    /// `aiafter` / compound vowels are appended *after* the FontTables cluster
    /// (`SyllableConversion`: A, o=A+e, O=A+E) — not at the 0x20 splice.
    private static func applyAiafter(
        _ glyphs: [UInt8],
        at i: Int,
        consumed: Int,
        vowel: Character?
    ) -> (Character?, Int) {
        let k = i + consumed
        guard k < glyphs.count else { return (vowel ?? "a", consumed) }
        if glyphs[k] == 0x41 {
            if k + 1 < glyphs.count, glyphs[k + 1] == UInt8(ascii: "e") {
                return ("o", consumed + 2)
            }
            if k + 1 < glyphs.count, glyphs[k + 1] == UInt8(ascii: "E") {
                return ("O", consumed + 2)
            }
            if clusterMatch(glyphs, at: k) == nil {
                return ("A", consumed + 1)
            }
        }
        if glyphs[k] == 0x49, clusterMatch(glyphs, at: k) == nil {
            return ("I", consumed + 1)
        }
        return (vowel ?? "a", consumed)
    }

    private static func isDistanceCode(_ b: UInt8) -> Bool {
        b == FontConstants.D030
            || b == FontConstants.D060
            || b == FontConstants.D090
            || b == FontConstants.D120
            || b == FontConstants.D150
            || b == FontConstants.D270
    }

    // MARK: - MakeDeva ASCII → Unicode IAST

    /// MakeDeva / Harvard-Kyoto-like single-byte alphabet → Unicode IAST.
    public static func makeDevaASCIIToIAST(_ ascii: String) -> String {
        var out = ""
        out.reserveCapacity(ascii.count)
        for ch in ascii {
            out.append(asciiToIAST[ch] ?? String(ch))
        }
        return out
    }

    private static let asciiToIAST: [Character: String] = [
        "a": "a", "A": "ā", "i": "i", "I": "ī", "u": "u", "U": "ū",
        "R": "ṛ", "Y": "ṝ", "L": "ḷ",
        "e": "e", "E": "ai", "o": "o", "O": "au",
        "M": "ṃ", "H": "ḥ", "w": "m̐",
        "k": "k", "K": "kh", "g": "g", "G": "gh", "F": "ṅ",
        "c": "c", "C": "ch", "j": "j", "J": "jh", "W": "ñ",
        "q": "ṭ", "Q": "ṭh", "x": "ḍ", "X": "ḍh", "N": "ṇ",
        "t": "t", "T": "th", "d": "d", "D": "dh", "n": "n",
        "p": "p", "P": "ph", "b": "b", "B": "bh", "m": "m",
        "y": "y", "r": "r", "l": "l", "v": "v",
        "Z": "ś", "S": "ṣ", "s": "s", "h": "h",
        "f": "ḷh",
        " ": " ", "-": "-", "'": "'", ".": ".", ",": ",", "\n": "\n",
    ]
}

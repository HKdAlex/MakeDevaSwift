import Foundation

/// Unicode IAST → MakeDeva ASCII ingest (IU-59 / custom path).
///
/// Inverse of `MakeDevaGlyphDecode.makeDevaASCIIToIAST`, then the same
/// ASCII digraphs `FileProcessor` applies after `bbt_uni2bbt` (`ai→E`, `au→O`,
/// `kh→K`, …). Does **not** call `IndicSandhi` / `prepareIAST` (ADR-23).
public enum MakeDevaIngest {
    /// Map normalized Unicode IAST to MakeDeva / Harvard-Kyoto-like ASCII.
    public static func iastToMakeDevaASCII(_ iast: String) -> String {
        let nfc = iast.precomposedStringWithCanonicalMapping
        var mapped = String()
        mapped.reserveCapacity(nfc.count)
        var i = nfc.startIndex
        while i < nfc.endIndex {
            if let (len, ascii) = matchGrapheme(nfc, at: i) {
                mapped.append(ascii)
                i = nfc.index(i, offsetBy: len)
            } else {
                mapped.append(nfc[i])
                i = nfc.index(after: i)
            }
        }
        return applyASCIIDigraphs(mapped)
    }

    // MARK: - IAST graphemes (longest first)

    private static func matchGrapheme(_ s: String, at i: String.Index) -> (Int, String)? {
        for (token, ascii) in iastTokens {
            guard s[i...].hasPrefix(token) else { continue }
            return (token.count, ascii)
        }
        return nil
    }

    /// Longest IAST spellings first so `ṭh` is not consumed as `ṭ` + `h`.
    private static let iastTokens: [(String, String)] = [
        ("m̐", "w"),
        // C Harvard-Kyoto `V` expands to `wl` (anunasika then `l`). Unicode IAST `l̐`
        // is coda `l` + candrabindu, so ingest is `lw` — otherwise a preceding vowel
        // steals `w` as anunasika (`vAwl` → वाँल, not ICU `वाल्̐`).
        ("l̐", "lw"),
        ("ḷh", "f"),
        ("kh", "K"), ("gh", "G"), ("ch", "C"), ("jh", "J"),
        ("ṭh", "Q"), ("ḍh", "X"), ("th", "T"), ("dh", "D"),
        ("ph", "P"), ("bh", "B"),
        ("ai", "E"), ("au", "O"),
        ("ṅ", "F"), ("ñ", "W"), ("ṇ", "N"),
        ("ś", "Z"), ("ṣ", "S"),
        ("ṛ", "R"), ("ṝ", "Y"), ("ḷ", "L"),
        ("ā", "A"), ("ī", "I"), ("ū", "U"),
        ("ṃ", "M"), ("ṁ", "M"), ("ḥ", "H"),
        ("k", "k"), ("g", "g"), ("c", "c"), ("j", "j"),
        ("ṭ", "q"), ("ḍ", "x"),
        ("t", "t"), ("d", "d"), ("n", "n"),
        ("p", "p"), ("b", "b"), ("m", "m"),
        ("y", "y"), ("r", "r"), ("l", "l"), ("v", "v"),
        ("s", "s"), ("h", "h"),
        ("a", "a"), ("i", "i"), ("u", "u"),
        ("e", "e"), ("o", "o"),
    ]

    /// FileProcessor / makedeva.c:1067–1084 digraphs on leftover ASCII pairs.
    private static func applyASCIIDigraphs(_ ascii: String) -> String {
        var chars = Array(ascii)
        var i = 0
        var out: [Character] = []
        out.reserveCapacity(chars.count)
        while i < chars.count {
            let c = chars[i]
            let next = i + 1 < chars.count ? chars[i + 1] : nil
            if next == "i", c == "a" {
                out.append("E")
                i += 2
                continue
            }
            if next == "u", c == "a" {
                out.append("O")
                i += 2
                continue
            }
            if next == "h" {
                let aspirated: Character? = switch c {
                case "k": "K"
                case "g": "G"
                case "c": "C"
                case "j": "J"
                case "q": "Q"
                case "x": "X"
                case "t": "T"
                case "d": "D"
                case "p": "P"
                case "b": "B"
                default: nil
                }
                if let mapped = aspirated {
                    out.append(mapped)
                    i += 2
                    continue
                }
            }
            out.append(c)
            i += 1
        }
        return String(out)
    }
}

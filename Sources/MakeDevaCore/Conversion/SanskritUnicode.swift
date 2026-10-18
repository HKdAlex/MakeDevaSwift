import Foundation

/// Literal Sanskrit IAST spelling → Unicode logical character order.
/// Structural spacing remains the caller's responsibility. Unlike ICU's general
/// Latin-Indic transform this does not accept ASCII "ddh" as an alias for ḍh,
/// assimilate explicit nasals, or consume avagraha. See MakeDevaSwift #20.
/// Unknown characters are retained, never silently deleted.
enum SanskritUnicode {
    /// House legacy spelling: BBT 0x8f / MakeDeva V denotes candrabindu + l.
    /// Expand before boundary handling as well as literal conversion.
    static func normalizeLegacyBBT(_ input: String) -> String {
        input.precomposedStringWithCanonicalMapping.replacingOccurrences(of: "ḻ", with: "m̐l")
    }

    static func transliterate(_ input: String) -> String {
        let text = normalizeLegacyBBT(input)
        var index = text.startIndex
        var output = ""
        var pendingConsonant = false
        func closeConsonant() {
            if pendingConsonant { output += "्" }
            pendingConsonant = false
        }
        while index < text.endIndex {
            let rest = text[index...]
            if rest.hasPrefix("l̐") {
                closeConsonant()
                output += "ल्ँ"
                index = text.index(after: index)
                continue
            }
            if rest.hasPrefix("m̐") {
                closeConsonant()
                output += "ँ"
                index = text.index(after: index)
                continue
            }
            if let token = consonants.first(where: { rest.hasPrefix($0.0) }) {
                closeConsonant()
                output += token.1
                pendingConsonant = true
                index = text.index(index, offsetBy: token.0.count)
            } else if let token = vowels.first(where: { rest.hasPrefix($0.0) }) {
                output += pendingConsonant ? token.2 : token.1
                pendingConsonant = false
                index = text.index(index, offsetBy: token.0.count)
            } else {
                closeConsonant()
                let character = text[index]
                output += marks[character] ?? String(character)
                index = text.index(after: index)
            }
        }
        closeConsonant()
        return output.precomposedStringWithCanonicalMapping
    }

    private static let consonants: [(String, String)] = [
        ("kh", "ख"), ("gh", "घ"), ("ch", "छ"), ("jh", "झ"),
        ("ṭh", "ठ"), ("ḍh", "ढ"), ("th", "थ"), ("dh", "ध"),
        ("ph", "फ"), ("bh", "भ"), ("ḷh", "ळ्ह"),
        ("k", "क"), ("g", "ग"), ("ṅ", "ङ"),
        ("c", "च"), ("j", "ज"), ("ñ", "ञ"),
        ("ṭ", "ट"), ("ḍ", "ड"), ("ṇ", "ण"),
        ("t", "त"), ("d", "द"), ("n", "न"),
        ("p", "प"), ("b", "ब"), ("m", "म"),
        ("y", "य"), ("r", "र"), ("l", "ल"), ("v", "व"),
        ("ś", "श"), ("ṣ", "ष"), ("s", "स"), ("h", "ह")
    ]
    private static let vowels: [(String, String, String)] = [
        ("ai", "ऐ", "ै"), ("au", "औ", "ौ"),
        ("a", "अ", ""), ("ā", "आ", "ा"),
        ("i", "इ", "ि"), ("ī", "ई", "ी"),
        ("u", "उ", "ु"), ("ū", "ऊ", "ू"),
        ("ṛ", "ऋ", "ृ"), ("ṝ", "ॠ", "ॄ"),
        ("ḷ", "ऌ", "ॢ"), ("ḹ", "ॡ", "ॣ"),
        ("e", "ए", "े"), ("o", "ओ", "ो")
    ]
    private static let marks: [Character: String] = [
        "ṁ": "ं", "ṃ": "ं", "ḥ": "ः", "'": "ऽ", "’": "ऽ",
        "0": "०", "1": "१", "2": "२", "3": "३", "4": "४",
        "5": "५", "6": "६", "7": "७", "8": "८", "9": "९"
    ]
}

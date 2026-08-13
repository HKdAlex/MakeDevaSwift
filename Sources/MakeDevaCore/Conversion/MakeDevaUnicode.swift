import BBTextIndicSandhi
import Foundation

/// Unicode Devanagari output path (UNI-08 / [#26](https://github.com/HKdAlex/BBText/issues/26)).
///
/// Documented entry API for merge-resolve and Unicode export.
///
/// Pipeline (ADR-23 amended / wayfinder #49 #53):
/// ```
/// normalized Unicode IAST
///   → structural prep (IndicSandhi — Unicode branch only)
///   → ICU pre-norm (ṛ→r̥, e/o→ē/ō)
///   → ICU Latin-Devanagari
/// ```
///
/// Custom font/encoding uses ingest (`bbt_uni2bbt`) → `LineConversion` and does **not**
/// call this type’s structural prep.
public enum MakeDevaUnicode {
    private static let latinToDevanagari = StringTransform(rawValue: "Latin-Devanagari")

    /// Structural prep + ICU transliteration to Unicode Devanagari.
    public static func convertLine(_ line: String) -> String {
        let prepared = prepareIAST(line)
        return transliterateToUnicodeDevanagari(prepared)
    }

    /// Structural prep for the **Unicode** branch only (ADR-23).
    ///
    /// Delegates to `IndicSandhi.closeSpaces` — whitespace collapse, MakeDeva `isnx`
    /// *n*-drop, coda-sibilant space-drop, coda-nasal+vowel space-drop, and avagraha
    /// space-drop ([#60](https://github.com/HKdAlex/BBText/issues/60),
    /// [#117](https://github.com/HKdAlex/BBText/issues/117),
    /// [#120](https://github.com/HKdAlex/BBText/issues/120)).
    /// No HKIndic pairwise joins. Does not apply ICU pre-normalization or script conversion.
    public static func prepareIAST(_ line: String) -> String {
        IndicSandhi.closeSpaces(in: line, script: .devanagari)
    }

    /// ICU script conversion only — caller supplies already-prepared IAST.
    public static func transliteratePreparedIAST(_ iast: String) -> String {
        transliterateToUnicodeDevanagari(iast)
    }

    /// Glyph → Unicode Devanagari (IU-58). Custom-path buffer; no `prepareIAST`.
    ///
    /// Mapping: `FontTables` (`devaline.c`) → MakeDeva ASCII → IAST → ICU.
    /// See `MakeDevaGlyphDecode`.
    public static func decodeUnicode(_ glyphs: [UInt8]) -> String {
        MakeDevaGlyphDecode.decodeUnicode(glyphs)
    }

    /// Custom path for a Unicode IAST line (IU-59): ingest → `LineConversion` → decode.
    ///
    /// Does **not** call `prepareIAST` (ADR-23).
    public static func customPathUnicode(_ iast: String) -> String {
        let ascii = MakeDevaIngest.iastToMakeDevaASCII(iast)
        let glyphs = LineConversion.convertLine(ascii).glyphs
        return decodeUnicode(glyphs)
    }

    /// NFC equality used by the cross-path oracle (documented ignorable equivalence).
    public static func unicodeEquivalent(_ a: String, _ b: String) -> Bool {
        a.precomposedStringWithCanonicalMapping == b.precomposedStringWithCanonicalMapping
    }

    // MARK: - Private

    private static func transliterateToUnicodeDevanagari(_ iast: String) -> String {
        let normalized = normalizeForICU(iast)
        return normalized.applyingTransform(latinToDevanagari, reverse: false) ?? normalized
    }

    /// ICU prerequisites (not structural sandhi). Must use `.literal` so diacritic
    /// letters (ā, ī, …) are not loosely matched to ṝ / e / o.
    private static func normalizeForICU(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\u{1E5B}", with: "r\u{0325}", options: .literal) // ṛ → r̥
            .replacingOccurrences(of: "\u{1E5D}", with: "r\u{0325}\u{0304}", options: .literal) // ṝ
            .replacingOccurrences(of: "e", with: "ē", options: .literal)
            .replacingOccurrences(of: "o", with: "ō", options: .literal)
    }
}

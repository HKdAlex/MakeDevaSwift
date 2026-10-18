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
///   → literal Sanskrit IAST spelling → Unicode logical order
/// ```
///
/// Custom font/encoding uses ingest (`bbt_uni2bbt`) → `LineConversion` and does **not**
/// call this type’s structural prep.
public enum MakeDevaUnicode {
    /// Structural prep + literal Sanskrit transliteration to Unicode Devanagari.
    public static func convertLine(_ line: String) -> String {
        let prepared = prepareIAST(line)
        // Keep stop+h separate until script mapping has fixed token identity.
        // C fontc half-forms close this word gap; explicit virama d/ṭ/ḍ do not.
        // Doing this in IAST would invent kh/gh/ch/jh/th/ph/bh aspirates.
        return transliterateToUnicodeDevanagari(prepared).replacingOccurrences(
            of: "([कगचजतपब]्) (?=ह)", with: "$1", options: .regularExpression
        )
    }

    /// Structural prep for the **Unicode** branch only (ADR-23).
    ///
    /// Delegates to IndicSandhi: horizontal whitespace, MakeDeva `isnx`,
    /// full-cluster coda boundaries and avagraha gaps (BBText ADR-23 / #217).
    /// Stops before h retain their source word gap to avoid inventing aspirates;
    /// `convertLine` handles the final half-form gap after literal script mapping.
    /// No HKIndic pairwise joins or ICU pre-normalization.
    public static func prepareIAST(_ line: String) -> String {
        IndicSandhi.closeSpaces(in: SanskritUnicode.normalizeLegacyBBT(line), script: .devanagari)
    }

    /// Literal Sanskrit script conversion only — caller supplies already-prepared IAST.
    public static func transliteratePreparedIAST(_ iast: String) -> String {
        transliterateToUnicodeDevanagari(iast)
    }

    /// Glyph → Unicode Devanagari (IU-58). Custom-path buffer; no `prepareIAST`.
    ///
    /// Mapping: `FontTables` (`devaline.c`) → MakeDeva ASCII → IAST → Unicode.
    /// See `MakeDevaGlyphDecode`.
    public static func decodeUnicode(_ glyphs: [UInt8]) -> String {
        MakeDevaGlyphDecode.decodeUnicode(glyphs)
    }

    /// Custom path for a Unicode IAST line (IU-59): ingest → `LineConversion` → decode.
    ///
    /// Does **not** call `prepareIAST` (ADR-23).
    public static func customPathUnicode(_ iast: String) -> String {
        // Semicolons are prose punctuation, not Sanskrit consonants. The
        // legacy font has no semicolon slot: byte 0x3B is the xr__ glyph.
        // Keep the separator outside glyph conversion, converting both spans
        // independently so neither adjacent syllable can absorb it. This API
        // returns Unicode; it does not claim a printable single-font buffer.
        return iast.components(separatedBy: ";").map { span in
            let ascii = MakeDevaIngest.iastToMakeDevaASCII(span)
            let glyphs = LineConversion.convertLine(ascii).glyphs
            return decodeUnicode(glyphs)
        }.joined(separator: ";")
    }

    /// NFC equality used by the cross-path oracle (documented ignorable equivalence).
    public static func unicodeEquivalent(_ a: String, _ b: String) -> Bool {
        a.precomposedStringWithCanonicalMapping == b.precomposedStringWithCanonicalMapping
    }

    // MARK: - Private

    private static func transliterateToUnicodeDevanagari(_ iast: String) -> String {
        SanskritUnicode.transliterate(iast)
    }
}

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
        return transliterateToUnicodeDevanagari(prepared)
    }

    /// Structural prep for the **Unicode** branch only (ADR-23).
    ///
    ///      Delegates to `IndicSandhi.closeSpaces` — whitespace collapse, MakeDeva `isnx`
    /// *n*-drop, coda-sibilant space-drop, coda-nasal+vowel space-drop, coda-`d`
    /// leftover-virama keep-space (`br` / `bhr` / non-`dh` `d`), and avagraha space-drop ([#60](https://github.com/HKdAlex/BBText/issues/60),
    /// [#117](https://github.com/HKdAlex/BBText/issues/117),
    /// [#120](https://github.com/HKdAlex/BBText/issues/120),
    /// [#136](https://github.com/HKdAlex/BBText/issues/136),
    /// [#140](https://github.com/HKdAlex/BBText/issues/140)).
    /// No HKIndic pairwise joins. Does not apply ICU pre-normalization or script conversion.
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

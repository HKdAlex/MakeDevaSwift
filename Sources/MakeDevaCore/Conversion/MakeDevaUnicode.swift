import BBTextIndicSandhi
import Foundation

/// Unicode Devanagari output path (UNI-08 / #26).
///
/// Custom font/encoding continues to use `LineConversion` until C parity goldens are
/// refreshed with the shared sandhi pre-pass. This type is the documented entry API
/// for merge-resolve and future Unicode export.
public enum MakeDevaUnicode {
    /// Apply shared IAST space-closing, then transliterate to Unicode Devanagari.
    ///
    /// Phase 1 (#32): sandhi pre-pass only; ICU transliteration lands in #26.
    public static func convertLine(_ line: String) -> String {
        let prepared = IndicSandhi.closeSpaces(in: line, script: .devanagari)
        return transliterateToUnicodeDevanagari(prepared)
    }

    /// Shared sandhi hook — call before **either** Unicode or custom-encoding conversion
    /// once parity goldens include the pre-pass (ADR-23).
    public static func prepareIAST(_ line: String) -> String {
        IndicSandhi.closeSpaces(in: line, script: .devanagari)
    }

  private static func transliterateToUnicodeDevanagari(_ iast: String) -> String {
        // #26: ICU transliteration; until then return sandhi-closed IAST for golden harness wiring.
        iast
    }
}

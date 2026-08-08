/// Font glyph tables for Devanagari conversion
///
/// These tables match the definitions in `devaline.c` lines 164-617.
/// They map Sanskrit transliteration strings to RM Devanagari font glyph codes.

import Foundation

/// Font information for consonants with vowels (FontInfoA in C source)
///
/// - transliteration: Sanskrit transliteration string (up to 3 characters)
/// - code: Array of glyph codes (1-4 bytes)
/// - uri: Flag indicating if u, uu, ri, rii, or lri vowel is possible (0 or 1)
/// - ya: Flag indicating if ya ligature is possible afterwards (0 or 1)
public struct FontInfoA: Sendable {
    public let transliteration: String
    public let code: [UInt8]
    public let uri: UInt8
    public let ya: UInt8

    public init(transliteration: String, code: [UInt8], uri: UInt8, ya: UInt8) {
        self.transliteration = transliteration
        self.code = code
        self.uri = uri
        self.ya = ya
    }
}

/// Font information for consonants without vowels (FontInfoC in C source)
///
/// - transliteration: Sanskrit transliteration string (up to 3 characters)
/// - code: Array of glyph codes (1-4 bytes)
public struct FontInfoC: Sendable {
    public let transliteration: String
    public let code: [UInt8]

    public init(transliteration: String, code: [UInt8]) {
        self.transliteration = transliteration
        self.code = code
    }
}

/// Helper function to create code array from C-style initialization
/// Filters out trailing zeros to match actual used bytes
private func code(_ bytes: UInt8...) -> [UInt8] {
    var result = bytes
    // Remove trailing zeros (but keep at least one byte)
    while result.count > 1 && result.last == 0 {
        result.removeLast()
    }
    return result
}

/// Font tables for consonants with 'u' vowel (fontu[] in C source, lines 200-233)
///
/// Contains 31 entries matching C source exactly.
public enum FontTables {
    public static let fontu: [FontInfoC] = [
        FontInfoC(transliteration: "F", code: code(0x78, 0x5D, 0x20, FontConstants.F___)),
        FontInfoC(transliteration: "Fr", code: code(0x78, 0x5F, 0x20, FontConstants.F___)),
        FontInfoC(transliteration: "Fk", code: code(FontConstants.xku_, 0x20, FontConstants.f___)),
        FontInfoC(transliteration: "Fg", code: code(FontConstants.xgu_, 0x20, FontConstants.f___)),
        FontInfoC(transliteration: "C", code: code(0x43, 0x5D, 0x20, FontConstants.D090)),
        FontInfoC(transliteration: "Cr", code: code(0x43, 0x5F, 0x20, FontConstants.D090)),
        FontInfoC(transliteration: "q", code: code(0x71, 0x20, FontConstants.D120, 0x5D)),
        FontInfoC(transliteration: "qr", code: code(0x71, 0x20, FontConstants.D120, 0x5F)),
        FontInfoC(transliteration: "Q", code: code(0x51, 0x20, FontConstants.D150, 0x5D)),
        FontInfoC(transliteration: "Qr", code: code(0x51, 0x20, FontConstants.D150, 0x5F)),
        FontInfoC(transliteration: "x", code: code(0x78, 0x20, FontConstants.D030, 0x5D)),
        FontInfoC(transliteration: "xr", code: code(0x78, 0x20, FontConstants.D030, 0x5F)),
        FontInfoC(transliteration: "xg", code: code(FontConstants.xgu_, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "X", code: code(0x58, 0x20, FontConstants.D060, 0x5D)),
        FontInfoC(transliteration: "Xr", code: code(0x58, 0x20, FontConstants.D060, 0x5F)),
        FontInfoC(
            transliteration: "d", code: code(FontConstants.d___, 0x75, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "dr", code: code(FontConstants.dr__, 0x75, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "dg", code: code(FontConstants.dgu_, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "r", code: code(FontConstants.ru__, 0x20, FontConstants.D150)),
        FontInfoC(
            transliteration: "Sq", code: code(FontConstants.Sqa_, 0x5D, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "Sqr", code: code(FontConstants.Sqa_, 0x5F, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "SQ", code: code(FontConstants.SQa_, 0x5D, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "SQr", code: code(FontConstants.SQa_, 0x5F, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "h", code: code(FontConstants.hu__, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hr",
            code: code(FontConstants.hra_, FontConstants.u_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hn",
            code: code(FontConstants.hna_, FontConstants.u_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hN",
            code: code(FontConstants.hNa_, FontConstants.u_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hl",
            code: code(FontConstants.hla_, FontConstants.u_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hv",
            code: code(FontConstants.hva_, FontConstants.u_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "f", code: code(FontConstants.lha_, 0x20, FontConstants.D150, 0x5D)),
        FontInfoC(
            transliteration: "fr", code: code(FontConstants.lha_, 0x20, FontConstants.D150, 0x5F)),
    ]

    /// Font tables for consonants with 'U' vowel (fontuu[] in C source, lines 236-265)
    ///
    /// Contains 27 entries matching C source exactly.
    public static let fontuu: [FontInfoC] = [
        FontInfoC(transliteration: "F", code: code(0x78, 0x5E, 0x20, FontConstants.F___)),
        FontInfoC(transliteration: "Fr", code: code(0x78, 0x60, 0x20, FontConstants.F___)),
        FontInfoC(transliteration: "C", code: code(0x43, 0x5E, 0x20, FontConstants.D090)),
        FontInfoC(transliteration: "Cr", code: code(0x43, 0x60, 0x20, FontConstants.D090)),
        FontInfoC(transliteration: "q", code: code(0x71, 0x20, FontConstants.D120, 0x5E)),
        FontInfoC(transliteration: "qr", code: code(0x71, 0x20, FontConstants.D120, 0x60)),
        FontInfoC(transliteration: "Q", code: code(0x51, 0x20, FontConstants.D150, 0x5E)),
        FontInfoC(transliteration: "Qr", code: code(0x51, 0x20, FontConstants.D150, 0x60)),
        FontInfoC(transliteration: "x", code: code(0x78, 0x20, FontConstants.D030, 0x5E)),
        FontInfoC(transliteration: "xr", code: code(0x78, 0x20, FontConstants.D030, 0x60)),
        FontInfoC(transliteration: "X", code: code(0x58, 0x20, FontConstants.D060, 0x5E)),
        FontInfoC(transliteration: "Xr", code: code(0x58, 0x20, FontConstants.D060, 0x60)),
        FontInfoC(
            transliteration: "d", code: code(FontConstants.d___, 0x55, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "dr", code: code(FontConstants.dr__, 0x55, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "r", code: code(FontConstants.rU__, 0x20, FontConstants.D150)),
        FontInfoC(
            transliteration: "Sq", code: code(FontConstants.Sqa_, 0x5E, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "Sqr", code: code(FontConstants.Sqa_, 0x60, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "SQ", code: code(FontConstants.SQa_, 0x5E, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "SQr", code: code(FontConstants.SQa_, 0x60, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "h", code: code(FontConstants.hU__, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hr",
            code: code(FontConstants.hra_, FontConstants.U_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hn",
            code: code(FontConstants.hna_, FontConstants.U_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hN",
            code: code(FontConstants.hNa_, FontConstants.U_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hl",
            code: code(FontConstants.hla_, FontConstants.U_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hv",
            code: code(FontConstants.hva_, FontConstants.U_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "f", code: code(FontConstants.lha_, 0x20, FontConstants.D150, 0x5E)),
        FontInfoC(
            transliteration: "fr", code: code(FontConstants.lha_, 0x20, FontConstants.D150, 0x60)),
    ]

    /// Font tables for consonants with 'R' vowel (fontR[] in C source, lines 268-288)
    ///
    /// Contains 18 entries matching C source exactly.
    public static let fontR: [FontInfoC] = [
        FontInfoC(transliteration: "F", code: code(0x78, 0x2B, 0x20, FontConstants.F___)),
        FontInfoC(transliteration: "C", code: code(0x43, 0x2B, 0x20, FontConstants.D090)),
        FontInfoC(transliteration: "q", code: code(0x71, 0x20, FontConstants.D120, 0x2B)),
        FontInfoC(transliteration: "Q", code: code(0x51, 0x20, FontConstants.D150, 0x2B)),
        FontInfoC(transliteration: "x", code: code(0x78, 0x20, FontConstants.D030, 0x2B)),
        FontInfoC(transliteration: "X", code: code(0x58, 0x20, FontConstants.D060, 0x2B)),
        FontInfoC(
            transliteration: "d", code: code(FontConstants.d___, 0x7B, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "dr", code: code(FontConstants.dr__, 0x7B, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "r", code: code(0x01)),
        FontInfoC(transliteration: "Z", code: code(0x5A, 0x61, 0x7B, 0x20)),
        FontInfoC(
            transliteration: "Sq", code: code(FontConstants.Sqa_, 0x2B, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "SQ", code: code(FontConstants.SQa_, 0x2B, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "h", code: code(FontConstants.hR__, 0x20, FontConstants.D090)),
        FontInfoC(
            transliteration: "hn",
            code: code(FontConstants.hna_, FontConstants.R_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hN",
            code: code(FontConstants.hNa_, FontConstants.R_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hl",
            code: code(FontConstants.hla_, FontConstants.R_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "hv",
            code: code(FontConstants.hva_, FontConstants.R_h_, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "f", code: code(FontConstants.lha_, 0x20, FontConstants.D150, 0x2B)),
    ]

    /// Font tables for consonants with 'Y' vowel (fontY[] in C source, lines 291-297)
    ///
    /// Contains 4 entries matching C source exactly.
    public static let fontY: [FontInfoC] = [
        FontInfoC(
            transliteration: "d", code: code(FontConstants.d___, 0x7C, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "dr", code: code(FontConstants.dr__, 0x7C, 0x20, FontConstants.D030)),
        FontInfoC(transliteration: "r", code: code(0x02)),
        FontInfoC(transliteration: "Z", code: code(0x5A, 0x61, 0x7C, 0x20)),
    ]

    /// Font tables for consonants with 'L' vowel (fontL[] in C source, lines 300-304)
    ///
    /// Contains 2 entries matching C source exactly.
    public static let fontL: [FontInfoC] = [
        FontInfoC(
            transliteration: "d", code: code(FontConstants.d___, 0x7D, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "dr", code: code(FontConstants.dr__, 0x7D, 0x20, FontConstants.D030)),
    ]

    /// Font tables for consonants with virama (fontv[] in C source, lines 307-317)
    ///
    /// Contains 8 entries matching C source exactly.
    public static let fontv: [FontInfoC] = [
        FontInfoC(transliteration: "F", code: code(0x78, 0x2E, 0x20, FontConstants.F___)),
        FontInfoC(transliteration: "C", code: code(0x43, 0x2E, 0x20, FontConstants.D090)),
        FontInfoC(transliteration: "q", code: code(0x71, 0x20, FontConstants.D120, 0x2E)),
        FontInfoC(transliteration: "Q", code: code(0x51, 0x20, FontConstants.D150, 0x2E)),
        FontInfoC(transliteration: "x", code: code(0x78, 0x20, FontConstants.D030, 0x2E)),
        FontInfoC(transliteration: "X", code: code(0x58, 0x20, FontConstants.D060, 0x2E)),
        FontInfoC(
            transliteration: "d", code: code(FontConstants.d___, 0x2C, 0x20, FontConstants.D030)),
        FontInfoC(
            transliteration: "f", code: code(FontConstants.lha_, 0x20, FontConstants.D150, 0x2E)),
    ]

    /// Font tables for consonants with other vowels (fonta[] in C source, lines 320-510)
    ///
    /// Contains 110 entries matching C source exactly.
    public static let fonta: [FontInfoA] = [
        FontInfoA(transliteration: "k", code: code(0x6B, 0x20, FontConstants.D270), uri: 1, ya: 0),
        FontInfoA(
            transliteration: "kr", code: code(FontConstants.kra_, 0x20, FontConstants.D270), uri: 1,
            ya: 0),
        FontInfoA(
            transliteration: "kn", code: code(FontConstants.kna_, 0x20, FontConstants.D270), uri: 1,
            ya: 0),
        FontInfoA(
            transliteration: "kt", code: code(FontConstants.kta_, 0x20, FontConstants.D270), uri: 1,
            ya: 0),
        FontInfoA(
            transliteration: "kv", code: code(FontConstants.kva_, 0x20, FontConstants.D270), uri: 1,
            ya: 0),
        FontInfoA(transliteration: "kS", code: code(FontConstants.kS__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "kSr", code: code(FontConstants.kSr_, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "K", code: code(0x4B, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Kr", code: code(0x4B, FontConstants.xr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "g", code: code(0x67, 0x41), uri: 1, ya: 0),
        FontInfoA(transliteration: "gr", code: code(FontConstants.gr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "gn", code: code(FontConstants.gn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "G", code: code(0x47, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Gr", code: code(FontConstants.Gr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Gn", code: code(FontConstants.Gn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "F", code: code(0x78, 0x20, FontConstants.F___), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "Fr", code: code(0x78, 0x29, 0x20, FontConstants.F___), uri: 0, ya: 1),
        FontInfoA(
            transliteration: "Fk", code: code(FontConstants.xka_, 0x20, FontConstants.f___), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "Fkt", code: code(FontConstants.xkta, 0x20, FontConstants.f___),
            uri: 0, ya: 1),
        FontInfoA(
            transliteration: "FkS", code: code(FontConstants.xkSa, 0x20, FontConstants.f___),
            uri: 0, ya: 1),
        FontInfoA(
            transliteration: "FK", code: code(FontConstants.xKa_, 0x20, FontConstants.f___), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "Fg", code: code(FontConstants.xga_, 0x20, FontConstants.f___), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "Fgr", code: code(FontConstants.xgra, 0x20, FontConstants.f___),
            uri: 0, ya: 1),
        FontInfoA(
            transliteration: "FG", code: code(FontConstants.xGa_, 0x20, FontConstants.f___), uri: 0,
            ya: 1),
        FontInfoA(transliteration: "c", code: code(0x63, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "cr", code: code(FontConstants.cr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "cc", code: code(FontConstants.cc__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "cW", code: code(FontConstants.cW__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "C", code: code(0x43, 0x20, FontConstants.D090), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "Cr", code: code(0x43, 0x29, 0x20, FontConstants.D090), uri: 0, ya: 1),
        FontInfoA(transliteration: "j", code: code(0x6A, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "jr", code: code(FontConstants.jr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "jj", code: code(FontConstants.jj__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "jW", code: code(FontConstants.jW__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "J", code: code(0x4A, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Jr", code: code(0x4A, FontConstants.xr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "W", code: code(0x48, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Wr", code: code(0x48, FontConstants.xr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Wc", code: code(FontConstants.Wc__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Wj", code: code(FontConstants.Wj__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "q", code: code(0x71, 0x20, FontConstants.D120), uri: 1, ya: 0),
        FontInfoA(
            transliteration: "qy", code: code(0x71, FontConstants.D030, 0x59, 0x61), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "qr", code: code(0x71, 0x20, FontConstants.D120, 0x29), uri: 0, ya: 1),
        FontInfoA(
            transliteration: "qq", code: code(FontConstants.qqa_, 0x20, FontConstants.D120), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "qv", code: code(FontConstants.qva_, 0x20, FontConstants.D120), uri: 0,
            ya: 1),
        FontInfoA(transliteration: "Q", code: code(0x51, 0x20, FontConstants.D150), uri: 1, ya: 0),
        FontInfoA(
            transliteration: "Qy", code: code(0x51, FontConstants.D090, 0x59, 0x61), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "Qr", code: code(0x51, 0x20, FontConstants.D150, 0x29), uri: 0, ya: 1),
        FontInfoA(transliteration: "x", code: code(0x78, 0x20, FontConstants.D030), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "xr", code: code(0x78, 0x20, FontConstants.D030, 0x29), uri: 0, ya: 1),
        FontInfoA(
            transliteration: "xg", code: code(FontConstants.xga_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "xgr", code: code(FontConstants.xgra, 0x20, FontConstants.D030),
            uri: 0, ya: 1),
        FontInfoA(
            transliteration: "xG", code: code(FontConstants.xGa_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "xx", code: code(FontConstants.xxa_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "xB", code: code(FontConstants.xBa_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "xv", code: code(FontConstants.xva_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(transliteration: "X", code: code(0x58, 0x20, FontConstants.D060), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "Xr", code: code(0x58, 0x20, FontConstants.D060, 0x29), uri: 0, ya: 1),
        FontInfoA(
            transliteration: "Xv", code: code(FontConstants.Xva_, 0x20, FontConstants.D060), uri: 0,
            ya: 1),
        FontInfoA(transliteration: "N", code: code(0x4E, 0x41), uri: 1, ya: 0),
        FontInfoA(
            transliteration: "Nr", code: code(0x4E, FontConstants.D120, FontConstants.xr__, 0x61),
            uri: 1, ya: 0),
        FontInfoA(transliteration: "t", code: code(0x74, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "tr", code: code(FontConstants.tr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "tn", code: code(FontConstants.tn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "tt", code: code(FontConstants.tt__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "T", code: code(0x54, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Tr", code: code(FontConstants.Tr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Tn", code: code(FontConstants.Tn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "d", code: code(0x64, 0x20, FontConstants.D030), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "dr", code: code(FontConstants.dra_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "dn", code: code(FontConstants.dna_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "dg", code: code(FontConstants.dga_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "dgr", code: code(FontConstants.dgra, 0x20, FontConstants.D030),
            uri: 0, ya: 1),
        FontInfoA(
            transliteration: "dG", code: code(FontConstants.dGa_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "dd", code: code(FontConstants.dda_, 0x20, FontConstants.D030), uri: 0,
            ya: 0),
        FontInfoA(
            transliteration: "ddr", code: code(FontConstants.ddra, 0x20, FontConstants.D030),
            uri: 0, ya: 1),
        FontInfoA(
            transliteration: "dD", code: code(FontConstants.dDa_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "db", code: code(FontConstants.dba_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "dB", code: code(FontConstants.dBa_, 0x20, FontConstants.D030), uri: 1,
            ya: 1),
        FontInfoA(transliteration: "dm", code: code(FontConstants.dma_), uri: 1, ya: 1),
        FontInfoA(transliteration: "dy", code: code(FontConstants.dya_), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "dv", code: code(FontConstants.dva_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(transliteration: "D", code: code(0x44, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Dr", code: code(FontConstants.Dr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Dn", code: code(FontConstants.Dn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "n", code: code(0x6E, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "nn", code: code(FontConstants.nn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "p", code: code(0x70, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "pr", code: code(FontConstants.pr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "pn", code: code(FontConstants.pn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "pt", code: code(FontConstants.pt__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "P", code: code(0x50, 0x20, FontConstants.D270), uri: 1, ya: 0),
        FontInfoA(
            transliteration: "Pr", code: code(FontConstants.Pra_, 0x20, FontConstants.D270), uri: 1,
            ya: 1),
        FontInfoA(
            transliteration: "Pn", code: code(FontConstants.Pna_, 0x20, FontConstants.D270), uri: 1,
            ya: 1),
        FontInfoA(transliteration: "b", code: code(0x62, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "br", code: code(FontConstants.br__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "bn", code: code(FontConstants.bn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "B", code: code(0x42, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Br", code: code(FontConstants.Br__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Bn", code: code(FontConstants.Bn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "m", code: code(0x6D, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "mr", code: code(FontConstants.mr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "mn", code: code(FontConstants.mn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "y", code: code(0x79, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "yr", code: code(0x79, FontConstants.xr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "r", code: code(0x72, 0x20, FontConstants.D030), uri: 1, ya: 0),
        FontInfoA(transliteration: "l", code: code(0x6C, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "lr", code: code(0x6C, FontConstants.xr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "ll", code: code(FontConstants.ll__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "v", code: code(0x76, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "vr", code: code(FontConstants.vr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "vn", code: code(FontConstants.vn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Z", code: code(0x7A, 0x41), uri: 1, ya: 0),
        FontInfoA(transliteration: "Zr", code: code(FontConstants.Zr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Zn", code: code(FontConstants.Zn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Zc", code: code(FontConstants.Zca_), uri: 1, ya: 0),
        FontInfoA(transliteration: "Zl", code: code(FontConstants.Zla_), uri: 1, ya: 0),
        FontInfoA(transliteration: "Zv", code: code(FontConstants.Zva_), uri: 1, ya: 0),
        FontInfoA(transliteration: "S", code: code(0x53, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "Sr", code: code(0x53, FontConstants.xr__, 0x61), uri: 1, ya: 0),
        FontInfoA(
            transliteration: "Sq", code: code(FontConstants.Sqa_, 0x20, FontConstants.D030), uri: 1,
            ya: 1),
        FontInfoA(
            transliteration: "Sqr", code: code(FontConstants.Sqa_, 0x29, 0x20, FontConstants.D030),
            uri: 0, ya: 1),
        FontInfoA(
            transliteration: "Sqv", code: code(FontConstants.Sqva, 0x20, FontConstants.D030),
            uri: 0, ya: 1),
        FontInfoA(
            transliteration: "SQ", code: code(FontConstants.SQa_, 0x20, FontConstants.D030), uri: 1,
            ya: 1),
        FontInfoA(
            transliteration: "SQr", code: code(FontConstants.SQa_, 0x29, 0x20, FontConstants.D030),
            uri: 0, ya: 1),
        FontInfoA(transliteration: "s", code: code(0x73, FontConstants.D090, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sr", code: code(FontConstants.sr__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sn", code: code(FontConstants.sn__, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sK", code: code(0x73, 0x4B, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sC", code: code(0x73, 0x43, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "st", code: code(0x73, 0x74, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sT", code: code(0x73, 0x54, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sd", code: code(0x73, 0x64, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sD", code: code(0x73, 0x44, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sm", code: code(0x73, 0x6D, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sy", code: code(0x73, 0x79, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sl", code: code(0x73, 0x6C, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "sv", code: code(0x73, 0x76, 0x61), uri: 1, ya: 0),
        FontInfoA(
            transliteration: "ss", code: code(0x73, 0x73, FontConstants.D090, 0x61), uri: 1, ya: 0),
        FontInfoA(transliteration: "str", code: code(FontConstants.stra), uri: 1, ya: 0),
        FontInfoA(transliteration: "h", code: code(0x68, 0x20, FontConstants.D030), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "hr", code: code(FontConstants.hra_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "hn", code: code(FontConstants.hna_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "hN", code: code(FontConstants.hNa_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(transliteration: "hm", code: code(FontConstants.hma_), uri: 1, ya: 1),
        FontInfoA(transliteration: "hy", code: code(FontConstants.hya_), uri: 1, ya: 1),
        FontInfoA(
            transliteration: "hl", code: code(FontConstants.hla_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "hv", code: code(FontConstants.hva_, 0x20, FontConstants.D030), uri: 0,
            ya: 1),
        FontInfoA(
            transliteration: "f", code: code(FontConstants.lha_, 0x20, FontConstants.D150), uri: 1,
            ya: 0),
        FontInfoA(
            transliteration: "fy", code: code(FontConstants.lha_, FontConstants.D090, 0x59, 0x61),
            uri: 1, ya: 1),
        FontInfoA(
            transliteration: "fr", code: code(FontConstants.lha_, 0x20, FontConstants.D150, 0x29),
            uri: 0, ya: 1),
    ]

    /// Font tables for consonants without vowel (fontc[] in C source, lines 513-617)
    ///
    /// Contains 61 entries matching C source exactly.
    public static let fontc: [FontInfoC] = [
        FontInfoC(transliteration: "k", code: code(0x66)),
        FontInfoC(transliteration: "kS", code: code(FontConstants.kS__)),
        FontInfoC(transliteration: "kSr", code: code(FontConstants.kSr_)),
        FontInfoC(transliteration: "K", code: code(0x4B)),
        FontInfoC(transliteration: "Kr", code: code(0x4B, FontConstants.xr__)),
        FontInfoC(transliteration: "g", code: code(0x67)),
        FontInfoC(transliteration: "gr", code: code(FontConstants.gr__)),
        FontInfoC(transliteration: "G", code: code(0x47)),
        FontInfoC(transliteration: "Gr", code: code(FontConstants.Gr__)),
        FontInfoC(transliteration: "F", code: code(0x78, 0x20, 0x2E, FontConstants.F___)),
        FontInfoC(transliteration: "c", code: code(0x63)),
        FontInfoC(transliteration: "cr", code: code(FontConstants.cr__)),
        FontInfoC(transliteration: "C", code: code(0x43, 0x20, 0x2E, FontConstants.D090)),
        FontInfoC(transliteration: "j", code: code(0x6A)),
        FontInfoC(transliteration: "jr", code: code(FontConstants.jr__)),
        FontInfoC(transliteration: "J", code: code(0x4A)),
        FontInfoC(transliteration: "Jr", code: code(0x4A, FontConstants.xr__)),
        FontInfoC(transliteration: "W", code: code(0x48)),
        FontInfoC(transliteration: "Wr", code: code(0x48, FontConstants.xr__)),
        FontInfoC(transliteration: "q", code: code(0x71, 0x20, FontConstants.D120, 0x2E)),
        FontInfoC(transliteration: "Q", code: code(0x51, 0x20, FontConstants.D150, 0x2E)),
        FontInfoC(transliteration: "x", code: code(0x78, 0x20, FontConstants.D030, 0x2E)),
        FontInfoC(transliteration: "X", code: code(0x58, 0x20, FontConstants.D060, 0x2E)),
        FontInfoC(transliteration: "N", code: code(0x4E)),
        FontInfoC(transliteration: "Nr", code: code(0x4E, FontConstants.D120, FontConstants.xr__)),
        FontInfoC(transliteration: "t", code: code(0x74)),
        FontInfoC(transliteration: "tr", code: code(FontConstants.tr__)),
        FontInfoC(transliteration: "tt", code: code(FontConstants.tt__)),
        FontInfoC(transliteration: "T", code: code(0x54)),
        FontInfoC(transliteration: "Tr", code: code(FontConstants.Tr__)),
        FontInfoC(
            transliteration: "d", code: code(FontConstants.d___, 0x20, 0x2C, FontConstants.D030)),
        FontInfoC(transliteration: "D", code: code(0x44)),
        FontInfoC(transliteration: "Dr", code: code(FontConstants.Dr__)),
        FontInfoC(transliteration: "n", code: code(0x6E)),
        FontInfoC(transliteration: "nr", code: code(FontConstants.nr__)),
        FontInfoC(transliteration: "nn", code: code(FontConstants.nn__)),
        FontInfoC(transliteration: "p", code: code(0x70)),
        FontInfoC(transliteration: "pr", code: code(FontConstants.pr__)),
        FontInfoC(transliteration: "P", code: code(0x46)),
        FontInfoC(transliteration: "b", code: code(0x62)),
        FontInfoC(transliteration: "br", code: code(FontConstants.br__)),
        FontInfoC(transliteration: "B", code: code(0x42)),
        FontInfoC(transliteration: "Br", code: code(FontConstants.Br__)),
        FontInfoC(transliteration: "m", code: code(0x6D)),
        FontInfoC(transliteration: "mr", code: code(FontConstants.mr__)),
        FontInfoC(transliteration: "y", code: code(0x79)),
        FontInfoC(transliteration: "yr", code: code(0x79, FontConstants.xr__)),
        FontInfoC(transliteration: "r", code: code(0x72, 0x20, 0x2C, FontConstants.D030)),
        FontInfoC(transliteration: "l", code: code(0x6C)),
        FontInfoC(transliteration: "lr", code: code(0x6C, FontConstants.xr__)),
        FontInfoC(transliteration: "ll", code: code(FontConstants.ll__)),
        FontInfoC(transliteration: "v", code: code(0x76)),
        FontInfoC(transliteration: "vr", code: code(FontConstants.vr__)),
        FontInfoC(transliteration: "Z", code: code(0x7A)),
        FontInfoC(transliteration: "Zr", code: code(FontConstants.Zr__)),
        FontInfoC(transliteration: "S", code: code(0x53)),
        FontInfoC(transliteration: "Sr", code: code(0x53, FontConstants.xr__)),
        FontInfoC(transliteration: "s", code: code(0x73, FontConstants.D090)),
        FontInfoC(transliteration: "sr", code: code(FontConstants.sr__)),
        FontInfoC(transliteration: "st", code: code(0x73, 0x74)),
        FontInfoC(transliteration: "str", code: code(0x73, FontConstants.D090, FontConstants.tr__)),
        FontInfoC(transliteration: "sm", code: code(0x73, 0x6D)),
        FontInfoC(transliteration: "smr", code: code(0x73, FontConstants.D090, FontConstants.mr__)),
        FontInfoC(transliteration: "sy", code: code(0x73, 0x79)),
        FontInfoC(transliteration: "sv", code: code(0x73, 0x76)),
        FontInfoC(transliteration: "svr", code: code(0x73, FontConstants.D090, FontConstants.vr__)),
        FontInfoC(transliteration: "h", code: code(0x68, 0x20, 0x2E, FontConstants.D030)),
        FontInfoC(
            transliteration: "hr", code: code(FontConstants.hra_, 0x20, FontConstants.D030, 0x2C)),
        FontInfoC(
            transliteration: "f", code: code(FontConstants.lha_, 0x20, FontConstants.D150, 0x2E)),
        // Pass-through for special characters that appear in input but aren't standard Sanskrit
        // { outputs as 0x7B followed by 0x22 (D030) in the Devanagari font
        FontInfoC(transliteration: "{", code: code(0x7B, FontConstants.D030)),
    ]
}

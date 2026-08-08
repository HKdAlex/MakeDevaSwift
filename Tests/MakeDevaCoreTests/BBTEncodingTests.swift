import Testing

@testable import MakeDevaCore

struct BBTEncodingTests {
    
    // MARK: - BBT to Unicode Conversion Tests
    
    @Test func bbtToUnicodeASCII() {
        // ASCII characters should map directly
        #expect(BBTEncoding.bbtToUnicode(0x00) == 0x0000)
        #expect(BBTEncoding.bbtToUnicode(0x20) == 0x0020)  // space
        #expect(BBTEncoding.bbtToUnicode(0x41) == 0x0041)  // 'A'
        #expect(BBTEncoding.bbtToUnicode(0x61) == 0x0061)  // 'a'
        #expect(BBTEncoding.bbtToUnicode(0x7F) == 0x007F)
    }
    
    @Test func bbtToUnicodeDevanagariDiacritics() {
        // Test BBT-specific Devanagari diacritics (0x80-0x9F)
        #expect(BBTEncoding.bbtToUnicode(0x80) == 0x015B)  // ś
        #expect(BBTEncoding.bbtToUnicode(0x81) == 0x016B)  // ū
        #expect(BBTEncoding.bbtToUnicode(0x82) == 0x1E5B)  // ṛ
        #expect(BBTEncoding.bbtToUnicode(0x90) == 0x015A)  // Ś
        #expect(BBTEncoding.bbtToUnicode(0x91) == 0x016A)  // Ū
        #expect(BBTEncoding.bbtToUnicode(0x9F) == 0x1E3F)  // ṿ
    }
    
    @Test func bbtToUnicodeEmDash() {
        // Em-dash is at 0xC5
        #expect(BBTEncoding.bbtToUnicode(0xC5) == 0x2014)  // em-dash
    }
    
    // MARK: - Windows to Unicode Conversion Tests
    
    @Test func windowsToUnicodeASCII() {
        // ASCII characters should map directly
        #expect(BBTEncoding.windowsToUnicode(0x00) == 0x0000)
        #expect(BBTEncoding.windowsToUnicode(0x20) == 0x0020)  // space
        #expect(BBTEncoding.windowsToUnicode(0x41) == 0x0041)  // 'A'
        #expect(BBTEncoding.windowsToUnicode(0x61) == 0x0061)  // 'a'
        #expect(BBTEncoding.windowsToUnicode(0x7F) == 0x007F)
    }
    
    @Test func windowsToUnicodeSpecialCharacters() {
        // Test Windows-1252 specific characters
        #expect(BBTEncoding.windowsToUnicode(0x80) == 0x20AC)  // €
        #expect(BBTEncoding.windowsToUnicode(0x82) == 0x201A)  // ‚
        #expect(BBTEncoding.windowsToUnicode(0x85) == 0x2026)  // …
        #expect(BBTEncoding.windowsToUnicode(0x9F) == 0x0178)  // Ÿ
    }
    
    // MARK: - Unicode to BBT Conversion Tests
    
    @Test func unicodeToBBTASCII() {
        // ASCII characters (< 128) should map directly
        #expect(BBTEncoding.unicodeToBBT(0x0000) == 0x00)
        #expect(BBTEncoding.unicodeToBBT(0x0020) == 0x20)  // space
        #expect(BBTEncoding.unicodeToBBT(0x0041) == 0x41)  // 'A'
        #expect(BBTEncoding.unicodeToBBT(0x0061) == 0x61)  // 'a'
        #expect(BBTEncoding.unicodeToBBT(0x007F) == 0x7F)
    }
    
    @Test func unicodeToBBTDevanagariDiacritics() {
        // Test round-trip for BBT diacritics (0x80-0x9F)
        // These should round-trip: bbtToUnicode(unicodeToBBT(x)) == x
        #expect(BBTEncoding.unicodeToBBT(0x015B) == 0x80)  // ś
        #expect(BBTEncoding.unicodeToBBT(0x016B) == 0x81)  // ū
        #expect(BBTEncoding.unicodeToBBT(0x1E5B) == 0x82)  // ṛ
        #expect(BBTEncoding.unicodeToBBT(0x015A) == 0x90)  // Ś
        #expect(BBTEncoding.unicodeToBBT(0x016A) == 0x91)  // Ū
        #expect(BBTEncoding.unicodeToBBT(0x1E3F) == 0x9F)  // ṿ
    }
    
    @Test func unicodeToBBTEmDash() {
        // Em-dash special case: 0x2014 -> 197 (0xC5)
        #expect(BBTEncoding.unicodeToBBT(0x2014) == 197)  // em-dash
    }
    
    @Test func unicodeToBBTInvalidRange() {
        // Code points >= 0x2100 should return nil
        #expect(BBTEncoding.unicodeToBBT(0x2100) == nil)
        #expect(BBTEncoding.unicodeToBBT(0x3000) == nil)
        #expect(BBTEncoding.unicodeToBBT(0xFFFF) == nil)
    }
    
    @Test func unicodeToBBTRoundTrip() {
        // Test round-trip conversion for valid BBT characters (0x80-0x9F)
        for i in 0x80..<0xA0 {
            let unicode = BBTEncoding.bbtToUnicode(UInt8(i))
            let backToBBT = BBTEncoding.unicodeToBBT(unicode)
            #expect(backToBBT == UInt8(i), "Round-trip failed for 0x\(String(i, radix: 16)) -> 0x\(String(unicode, radix: 16)) -> \(backToBBT?.description ?? "nil")")
        }
        
        // Test em-dash round-trip
        #expect(BBTEncoding.unicodeToBBT(0x2014) == 0xC5)
        #expect(BBTEncoding.bbtToUnicode(0xC5) == 0x2014)
    }
}

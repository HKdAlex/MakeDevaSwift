import Testing

@testable import MakeDevaCore

struct EncodingTablesTests {
    
    // MARK: - Array Size Tests
    
    @Test func bbtToUnicodeSize() {
        #expect(EncodingTables.bbtToUnicode.count == 256)
    }
    
    @Test func windowsToUnicodeSize() {
        #expect(EncodingTables.windowsToUnicode.count == 256)
    }
    
    @Test func charConvSize() {
        #expect(EncodingTables.charConv.count == 31, "charConv should have 31 elements (verified from C source)")
    }
    
    // MARK: - Sample Value Tests
    
    @Test func bbtToUnicodeSampleValues() {
        // Test ASCII range (0x00-0x7F) - should map directly
        #expect(EncodingTables.bbtToUnicode[0x00] == 0x0000)
        #expect(EncodingTables.bbtToUnicode[0x20] == 0x0020)  // space
        #expect(EncodingTables.bbtToUnicode[0x41] == 0x0041)  // 'A'
        #expect(EncodingTables.bbtToUnicode[0x61] == 0x0061)  // 'a'
        #expect(EncodingTables.bbtToUnicode[0x7F] == 0x007F)
        
        // Test BBT-specific range (0x80-0x9F) - Devanagari diacritics
        #expect(EncodingTables.bbtToUnicode[0x80] == 0x015B)  // ś
        #expect(EncodingTables.bbtToUnicode[0x81] == 0x016B)  // ū
        #expect(EncodingTables.bbtToUnicode[0x82] == 0x1E5B)  // ṛ
        #expect(EncodingTables.bbtToUnicode[0x90] == 0x015A)  // Ś
        #expect(EncodingTables.bbtToUnicode[0x91] == 0x016A)  // Ū
        #expect(EncodingTables.bbtToUnicode[0x9F] == 0x1E3F)  // ṿ
        
        // Test em-dash at 0xC5
        #expect(EncodingTables.bbtToUnicode[0xC5] == 0x2014)  // em-dash
    }
    
    @Test func windowsToUnicodeSampleValues() {
        // Test ASCII range (0x00-0x7F) - should map directly
        #expect(EncodingTables.windowsToUnicode[0x00] == 0x0000)
        #expect(EncodingTables.windowsToUnicode[0x20] == 0x0020)  // space
        #expect(EncodingTables.windowsToUnicode[0x41] == 0x0041)  // 'A'
        #expect(EncodingTables.windowsToUnicode[0x61] == 0x0061)  // 'a'
        #expect(EncodingTables.windowsToUnicode[0x7F] == 0x007F)
        
        // Test Windows-1252 specific characters (0x80-0x9F)
        #expect(EncodingTables.windowsToUnicode[0x80] == 0x20AC)  // €
        #expect(EncodingTables.windowsToUnicode[0x82] == 0x201A)  // ‚
        #expect(EncodingTables.windowsToUnicode[0x83] == 0x0192)  // ƒ
        #expect(EncodingTables.windowsToUnicode[0x85] == 0x2026)  // …
        #expect(EncodingTables.windowsToUnicode[0x86] == 0x2020)  // †
        #expect(EncodingTables.windowsToUnicode[0x87] == 0x2021)  // ‡
        #expect(EncodingTables.windowsToUnicode[0x8E] == 0x017D)  // Ž
        #expect(EncodingTables.windowsToUnicode[0x9C] == 0x0153)  // œ
        #expect(EncodingTables.windowsToUnicode[0x9F] == 0x0178)  // Ÿ
        
        // Test Latin-1 range (0xA0-0xFF)
        #expect(EncodingTables.windowsToUnicode[0xA0] == 0x00A0)  // non-breaking space
        #expect(EncodingTables.windowsToUnicode[0xA1] == 0x00A1)  // ¡
        #expect(EncodingTables.windowsToUnicode[0xFF] == 0x00FF)  // ÿ
    }
    
    @Test func charConvValues() {
        // Verify the character conversion string matches C source
        // "ZURAMFNqxSWHIYLVZURAMFNqxSWHIYL" (31 characters)
        let expected: [UInt8] = [
            0x5A, 0x55, 0x52, 0x41, 0x4D, 0x46, 0x4E, 0x71, 0x78, 0x53,  // ZURAMFNqxS
            0x57, 0x48, 0x49, 0x59, 0x4C, 0x56, 0x5A, 0x55, 0x52, 0x41,  // WHIYLVZURA
            0x4D, 0x46, 0x4E, 0x71, 0x78, 0x53, 0x57, 0x48, 0x49, 0x59,  // MFNqxSWHIY
            0x4C  // L (31st character)
        ]
        
        #expect(EncodingTables.charConv.count == expected.count)
        for (index, expectedValue) in expected.enumerated() {
            #expect(EncodingTables.charConv[index] == expectedValue, "charConv[\(index)] should be 0x\(String(expectedValue, radix: 16))")
        }
    }
}

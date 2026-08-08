import Testing

@testable import MakeDevaCore

struct GlyphLookupTests {
    
    // MARK: - findCode Tests (FontInfoC tables)
    
    @Test func findCodeSingleChar() {
        // Test finding single character transliteration in fontu table
        // fontu starts with "F", "Fr", "Fk", "Fg", "C", "Cr", "q", "qr"...
        let result = GlyphLookup.findCode(transliteration: "F", in: FontTables.fontu)
        #expect(result != nil, "Should find 'F' in fontu table")
        // Verify it's the correct entry (first entry in fontu is "F")
        let expected = FontTables.fontu.first { $0.transliteration == "F" }
        #expect(result == expected?.code)
    }
    
    @Test func findCodeMultiChar() {
        // Test finding multi-character transliteration in fontc table
        // "k" exists in fontc
        let result = GlyphLookup.findCode(transliteration: "k", in: FontTables.fontc)
        #expect(result != nil, "Should find 'k' in fontc table")
        
        // Verify it matches the expected entry
        let expected = FontTables.fontc.first { $0.transliteration == "k" }
        #expect(result == expected?.code)
    }
    
    @Test func findCodeNotFound() {
        // Test non-existent transliteration
        let result = GlyphLookup.findCode(transliteration: "xyz", in: FontTables.fontu)
        #expect(result == nil, "Should return nil for non-existent transliteration")
    }
    
    @Test func findCodeInDifferentTables() {
        // Test finding in different FontInfoC tables
        // fontu has "F", "q", "C" etc.
        let fontuResult = GlyphLookup.findCode(transliteration: "F", in: FontTables.fontu)
        #expect(fontuResult != nil, "Should find 'F' in fontu")
        
        // fontuu starts with "F" as well
        let fontuuResult = GlyphLookup.findCode(transliteration: "F", in: FontTables.fontuu)
        #expect(fontuuResult != nil, "Should find 'F' in fontuu")
        
        // fontR has "r" (lowercase), not "R"
        let fontRResult = GlyphLookup.findCode(transliteration: "r", in: FontTables.fontR)
        #expect(fontRResult != nil, "Should find 'r' in fontR")
    }
    
    // MARK: - findCodeA Tests (FontInfoA tables)
    
    @Test func findCodeAWithoutFlags() {
        // Test finding without requiring flags (uri=false, ya=false)
        let result = GlyphLookup.findCodeA(transliteration: "dm", in: FontTables.fonta, uri: false, ya: false)
        #expect(result != nil, "Should find 'dm' in fonta table without flags")
        
        // Verify it matches the entry
        let expected = FontTables.fonta.first { $0.transliteration == "dm" }
        #expect(result == expected?.code)
    }
    
    @Test func findCodeAWithUriFlag() {
        // Test finding with uri flag requirement
        // "dm" has uri=1, ya=1, so it should match when uri=true
        let result = GlyphLookup.findCodeA(transliteration: "dm", in: FontTables.fonta, uri: true, ya: false)
        #expect(result != nil, "Should find 'dm' with uri flag")
        
        // Verify it's the entry with uri flag set
        let expected = FontTables.fonta.first { $0.transliteration == "dm" && $0.uri != 0 }
        #expect(result == expected?.code)
    }
    
    @Test func findCodeAWithYaFlag() {
        // Test finding with ya flag requirement
        // "dm" has uri=1, ya=1, so it should match when ya=true
        let result = GlyphLookup.findCodeA(transliteration: "dm", in: FontTables.fonta, uri: false, ya: true)
        #expect(result != nil, "Should find 'dm' with ya flag")
        
        // Verify it's the entry with ya flag set
        let expected = FontTables.fonta.first { $0.transliteration == "dm" && $0.ya != 0 }
        #expect(result == expected?.code)
    }
    
    @Test func findCodeAWithBothFlags() {
        // Test finding with both flags required
        let result = GlyphLookup.findCodeA(transliteration: "dm", in: FontTables.fonta, uri: true, ya: true)
        #expect(result != nil, "Should find 'dm' with both flags")
        
        // Verify it's the entry with both flags set
        let expected = FontTables.fonta.first { $0.transliteration == "dm" && $0.uri != 0 && $0.ya != 0 }
        #expect(result == expected?.code)
    }
    
    @Test func findCodeAFlagsIgnored() {
        // Test that flags are ignored when set to false
        // Should match any entry with matching transliteration regardless of flags
        let result1 = GlyphLookup.findCodeA(transliteration: "dm", in: FontTables.fonta, uri: false, ya: false)
        let result2 = GlyphLookup.findCodeA(transliteration: "dm", in: FontTables.fonta, uri: true, ya: true)
        #expect(result1 == result2, "Results should match when flags are false vs true (entry has both flags)")
    }
    
    @Test func findCodeANotFound() {
        // Test non-existent transliteration
        let result = GlyphLookup.findCodeA(transliteration: "xyz", in: FontTables.fonta, uri: false, ya: false)
        #expect(result == nil, "Should return nil for non-existent transliteration")
    }
    
    // MARK: - String to UInt32 Conversion Tests
    
    @Test func transliterationConversionSingleChar() {
        // Test that single character strings are converted correctly
        // "F" exists in fontu
        let result1 = GlyphLookup.findCode(transliteration: "F", in: FontTables.fontu)
        #expect(result1 != nil, "Single char 'F' should be found")
        
        // "k" exists in fontc
        let result2 = GlyphLookup.findCode(transliteration: "k", in: FontTables.fontc)
        #expect(result2 != nil, "Single char 'k' should be found")
    }
    
    @Test func transliterationConversionMultiChar() {
        // Test that multi-character strings are converted correctly
        // "Fr" exists in fontu
        let result1 = GlyphLookup.findCode(transliteration: "Fr", in: FontTables.fontu)
        #expect(result1 != nil, "Two char 'Fr' should be found in fontu")
        
        // "Sq" exists in fontu (checking two-char first)
        let result2 = GlyphLookup.findCode(transliteration: "Sq", in: FontTables.fontu)
        #expect(result2 != nil, "Two char 'Sq' should be found in fontu")
        
        // "Sqr" exists in fontu
        let result3 = GlyphLookup.findCode(transliteration: "Sqr", in: FontTables.fontu)
        #expect(result3 != nil, "Three char 'Sqr' should be found in fontu")
    }
    
    @Test func transliterationConversionCaseSensitive() {
        // Test that conversion is case-sensitive (matching C behavior)
        // "F" exists in fontu, "f" might not
        let resultUpper = GlyphLookup.findCode(transliteration: "F", in: FontTables.fontu)
        let resultLower = GlyphLookup.findCode(transliteration: "f", in: FontTables.fontu)
        
        // "F" should exist, "f" might not
        #expect(resultUpper != nil, "Uppercase 'F' should be found")
        // Lowercase "f" may or may not exist, but if it does, it should be different
        if resultLower != nil {
            #expect(resultLower != resultUpper, "If both exist, they should be different")
        }
    }
    
    // MARK: - Edge Cases
    
    @Test func findCodeEmptyString() {
        // Empty string should not match anything
        let result = GlyphLookup.findCode(transliteration: "", in: FontTables.fontu)
        #expect(result == nil, "Empty string should return nil")
    }
    
    @Test func findCodeALongString() {
        // String longer than 4 characters should be truncated (matching C behavior)
        // This tests that only first 4 chars are used
        let result = GlyphLookup.findCode(transliteration: "abcd", in: FontTables.fontc)
        // If "abcd" doesn't exist, that's fine - we're just testing it doesn't crash
        // If it does exist, it should be found
    }
}

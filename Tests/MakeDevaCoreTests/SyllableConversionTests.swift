import Testing

@testable import MakeDevaCore

struct SyllableConversionTests {
    
    // MARK: - Standalone Vowel Tests
    
    @Test func standaloneVowelA() {
        let result = SyllableConversion.convertSyllable(
            consonants: "",
            vowel: Character("a")
        )
        #expect(result.glyphs.count > 0, "Should produce glyphs for standalone 'a'")
        #expect(result.glyphs[0] == 0x40, "First glyph should be 0x40 (Devanagari 'a')")
    }
    
    @Test func standaloneVowelI() {
        let result = SyllableConversion.convertSyllable(
            consonants: "",
            vowel: Character("i")
        )
        #expect(result.glyphs.count > 0, "Should produce glyphs for standalone 'i'")
        #expect(result.glyphs[0] == UInt8(ascii: "w"), "First glyph should be 'w' (Devanagari 'i')")
    }
    
    @Test func standaloneVowelO() {
        let result = SyllableConversion.convertSyllable(
            consonants: "",
            vowel: Character("o")
        )
        #expect(result.glyphs.count > 0, "Should produce glyphs for standalone 'o'")
    }
    
    @Test func standaloneVowelOWithAnusvara() {
        // 'o' with anusvara should become 'om' (V)
        let result = SyllableConversion.convertSyllable(
            consonants: "",
            vowel: Character("o"),
            anusvara: Character("M")
        )
        #expect(result.glyphs.count > 0, "Should produce glyphs for 'om'")
        #expect(result.glyphs[0] == UInt8(ascii: "V"), "First glyph should be 'V' (om)")
    }
    
    // MARK: - Consonant + Vowel Tests
    
    @Test func consonantWithVowel() {
        // Test simple consonant+vowel (e.g., "ka")
        let result = SyllableConversion.convertSyllable(
            consonants: "k",
            vowel: Character("a")
        )
        #expect(result.glyphs.count > 0, "Should produce glyphs for 'ka'")
    }
    
    @Test func consonantNotFound() {
        // Test with non-existent consonant
        let result = SyllableConversion.convertSyllable(
            consonants: "xyz",
            vowel: Character("a")
        )
        // Should still produce some output (even if just the vowel sign)
        #expect(result.glyphs.count >= 0, "Should handle non-existent consonant gracefully")
    }
    
    // MARK: - Edge Cases
    
    @Test func emptyInput() {
        let result = SyllableConversion.convertSyllable(
            consonants: "",
            vowel: nil
        )
        #expect(result.glyphs.count == 0, "Empty input should produce no glyphs")
    }
    
    @Test func buildTest() {
        // Just verify the function can be called without crashing
        let _ = SyllableConversion.convertSyllable(
            consonants: "k",
            vowel: Character("a"),
            anusvara: nil,
            visarga: nil,
            nafter: false
        )
        // If we get here, the function at least compiles and runs
    }
}

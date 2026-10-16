import Testing

@testable import MakeDevaCore

struct LineConversionTests {
    
    @Test(arguments: [false, true]) func digitsAdvanceAndKeepCustomGlyphBytes(verseFormat: Bool) {
        // devaline.c SHELL punctuation/digit branch, lines 1449–1491.
        #expect(LineConversion.convertLine("0123456789", verseFormat: verseFormat).glyphs == Array("0123456789".utf8))
        let word = LineConversion.convertLine("rAma", verseFormat: verseFormat).glyphs
        #expect(LineConversion.convertLine("rAma 9", verseFormat: verseFormat).glyphs == word + Array(" 9".utf8))
        #expect(LineConversion.convertLine("9 rAma", verseFormat: verseFormat).glyphs == Array("9 ".utf8) + word)
        #expect(LineConversion.convertLine("9, 1.", verseFormat: verseFormat).glyphs == Array("9/ 1//".utf8))
    }

    @Test func digitInCustomUnicodeComparisonTerminates() {
        #expect(MakeDevaUnicode.customPathUnicode("rāma 9") == "राम ९")
    }

    // MARK: - Basic Line Conversion Tests
    
    @Test func simpleLine() {
        let result = LineConversion.convertLine("ka", verseFormat: false)
        #expect(result.glyphs.count > 0, "Should produce glyphs for simple line")
    }
    
    @Test func multipleSyllables() {
        let result = LineConversion.convertLine("ka ma", verseFormat: false)
        #expect(result.glyphs.count > 0, "Should produce glyphs for multiple syllables")
    }
    
    @Test func verseFormat() {
        let result = LineConversion.convertLine("ka", verseFormat: true)
        #expect(result.glyphs.count > 0, "Should produce glyphs in verse format")
    }
    
    @Test func proseFormat() {
        let result = LineConversion.convertLine("ka ma", verseFormat: false)
        #expect(result.glyphs.count > 0, "Should produce glyphs in prose format")
    }
    
    @Test func emptyLine() {
        let result = LineConversion.convertLine("", verseFormat: false)
        #expect(result.glyphs.count == 0, "Empty line should produce no glyphs")
    }
    
    @Test func standaloneVowel() {
        let result = LineConversion.convertLine("a", verseFormat: false)
        #expect(result.glyphs.count > 0, "Should produce glyphs for standalone vowel")
    }
    
    @Test func buildTest() {
        // Just verify the function can be called without crashing
        let _ = LineConversion.convertLine("ka", verseFormat: false, sannyasa: false)
        // If we get here, the function at least compiles and runs
    }
}

import Testing

@testable import MakeDevaCore

struct LineConversionTests {
    
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

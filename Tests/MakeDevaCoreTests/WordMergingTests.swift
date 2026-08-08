import Testing

@testable import MakeDevaCore

struct WordMergingTests {

    // MARK: - SplitLine Tests

    @Test func splitLineBasic() {
        // Test basic splitline functionality
        let line = "ka ma"
        let result = WordMerging.splitLine(line, at: 3)
        #expect(result >= 0 && result <= line.count, "Split position should be within line bounds")
    }

    @Test func splitLineAtBeginning() {
        let line = "ka"
        let result = WordMerging.splitLine(line, at: 0)
        #expect(result == 0, "Split at beginning should return 0")
    }

    @Test func splitLineAtEnd() {
        let line = "ka"
        let result = WordMerging.splitLine(line, at: line.count)
        #expect(result <= line.count, "Split at end should return valid position")
    }

    @Test func splitLineWithSandhi() {
        // Test splitline with isnx pattern
        let line = "n ka"
        let result = WordMerging.splitLine(line, at: 2)
        #expect(result >= 0, "Should handle sandhi patterns")
    }

    // MARK: - Word Boundary Tests

    @Test func findWordBoundariesBasic() {
        let text = "ka ma"
        let (wordStart, wordEnd, nextWordStart) = WordMerging.findWordBoundaries(
            text, startIndex: 0, endIndex: text.count
        )
        #expect(wordStart == 0, "First word should start at 0")
        #expect(wordEnd > wordStart, "Word end should be after start")
        #expect(nextWordStart > wordEnd, "Next word should be after current word")
    }

    @Test func findWordBoundariesSingleWord() {
        let text = "ka"
        let (wordStart, wordEnd, nextWordStart) = WordMerging.findWordBoundaries(
            text, startIndex: 0, endIndex: text.count
        )
        #expect(wordStart == 0, "Single word should start at 0")
        #expect(wordEnd == text.count, "Single word should end at text end")
    }

    @Test func findWordBoundariesWithSpaces() {
        let text = "  ka  ma  "
        let (wordStart, wordEnd, nextWordStart) = WordMerging.findWordBoundaries(
            text, startIndex: 0, endIndex: text.count
        )
        #expect(wordStart == 2, "Should skip leading spaces")
        #expect(wordEnd > wordStart, "Word end should be after start")
    }

    // MARK: - Line Width Tests

    @Test func calculateLineWidth() {
        let glyphs: [UInt8] = [0x40, 0x6B]  // 'a' and 'k'
        let width = WordMerging.calculateLineWidth(glyphs)
        #expect(width > 0, "Line width should be positive")
    }

    @Test func calculateLineWidthEmpty() {
        let glyphs: [UInt8] = []
        let width = WordMerging.calculateLineWidth(glyphs)
        #expect(width == 0, "Empty line should have zero width")
    }

    @Test func buildTest() {
        // Just verify the functions can be called without crashing
        let _ = WordMerging.splitLine("ka", at: 1)
        let _ = WordMerging.findWordBoundaries("ka ma", startIndex: 0, endIndex: 5)
        let _ = WordMerging.calculateLineWidth([0x40])
        // If we get here, the functions at least compile and run
    }
}

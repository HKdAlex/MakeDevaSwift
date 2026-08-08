import Testing

@testable import MakeDevaCore

struct BBTTagParserTests {

    // MARK: - Basic Tag Parsing Tests

    @Test func basicTagParsing() {
        let text = "@TAG = value"
        var index = 0
        let result = BBTTagParser.parseTag(text, at: &index)

        #expect(result != nil, "Should parse basic tag")
        #expect(result?.tagName == "TAG", "Tag name should be 'TAG'")
        #expect(result?.value == "value", "Tag value should be 'value'")
    }

    @Test func devanagariTagRecognition() {
        let text = "@DEVANAGARI = some content"
        var index = 0
        let result = BBTTagParser.parseTag(text, at: &index)

        #expect(result != nil, "Should parse Devanagari tag")
        #expect(result?.isDevanagari == true, "Should recognize as Devanagari tag")
        #expect(result?.tagType == .devanagari, "Tag type should be .devanagari")
    }

    @Test func tagValueExtraction() {
        let text = "@TEXT = 123"
        var index = 0
        let result = BBTTagParser.parseTag(text, at: &index)

        #expect(result != nil, "Should parse tag with numeric value")
        #expect(result?.value == "123", "Should extract numeric value")
    }

    @Test func caseInsensitivity() {
        let text = "@devanagari = content"
        var index = 0
        let result = BBTTagParser.parseTag(text, at: &index)

        #expect(result != nil, "Should parse lowercase tag")
        #expect(result?.tagName == "DEVANAGARI", "Tag name should be uppercased")
        #expect(result?.isDevanagari == true, "Should recognize lowercase Devanagari tag")
    }

    @Test func multipleTags() {
        let text = "@TAG1 = value1 @TAG2 = value2"
        var index = 0

        let result1 = BBTTagParser.parseTag(text, at: &index)
        #expect(result1 != nil, "Should parse first tag")
        #expect(result1?.tagName == "TAG1", "First tag name should be 'TAG1'")

        let result2 = BBTTagParser.parseTag(text, at: &index)
        #expect(result2 != nil, "Should parse second tag")
        #expect(result2?.tagName == "TAG2", "Second tag name should be 'TAG2'")
    }

    @Test func malformedTag() {
        let text = "@TAG"
        var index = 0
        let result = BBTTagParser.parseTag(text, at: &index)

        #expect(result == nil, "Should not parse malformed tag without '='")
    }

    @Test func isDevanagariTag() {
        #expect(BBTTagParser.isDevanagariTag("DEVANAGARI") == true, "Should recognize DEVANAGARI")
        #expect(BBTTagParser.isDevanagariTag("DEV PROSE") == true, "Should recognize DEV PROSE")
        #expect(BBTTagParser.isDevanagariTag("d-uvaca") == true, "Should recognize d-uvaca")
        #expect(
            BBTTagParser.isDevanagariTag("TEXT") == false, "Should not recognize TEXT as Devanagari"
        )
    }

    @Test func extractSanskritContent() {
        let text = "@DEVANAGARI = ka ma @TEXT = 1"
        let content = BBTTagParser.extractSanskritContent(
            text, startTag: "@DEVANAGARI", endTag: "@TEXT")

        #expect(content.contains("ka"), "Should extract Sanskrit content")
        #expect(content.contains("ma"), "Should extract Sanskrit content")
    }

    @Test func buildTest() {
        // Just verify the functions can be called without crashing
        var index = 0
        let _ = BBTTagParser.parseTag("@TEST = value", at: &index)
        let _ = BBTTagParser.isDevanagariTag("DEVANAGARI")
        let _ = BBTTagParser.extractSanskritContent("@DEVANAGARI = ka", startTag: "@DEVANAGARI")
        // If we get here, the functions at least compile and run
    }
}

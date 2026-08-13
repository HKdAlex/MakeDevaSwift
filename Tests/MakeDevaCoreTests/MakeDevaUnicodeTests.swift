import Foundation
import Testing
@testable import MakeDevaCore

struct MakeDevaUnicodeTests {

    // MARK: - Structural prep (Unicode branch only)

    @Test("prepareIAST collapses whitespace and does not pairwise-join")
    func prepareIASTWhitespaceOnly() {
        #expect(MakeDevaUnicode.prepareIAST("k  \t  g") == "k g")
        #expect(MakeDevaUnicode.prepareIAST("k g") == "k g")
        #expect(MakeDevaUnicode.prepareIAST("k a") == "k a")
        #expect(MakeDevaUnicode.prepareIAST("n m k a") == "n m k a")
        #expect(MakeDevaUnicode.prepareIAST("an ka") == "a ka")
    }

    // MARK: - ICU Latin-Devanagari (UNI-08)

    @Test("convertLine maps simple syllables to Unicode Devanagari")
    func simpleSyllables() {
        #expect(MakeDevaUnicode.convertLine("ka") == "क")
        #expect(MakeDevaUnicode.convertLine("rāma") == "राम")
        #expect(MakeDevaUnicode.convertLine("uvāca") == "उवाच")
    }

    @Test("convertLine applies ICU pre-normalization for ṛ and e/o")
    func icuPreNormalization() {
        #expect(MakeDevaUnicode.convertLine("kṛṣṇa") == "कृष्ण")
        #expect(MakeDevaUnicode.convertLine("namo") == "नमो")
        #expect(MakeDevaUnicode.convertLine("eva") == "एव")
    }

    @Test("convertLine golden fixtures match committed oracle")
    func goldenFixtures() throws {
        let url = try Self.fixtureURL("unicode-devanagari/cases.tsv")
        let text = try String(contentsOf: url, encoding: .utf8)
        for line in text.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            let parts = trimmed.split(separator: "\t", maxSplits: 1).map(String.init)
            guard parts.count == 2 else {
                Issue.record("Malformed fixture line: \(trimmed)")
                continue
            }
            #expect(MakeDevaUnicode.convertLine(parts[0]) == parts[1], "input: \(parts[0])")
        }
    }

    // MARK: - Helpers

    private static func fixtureURL(_ relative: String) throws -> URL {
        let thisFile = URL(fileURLWithPath: #filePath)
        let fixtures = thisFile
            .deletingLastPathComponent() // MakeDevaCoreTests
            .deletingLastPathComponent() // Tests
            .appendingPathComponent("Fixtures", isDirectory: true)
            .appendingPathComponent(relative)
        guard FileManager.default.fileExists(atPath: fixtures.path) else {
            throw FixtureError.missing(fixtures.path)
        }
        return fixtures
    }

    private enum FixtureError: Error {
        case missing(String)
    }
}

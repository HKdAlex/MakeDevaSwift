import Foundation
import Testing
@testable import MakeDevaCore

struct MakeDevaStructuralPrepTests {

    @Test("prepareIAST matches committed structural-prep fixtures")
    func goldenFixtures() throws {
        let url = try Self.fixtureURL("structural-prep/cases.tsv")
        let text = try String(contentsOf: url, encoding: .utf8)
        var rows = 0
        for line in text.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            let parts = trimmed.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 2 else {
                Issue.record("Malformed structural-prep line: \(trimmed)")
                continue
            }
            rows += 1
            #expect(
                MakeDevaUnicode.prepareIAST(parts[0]) == parts[1],
                "\(parts.count > 2 ? parts[2] : "") input=\(parts[0])"
            )
        }
        #expect(rows >= 12, "structural-prep fixture list shrank")
    }

    @Test("custom path still does not call prepareIAST")
    func customPathSkipsPrep() {
        #expect(MakeDevaIngest.iastToMakeDevaASCII("an ka") == "an ka")
        #expect(MakeDevaUnicode.prepareIAST("an ka") == "a ka")
    }

    private static func fixtureURL(_ relative: String) throws -> URL {
        let thisFile = URL(fileURLWithPath: #filePath)
        let fixtures = thisFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
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

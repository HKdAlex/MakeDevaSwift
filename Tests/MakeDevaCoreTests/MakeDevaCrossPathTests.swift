import Foundation
import Testing
@testable import MakeDevaCore

struct MakeDevaCrossPathTests {

    private static let corpusFloor = 56

    @Test("ingest maps Unicode IAST to MakeDeva ASCII")
    func ingestKnownPairs() {
        #expect(MakeDevaIngest.iastToMakeDevaASCII("kṛṣṇa") == "kRSNa")
        #expect(MakeDevaIngest.iastToMakeDevaASCII("rāma") == "rAma")
        #expect(MakeDevaIngest.iastToMakeDevaASCII("śrī") == "ZrI")
        #expect(MakeDevaIngest.iastToMakeDevaASCII("pāṇḍava") == "pANxava")
        #expect(MakeDevaIngest.iastToMakeDevaASCII("ai") == "E")
        #expect(MakeDevaIngest.iastToMakeDevaASCII("kh") == "K")
        #expect(MakeDevaIngest.iastToMakeDevaASCII("dhṛtarāṣṭra") == "DRtarASqra")
    }

    @Test("custom path does not call prepareIAST (spaces preserved in ingest)")
    func customPathDoesNotPrepare() {
        let ascii = MakeDevaIngest.iastToMakeDevaASCII("k  a")
        #expect(ascii == "k  a")
        #expect(MakeDevaUnicode.prepareIAST("k  a") == "k a")
    }

    @Test("CrossPathCorpus has at least the committed floor (anti-shrink)")
    func corpusFloorCount() throws {
        let rows = try Self.loadCorpus()
        #expect(rows.count >= Self.corpusFloor, "CrossPathCorpus shrank below \(Self.corpusFloor)")
    }

    @Test("unicode-devanagari golden inputs are in CrossPathCorpus")
    func unicodeGoldensAreSubset() throws {
        let corpus = Set(try Self.loadCorpus().map(\.iast))
        let goldens = try Self.loadUnicodeGoldenInputs()
        for iast in goldens {
            #expect(corpus.contains(iast), "missing from CrossPathCorpus: \(iast)")
        }
    }

    @Test("every corpus divergence id is in the ledger")
    func ledgerCoversDivergenceIds() throws {
        let ledger = try String(
            contentsOf: try Self.fixtureURL("cross-path/ledger.md"), encoding: .utf8)
        let rows = try Self.loadCorpus()
        for row in rows where !row.divergence.isEmpty {
            #expect(
                ledger.contains(row.divergence),
                "\(row.id) divergence \(row.divergence) missing from ledger.md"
            )
        }
    }

    @Test("cross-path NFC equivalence on CrossPathCorpus")
    func crossPathOracle() throws {
        let rows = try Self.loadCorpus()
        #expect(!rows.isEmpty)
        for row in rows {
            let unicodeOut = MakeDevaUnicode.convertLine(row.iast)
            let customOut = MakeDevaUnicode.customPathUnicode(row.iast)
            let matches = MakeDevaUnicode.unicodeEquivalent(unicodeOut, customOut)
            if row.divergence.isEmpty {
                #expect(
                    matches,
                    "\(row.id) \(row.iast): unicode=\(unicodeOut) custom=\(customOut) ascii=\(MakeDevaIngest.iastToMakeDevaASCII(row.iast))"
                )
            } else if matches {
                Issue.record(
                    "\(row.id) now matches; clear divergence \(row.divergence) from corpus.tsv")
            }
        }
    }

    // MARK: - Loaders

    private struct CorpusRow {
        let id: String
        let pattern: String
        let source: String
        let iast: String
        let divergence: String
    }

    private static func loadCorpus() throws -> [CorpusRow] {
        let text = try String(contentsOf: try fixtureURL("cross-path/corpus.tsv"), encoding: .utf8)
        var rows: [CorpusRow] = []
        for line in text.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            let parts = trimmed.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard parts.count >= 4 else {
                Issue.record("Malformed CrossPathCorpus line: \(trimmed)")
                continue
            }
            let divergence = parts.count > 4 ? parts[4] : ""
            rows.append(
                CorpusRow(
                    id: parts[0],
                    pattern: parts[1],
                    source: parts[2],
                    iast: parts[3],
                    divergence: divergence
                )
            )
        }
        return rows
    }

    private static func loadUnicodeGoldenInputs() throws -> [String] {
        let text = try String(
            contentsOf: try fixtureURL("unicode-devanagari/cases.tsv"), encoding: .utf8)
        var inputs: [String] = []
        for line in text.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            let parts = trimmed.split(separator: "\t", maxSplits: 1).map(String.init)
            guard let iast = parts.first else { continue }
            inputs.append(iast)
        }
        return inputs
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

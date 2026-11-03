import Foundation
import MakeDevaCore
import Testing
@testable import MakeDevaCLI

@Suite("Strict source glyph JSON intake")
struct GlyphBufferCommandTests {
    func input(_ rows: [[String: Any]]) throws -> Data {
        try JSONSerialization.data(withJSONObject: rows, options: [.sortedKeys])
    }

    @Test func exactSourceBufferAndStableBatchOrder() throws {
        // NOI iBooks r3, RUNI01XT.xhtml#x2, first physical line; original glyphs.
        // RMDEVA.TTF SHA256: 3c4d491ed86d5ef9c0f4234cfed9bd9c44bcde322dba1c37bebe75439fcd9db7.
        let source: [UInt8] = [118,97,65,99,97,65,101,32,118,97,101,103,65,77,32,109,97,110,97,115,36,97,58,32,130,40,65,101,68,97,118,97,101,103,65,77]
        let data = try input([["id":"NOI1:0","glyphs":source], ["id":"ka","glyphs":LineConversion.convertLine("ka").glyphs]])
        let first = try GlyphBufferCommand.convert(data)
        let second = try GlyphBufferCommand.convert(data)
        #expect(first == second)
        let result = try #require(JSONSerialization.jsonObject(with: first) as? [String: Any])
        #expect(result["schema"] as? String == "rmd-glyph-probe/1")
        let records = try #require(result["records"] as? [[String: Any]])
        #expect(records.map { $0["id"] as? String } == ["NOI1:0", "ka"])
        #expect(records[0]["unicode"] as? String == "वाचो वेगं मनसः क्रोधवेगं")
        #expect(records[0]["exactGlyphReplay"] as? Bool == true)
        #expect(records[0]["inputGlyphs"] as? [Int] == source.map(Int.init))
        #expect(records[1]["unicode"] as? String == "क")
    }

    @Test func unknownOrLostGlyphRejectsWholeBatch() throws {
        let data = try input([["id":"valid","glyphs":LineConversion.convertLine("ka").glyphs],
                              ["id":"unknown","glyphs":[0]]])
        #expect(throws: GlyphBufferCommand.Failure.self) { try GlyphBufferCommand.convert(data) }
    }

    @Test func identityAndEmptyBuffersReject() throws {
        for rows: [[String: Any]] in [[], [["id":"","glyphs":[107]]],
                                    [["id":"one","glyphs":[]]],
                                    [["id":"same","glyphs":[107]], ["id":"same","glyphs":[107]]]] {
            let data = try input(rows)
            #expect(throws: GlyphBufferCommand.Failure.self) { try GlyphBufferCommand.convert(data) }
        }
    }

    @Test func malformedAndOutOfByteRangeInputsReject() {
        for raw in ["not-json", "{}", "[{\"id\":\"x\",\"glyphs\":[256]}]", "[{\"id\":\"x\",\"glyphs\":[-1]}]"] {
            #expect(throws: (any Error).self) { try GlyphBufferCommand.convert(Data(raw.utf8)) }
        }
    }
}

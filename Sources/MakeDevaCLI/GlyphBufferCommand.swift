import Foundation
import MakeDevaCore

/// Read-only source-intake probe. Callers must separately qualify the source
/// font and its byte transport; a successful glyph replay is not font authority.
enum GlyphBufferCommand {
    struct Input: Decodable {
        let id: String
        let glyphs: [UInt8]
    }

    struct Record: Encodable {
        let id: String
        let inputGlyphs: [UInt8]
        let reconstructedASCII: String
        let unicode: String
        let replayGlyphs: [UInt8]
        let exactGlyphReplay: Bool
    }

    struct Result: Encodable {
        let schema = "rmd-glyph-probe/1"
        let records: [Record]
    }

    enum Failure: Error, LocalizedError {
        case invalidIdentity
        case emptyGlyphs(String)
        case nonReproducible(String)

        var errorDescription: String? {
            switch self {
            case .invalidIdentity: "Glyph records need distinct nonempty identities"
            case let .emptyGlyphs(id): "Empty source glyph buffer: \(id)"
            case let .nonReproducible(id): "Source glyph buffer does not replay exactly: \(id)"
            }
        }
    }

    /// Validate the complete batch before emitting any result. The existing
    /// decoder can skip unknown glyphs, so exact regeneration is mandatory here.
    /// Keep legacy ASCII punctuation in the Unicode API result: a qualified
    /// font-intake profile owns font danda glyphs and Unicode layout characters.
    static func convert(_ data: Data) throws -> Data {
        let inputs = try JSONDecoder().decode([Input].self, from: data)
        guard !inputs.isEmpty, inputs.allSatisfy({ !$0.id.isEmpty }),
              Set(inputs.map(\.id)).count == inputs.count else {
            throw Failure.invalidIdentity
        }
        let records = try inputs.map { input in
            guard !input.glyphs.isEmpty else { throw Failure.emptyGlyphs(input.id) }
            let ascii = MakeDevaGlyphDecode.reconstructMakeDevaASCII(input.glyphs)
            let replay = LineConversion.convertLine(ascii).glyphs
            guard replay == input.glyphs else { throw Failure.nonReproducible(input.id) }
            return Record(id: input.id, inputGlyphs: input.glyphs,
                          reconstructedASCII: ascii,
                          unicode: MakeDevaUnicode.decodeUnicode(input.glyphs),
                          replayGlyphs: replay, exactGlyphReplay: true)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var result = try encoder.encode(Result(records: records))
        result.append(0x0A)
        return result
    }
}

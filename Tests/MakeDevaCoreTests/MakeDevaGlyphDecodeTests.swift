import Foundation
import Testing
@testable import MakeDevaCore

struct MakeDevaGlyphDecodeTests {

    // MARK: - Known glyph sequences → Unicode (IU-58 fixtures)

    @Test("decodeUnicode maps recorded glyph bytes to Unicode Devanagari")
    func goldenGlyphFixtures() throws {
        let url = try Self.fixtureURL("glyph-decode/cases.tsv")
        let text = try String(contentsOf: url, encoding: .utf8)
        for line in text.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            let parts = trimmed.split(separator: "\t", maxSplits: 2).map(String.init)
            guard parts.count >= 2 else {
                Issue.record("Malformed fixture line: \(trimmed)")
                continue
            }
            let glyphs = try Self.parseHex(parts[0])
            #expect(
                MakeDevaUnicode.decodeUnicode(glyphs) == parts[1],
                "glyphs: \(parts[0])"
            )
        }
    }

    // MARK: - Reconstruction of MakeDeva ASCII

    @Test("reconstructMakeDevaASCII round-trips LineConversion samples")
    func reconstructSimpleASCII() {
        let samples = [
            "ka", "rAma", "uvAca", "kRSNa", "namo", "eva", "a", "i", "e", "o", "ka ma",
            "dharma", "ki", "ZrI", "DR", "DRta", "m", "ham", "so'ham",
            "kSetre", "cEva", "cEtanya", "Darma-kSetre",
            "haM", "oM", "saM",
            "ju", "Su", "arjuna", "madhusUdanaH", "kSudraM", "puMsaH",
            "kI", "kIrti", "kL",
            "janArdana", "indriyANi", "kAryaM", "kurvanti", "nti", "ndri", "kuryAM",
            "ry", "arTa",
        ]
        for s in samples {
            let glyphs = LineConversion.convertLine(s).glyphs
            let got = MakeDevaGlyphDecode.reconstructMakeDevaASCII(glyphs)
            #expect(got == s, "input \(s) reconstructed \(got) glyphs \(hex(glyphs))")
        }
    }

    @Test("decodeUnicode of LineConversion(ka) matches ICU ka")
    func kaCrossCheck() {
        let glyphs = LineConversion.convertLine("ka").glyphs
        #expect(MakeDevaUnicode.decodeUnicode(glyphs) == "क")
    }

    @Test("decodeUnicode honors C virama comma on vowelless m")
    func viramaFinalMMatchesICU() {
        let glyphs = LineConversion.convertLine("m").glyphs
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(glyphs) == "m")
        #expect(MakeDevaUnicode.decodeUnicode(glyphs) == MakeDevaUnicode.convertLine("m"))
        #expect(MakeDevaUnicode.customPathUnicode("so'ham") == MakeDevaUnicode.convertLine("so'ham"))
        #expect(MakeDevaUnicode.customPathUnicode("so'ham") == "सोहम्")
    }

    @Test("decodeUnicode honors C e/E vowelsign after a letterform cluster")
    func eAndAiVowelsignAfterClusterMatchesICU() {
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("kSetre").glyphs) == "kSetre")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("cEva").glyphs) == "cEva")
        #expect(MakeDevaUnicode.customPathUnicode("kṣetre") == MakeDevaUnicode.convertLine("kṣetre"))
        #expect(MakeDevaUnicode.customPathUnicode("caiva") == MakeDevaUnicode.convertLine("caiva"))
        #expect(MakeDevaUnicode.customPathUnicode("caitanya") == MakeDevaUnicode.convertLine("caitanya"))
        #expect(MakeDevaUnicode.customPathUnicode("dharma-kṣetre") == MakeDevaUnicode.convertLine("dharma-kṣetre"))
    }

    @Test("decodeUnicode honors C u/U vowelsign after a letterform cluster")
    func uAndUuVowelsignAfterClusterMatchesICU() {
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("ju").glyphs) == "ju")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("arjuna").glyphs) == "arjuna")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("madhusUdanaH").glyphs) == "madhusUdanaH")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("kSudraM").glyphs) == "kSudraM")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("puMsaH").glyphs) == "puMsaH")
        #expect(MakeDevaUnicode.customPathUnicode("arjuna") == MakeDevaUnicode.convertLine("arjuna"))
        #expect(MakeDevaUnicode.customPathUnicode("madhusūdanaḥ") == MakeDevaUnicode.convertLine("madhusūdanaḥ"))
        #expect(MakeDevaUnicode.customPathUnicode("kṣudraṁ") == MakeDevaUnicode.convertLine("kṣudraṁ"))
        #expect(MakeDevaUnicode.customPathUnicode("puṁsaḥ") == MakeDevaUnicode.convertLine("puṁsaḥ"))
    }

    @Test("decodeUnicode honors C wide long-ī aiafter rewritten to L (0x4C)")
    func wideLongIAiafterLMatchesICU() {
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("kI").glyphs) == "kI")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("kIrti").glyphs) == "kIrti")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("kL").glyphs) == "kL")
        #expect(MakeDevaUnicode.customPathUnicode("kī") == MakeDevaUnicode.convertLine("kī"))
        #expect(MakeDevaUnicode.customPathUnicode("kīrti") == MakeDevaUnicode.convertLine("kīrti"))
        #expect(MakeDevaUnicode.customPathUnicode("kḷ") == MakeDevaUnicode.convertLine("kḷ"))
    }

    @Test("decodeUnicode honors C repha splice, collapsed r+M, and pending-i on half-n")
    func rephaAndPendingIClustersMatchICU() {
        let asciiSamples = [
            "janArdana", "indriyANi", "kAryaM", "kurvanti", "nti", "ndri", "kuryAM", "ry", "arTa",
            "kya", "Kya", "sAFKyAnAM",
        ]
        for s in asciiSamples {
            let glyphs = LineConversion.convertLine(s).glyphs
            #expect(
                MakeDevaGlyphDecode.reconstructMakeDevaASCII(glyphs) == s,
                "input \(s) reconstructed \(MakeDevaGlyphDecode.reconstructMakeDevaASCII(glyphs))"
            )
        }
        #expect(MakeDevaUnicode.customPathUnicode("janārdana") == MakeDevaUnicode.convertLine("janārdana"))
        #expect(MakeDevaUnicode.customPathUnicode("indriyāṇi") == MakeDevaUnicode.convertLine("indriyāṇi"))
        #expect(MakeDevaUnicode.customPathUnicode("kāryaṁ") == MakeDevaUnicode.convertLine("kāryaṁ"))
        #expect(MakeDevaUnicode.customPathUnicode("kurvanti") == MakeDevaUnicode.convertLine("kurvanti"))
        #expect(MakeDevaUnicode.customPathUnicode("kuryāṁ") == MakeDevaUnicode.convertLine("kuryāṁ"))
        #expect(MakeDevaUnicode.customPathUnicode("artha") == MakeDevaUnicode.convertLine("artha"))
        #expect(MakeDevaUnicode.customPathUnicode("kya") == MakeDevaUnicode.convertLine("kya"))
        #expect(MakeDevaUnicode.customPathUnicode("khya") == MakeDevaUnicode.convertLine("khya"))
        #expect(MakeDevaUnicode.customPathUnicode("sāṅkhyānāṁ") == MakeDevaUnicode.convertLine("sāṅkhyānāṁ"))
    }

    @Test("hyphen compounds NFC-match; leftover yafter is conjunct not khaya")
    func hyphenCompoundsMatchICU() {
        let samples = [
            "dharma-kṣetre",
            "jñāna-yogena",
            "jñāna-yogena sāṅkhyānāṁ",
            "karma-yogena",
            "tad-arthaṁ",
            "ahaṅkāra-vimūḍhātmā",
            "mukta-saṅgaḥ",
            "loka-saṅgraham",
            "guṇa-karma-vibhāgayoḥ",
        ]
        for s in samples {
            let u = MakeDevaUnicode.convertLine(s)
            let c = MakeDevaUnicode.customPathUnicode(s)
            #expect(MakeDevaUnicode.unicodeEquivalent(u, c), "\(s) unicode=\(u) custom=\(c)")
        }
    }

    @Test("decodeUnicode honors C anusvara M as IAST ṁ (U+1E41)")
    func anusvaraMDotAboveMatchesICU() {
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("haM").glyphs) == "haM")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII(LineConversion.convertLine("oM").glyphs) == "oM")
        #expect(MakeDevaGlyphDecode.makeDevaASCIIToIAST("oM") == "oṁ")
        #expect(MakeDevaGlyphDecode.makeDevaASCIIToIAST("haM") == "haṁ")
        #expect(MakeDevaUnicode.customPathUnicode("oṁ") == MakeDevaUnicode.convertLine("oṁ"))
        #expect(MakeDevaUnicode.customPathUnicode("oṁ") == "ओं")
        #expect(MakeDevaUnicode.customPathUnicode("haṁ") == MakeDevaUnicode.convertLine("haṁ"))
        #expect(MakeDevaUnicode.customPathUnicode("haṁ") == "हं")
        #expect(MakeDevaUnicode.customPathUnicode("saṁ") == MakeDevaUnicode.convertLine("saṁ"))
    }

    @Test("repha before conjunct (rtm/rṇy) and l-candrabindu NFC-match ICU")
    func rephaConjunctAndLCandrabinduMatchICU() {
        let samples: [(iast: String, ascii: String)] = [
            ("vartmā", "vartmA"),
            ("varṇyaṁ", "varNyaM"),
            ("vāl̐", "vAlw"),
        ]
        for (s, expectedASCII) in samples {
            let ascii = MakeDevaIngest.iastToMakeDevaASCII(s)
            let glyphs = LineConversion.convertLine(ascii).glyphs
            let recon = MakeDevaGlyphDecode.reconstructMakeDevaASCII(glyphs)
            let u = MakeDevaUnicode.convertLine(s)
            let c = MakeDevaUnicode.customPathUnicode(s)
            #expect(ascii == expectedASCII, "\(s) ingest=\(ascii)")
            #expect(recon == expectedASCII, "\(s) recon=\(recon) glyphs=\(hex(glyphs))")
            #expect(
                MakeDevaUnicode.unicodeEquivalent(u, c),
                "\(s) ascii=\(ascii) recon=\(recon) glyphs=\(hex(glyphs)) unicode=\(u) custom=\(c)"
            )
        }
    }

    @Test("ASCII→IAST maps MakeDeva alphabet")
    func asciiToIAST() {
        #expect(MakeDevaGlyphDecode.makeDevaASCIIToIAST("kRSNa") == "kṛṣṇa")
        #expect(MakeDevaGlyphDecode.makeDevaASCIIToIAST("rAma") == "rāma")
        #expect(MakeDevaGlyphDecode.makeDevaASCIIToIAST("ZrI") == "śrī")
        #expect(MakeDevaGlyphDecode.makeDevaASCIIToIAST("M") == "ṁ")
        #expect(MakeDevaGlyphDecode.makeDevaASCIIToIAST("lw") == "l̐")
        #expect(MakeDevaGlyphDecode.makeDevaASCIIToIAST("vAlw") == "vāl̐")
    }

    // MARK: - Helpers

    private func hex(_ glyphs: [UInt8]) -> String {
        glyphs.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    private static func parseHex(_ text: String) throws -> [UInt8] {
        let tokens = text.split(whereSeparator: \.isWhitespace)
        return try tokens.map { token in
            guard let v = UInt8(token, radix: 16) else {
                throw FixtureError.badHex(String(token))
            }
            return v
        }
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
        case badHex(String)
    }
}

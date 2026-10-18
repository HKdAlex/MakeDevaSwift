import Foundation
import Testing
@testable import MakeDevaCore

struct SBBatchConversionTests {
    @Test func prefixedShortIBelongsToNextCluster() {
        #expect(MakeDevaUnicode.customPathUnicode("śṛṅgidaṁṣṭriṇām") == "शृङ्गिदंष्ट्रिणाम्")
        #expect(MakeDevaUnicode.customPathUnicode("śṛ gi") == "शृ गि")
    }

    @Test func rephaOnTrailingYaBelongsToWholeConjunct() {
        for (input, expected) in [("rddhyā", "र्द्ध्या"), ("rṣṭya", "र्ष्ट्य"), ("ddhyā", "द्ध्या"), ("ṣṭya", "ष्ट्य")] {
            #expect(MakeDevaUnicode.customPathUnicode(input) == expected)
        }
    }

    @Test func avagrahaAnusvaraGlyphOrderIsNotAnInvertibleTextEncoding() {
        // C devaline.c:1576–1587 looks beyond avagraha and attaches M
        // to the preceding vowel. Different logical inputs share glyphs.
        let before = "brahmaṇoṁ 'śena"
        let after = "brahmaṇo 'ṁśena"
        let a = LineConversion.convertLine(MakeDevaIngest.iastToMakeDevaASCII(before)).glyphs
        let b = LineConversion.convertLine(MakeDevaIngest.iastToMakeDevaASCII(after)).glyphs
        #expect(a == b)
        #expect(MakeDevaUnicode.convertLine(before) == "ब्रह्मणोंऽशेन")
        #expect(MakeDevaUnicode.convertLine(after) == "ब्रह्मणोऽंशेन")
        #expect(MakeDevaUnicode.customPathUnicode(before) == MakeDevaUnicode.customPathUnicode(after))
    }

    @Test func shortIOnRaDoesNotLeakAcrossSpace() {
        for (input, expected) in [("ri", "रि"), ("hariṁ", "हरिं"), ("hariṁ gehāt", "हरिं गेहात्")] {
            #expect(MakeDevaUnicode.customPathUnicode(input) == expected)
        }
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII([0x69, 0x72, 0x24, 0x4D]) == "riM")
    }

    @Test func legacyBBTNasalLReachesBothPaths() {
        // BBT Unicode U+1E3B -> byte 0x8f -> V -> wl in makedeva.c.
        #expect(EncodingTables.bbtToUnicode[0x8f] == 0x1e3b)
        #expect(EncodingTables.charConv[0x0f] == 0x56)
        #expect(MakeDevaIngest.iastToMakeDevaASCII("bhagavaḻ liṅgaiḥ") == "Bagavawl liFgEH")
        for input in ["bhagavaḻ liṅgaiḥ", "bhagaval\u{0331} liṅgaiḥ"] {
            #expect(MakeDevaUnicode.convertLine(input) == "भगवँल्लिङ्गैः")
            #expect(MakeDevaUnicode.customPathUnicode(input) == "भगवँल्लिङ्गैः")
        }
    }

    @Test func unicodeAvagrahaSpellingsReachCustomPath() {
        // SB 8.1.1 uses a curly apostrophe; the existing straight form is the control.
        for input in ["so'ham", "so’ham", "so ’ham", "so\u{00a0}’ham"] {
            #expect(MakeDevaUnicode.customPathUnicode(input) == "सोऽहम्", "input: \(input)")
        }
    }
    @Test func nonbreakingSpaceIsAnInputBoundary() {
        #expect(MakeDevaIngest.iastToMakeDevaASCII("ka\u{00a0}ma") == "ka ma")
        #expect(MakeDevaUnicode.customPathUnicode("ka\u{00a0}ma") == "क म")
        #expect(MakeDevaIngest.iastToMakeDevaASCII("so’ham") == "so'ham")
    }

    @Test func collapsedRephaAnusvaraAtSpliceRetainsSyllable() {
        // C devaline.c:1060–1072 folds repha+anusvara into < or >.
        // The mark can occur inside a font-table splice, not only after it.
        for (iast, ascii, glyphs, expected) in [
            ("rhaṁ", "rhaM", [0x68, 0x3C, 0x22], "र्हं"),
            ("rhiṁ", "rhiM", [0x69, 0x68, 0x3C, 0x22], "र्हिं"),
            ("rheṁ", "rheM", [0x68, 0x65, 0x3C, 0x22], "र्हें"),
            ("rhaiṁ", "rhEM", [0x68, 0x45, 0x3E, 0x22], "र्हैं"),
            ("rhuṁ", "rhuM", [0xF2, 0x3C, 0x22], "र्हुं"),
            ("rhūṁ", "rhUM", [0xF3, 0x3C, 0x22], "र्हूं")
        ] {
            let bytes = glyphs.map(UInt8.init)
            #expect(LineConversion.convertLine(ascii).glyphs == bytes)
            #expect(MakeDevaUnicode.decodeUnicode(bytes) == expected)
            #expect(MakeDevaUnicode.customPathUnicode(iast) == expected)
        }
        #expect(MakeDevaUnicode.customPathUnicode("devarṣir haṁsayānena") == "देवर्षिर्हंसयानेन")
        // Ordinary repha / a following long-vowel mark remain separate cases.
        #expect(MakeDevaUnicode.customPathUnicode("rhe") == "र्हे")
        #expect(MakeDevaUnicode.customPathUnicode("rhīṁ") == "र्हीं")
    }
    @Test func vocalicRWithRephaSurvivesReverseDecode() {
        for (input, expected) in [("rṛ", "रृ"), ("rṝ", "रॄ"), ("nirṛtiṁ", "निरृतिं")] {
            #expect(MakeDevaUnicode.customPathUnicode(input) == expected)
        }
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII([0x5B, 0x52, 0x25]) == "rR")
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII([0x5C, 0x52, 0x23]) == "rY")
    }

    @Test func splicedRephaPrecedesWholeConjunct() {
        for (input, expected) in [("rccha", "र्च्छ"), ("mūrcchitena", "मूर्च्छितेन"), ("ccha", "च्छ")] {
            #expect(MakeDevaUnicode.customPathUnicode(input) == expected)
        }
        #expect(MakeDevaGlyphDecode.reconstructMakeDevaASCII([0x63, 0x43, 0x52, 0x24]) == "rcCa")
    }
}

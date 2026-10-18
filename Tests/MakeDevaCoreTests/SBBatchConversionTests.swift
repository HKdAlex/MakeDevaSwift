import Foundation
import Testing
@testable import MakeDevaCore

struct SBBatchConversionTests {
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

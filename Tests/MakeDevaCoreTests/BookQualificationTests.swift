import Foundation
import Testing
@testable import MakeDevaCore

struct BookQualificationTests {
    @Test func literalSanskritSpelling() {
        for (input, expected) in [
            ("buddhi", "बुद्धि"), ("pāṇḍava", "पाण्डव"),
            ("upasaṅgamya", "उपसङ्गम्य"), ("so'ham", "सोऽहम्"),
            ("so’ham", "सोऽहम्"), ("bhoktuṁ", "भोक्तुं"),
            ("tyaktuṁ", "त्यक्तुं"), ("nirdeśo", "निर्देशो"),
            ("ḍha", "ढ"), ("ddha", "द्ध"), ("ai au ṝ ḹ", "ऐ औ ॠ ॡ")
        ] {
            #expect(MakeDevaUnicode.convertLine(input) == expected, "\(input)")
        }
        #expect(MakeDevaUnicode.convertLine("kr̥ṣṇa") == "क्r̥ष्ण") // unsupported spelling stays visible
        #expect(MakeDevaUnicode.convertLine("kṛṣṇa") == "कृष्ण") // NFD IAST
    }

    @Test func glyphClustersAreNotLost() {
        for (input, expected) in [
            ("bhoktuṁ", "भोक्तुं"), ("tyaktuṁ", "त्यक्तुं"),
            ("nirdeśo", "निर्देशो"), ("anirdeśyam", "अनिर्देश्यम्"),
            ("vidur devā", "विदुर्देवा")
        ] {
            #expect(MakeDevaUnicode.customPathUnicode(input) == expected, "\(input)")
        }
    }

    @Test func sourceSpacingAndGlyphSpacingAgree() {
        for input in ["tad buddhi", "tad bū", "tad bṛ", "tad gū", "tad gṛ", "īdṛṅ mamedam", "tad guru", "tad baka"] {
            #expect(MakeDevaUnicode.convertLine(input) == MakeDevaUnicode.customPathUnicode(input), "\(input)")
        }
    }

    @Test func legacyAvagrahaAnusvaraOrderingIsExplicit() {
        // C deliberately lifts the anusvara before avagraha (devaline.c:1576).
        // This glyph order is not the logical spelling retained by Unicode output.
        #expect(MakeDevaUnicode.convertLine("tejo'ṁśa") == "तेजोऽंश")
        #expect(MakeDevaUnicode.customPathUnicode("tejo'ṁśa") == "तेजोंऽश")
    }
}

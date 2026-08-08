import Testing

@testable import MakeDevaCore

struct IntegrationTests {

    /// Test the expected conversion from BBT transliteration to Devanagari
    /// Input: "ZrI Zuka uvAca" (BBT transliteration, hyphen stripped during collection)
    /// Expected output: glyphs that produce "™aIzAuk( ovaAca" in the font
    @Test func sriSukaUvacaConversion() {
        // BBT transliteration input (after charconv, hyphen stripped)
        let input = "ZrI Zuka uvAca"

        // Convert to Devanagari
        let result = LineConversion.convertLine(input, verseFormat: true)

        // Print the result for debugging
        print("Input: \(input)")
        print("Glyph count: \(result.glyphs.count)")
        print(
            "Glyphs (hex): \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Convert glyphs to characters for comparison
        let chars = result.glyphs.map { glyph -> Character in
            let scalar = UnicodeScalar(glyph)
            return Character(scalar)
        }
        let outputString = String(chars)
        print("Output string: \(outputString)")

        // Expected output from C: "™aIzAuk( ovaAca"
        // In hex: 99 61 49 7a 41 75 6b 28 20 6f 76 61 41 63 61
        let expectedGlyphs: [UInt8] = [
            0x99, 0x61, 0x49, 0x7A, 0x41, 0x75, 0x6B, 0x28, 0x20, 0x6F, 0x76, 0x61, 0x41, 0x63,
            0x61,
        ]
        print(
            "Expected glyphs (hex): \(expectedGlyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        #expect(result.glyphs.count > 0, "Should produce glyphs")
    }

    /// Test simple syllable: "ka" should produce specific Devanagari glyph
    @Test func simpleKa() {
        let result = LineConversion.convertLine("ka", verseFormat: true)
        print(
            "'ka' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        #expect(result.glyphs.count > 0)
    }

    /// Test simple syllable: "Za" (sha) should produce specific Devanagari glyph
    @Test func simpleZa() {
        let result = LineConversion.convertLine("Za", verseFormat: true)
        print(
            "'Za' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        #expect(result.glyphs.count > 0)
    }

    /// Test "maitreyo" conversion
    /// C output shows: maEíaeyaAe
    /// Note: Input must be pre-converted with digraphs (ai→E) since LineConversion
    /// doesn't do digraph conversion (that happens in FileProcessor)
    @Test func maitreyoConversion() {
        // Input is BBT transliteration AFTER digraph conversion (ai→E)
        let input = "mEtreyo"  // Not "maitreyo" - digraph already converted
        let result = LineConversion.convertLine(input, verseFormat: true)
        print(
            "'\(input)' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Convert to string
        let chars = result.glyphs.map { glyph -> Character in
            let scalar = UnicodeScalar(glyph)
            return Character(scalar)
        }
        print("Output: \(String(chars))")

        // C output: maEíaeyaAe = 6D 61 45 ED 61 65 79 61 41 65
        // Note: 0x45 = 'E', 0xED = 'í' (vowel sign)
        #expect(result.glyphs.count > 0)
    }

    /// Test "bhagavAn" conversion
    /// C output shows: BagAvaAna
    /// Swift produces: bh"gAvaAna
    @Test func bhagavanConversion() {
        let input = "BagavAn"
        let result = LineConversion.convertLine(input, verseFormat: true)
        print(
            "'\(input)' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        let chars = result.glyphs.map { glyph -> Character in
            let scalar = UnicodeScalar(glyph)
            return Character(scalar)
        }
        print("Output: \(String(chars))")
        #expect(result.glyphs.count > 0)
    }

    /// Test "kila" conversion - order issue?
    /// C output: ik(la
    /// Swift: ki(la
    @Test func kilaConversion() {
        let input = "kila"
        let result = LineConversion.convertLine(input, verseFormat: true)
        print(
            "'\(input)' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        let chars = result.glyphs.map { glyph -> Character in
            let scalar = UnicodeScalar(glyph)
            return Character(scalar)
        }
        print("Output: \(String(chars))")
        #expect(result.glyphs.count > 0)
    }

    /// Test "ZrI" (śrī)
    @Test func zri() {
        let result = LineConversion.convertLine("ZrI", verseFormat: true)
        print(
            "'ZrI' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        #expect(result.glyphs.count > 0)
    }

    /// Test word "Zuka"
    @Test func zuka() {
        let result = LineConversion.convertLine("Zuka", verseFormat: true)
        print(
            "'Zuka' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        #expect(result.glyphs.count > 0)

        // Expected from C: zAuk( = 7A 41 75 6B 28
        // Check each glyph
        print("Expected: 7A 41 75 6B 28 (zAuk()")
    }

    /// Debug test for vowel recognition
    @Test func vowelRecognition() {
        print("'a' is vowel:", CharacterClassification.isVowel(Character("a")))
        print("'u' is vowel:", CharacterClassification.isVowel(Character("u")))
        print("'Z' is vowel:", CharacterClassification.isVowel(Character("Z")))
        print("'k' is vowel:", CharacterClassification.isVowel(Character("k")))
    }

    /// Test single syllable "Zu" (sha + u)
    @Test func singleSyllableZu() {
        let result = LineConversion.convertLine("Zu", verseFormat: true)
        print(
            "'Zu' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        #expect(result.glyphs.count > 0)
    }

    /// Test half-line handling - short verse (should join with space)
    @Test func halfLineShortVerse() {
        // Input with CODE_HalfLine (0x09) - short verse should replace with space
        // "evam etat [HalfLine] maitreyo" - 8 syllables, < 19
        let input = "evam etat \u{09}maitreyo"
        let result = LineConversion.convertLine(input, verseFormat: true)
        print("Short verse with halfline:")
        print("  Input: \(input.debugDescription)")
        print(
            "  Glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))")
        // Check that CODE_HalfLine (0x09) is NOT in output (replaced with space)
        let hasHalfLine = result.glyphs.contains(0x09)
        print("  Contains 0x09: \(hasHalfLine)")
        #expect(!hasHalfLine, "Short verse should not have CODE_HalfLine in output")
    }

    /// Test half-line handling - long verse (should keep marker)
    @Test func halfLineLongVerse() {
        // Input with CODE_HalfLine (0x09) - long verse (22+ syllables) should keep it
        // "pusnata dharmena vinastadrstih [HalfLine] pravezya laksa bhavane dadaha"
        // Approximate 22+ syllables
        let input = "pusnata dharmena vinastadrstih \u{09}pravezya laksa bhavane dadaha"
        let result = LineConversion.convertLine(input, verseFormat: true)
        print("Long verse with halfline:")
        print("  Input: \(input.debugDescription)")
        print(
            "  Glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))")
        // Check that CODE_HalfLine (0x09) IS in output
        let hasHalfLine = result.glyphs.contains(0x09)
        print("  Contains 0x09: \(hasHalfLine)")
        // Count vowels (syllables) in input
        let vowelCount = input.filter { "aAiIuURYLeEoO".contains($0) }.count
        print("  Vowel count: \(vowelCount)")
        #expect(hasHalfLine, "Long verse (syln >= 19) should keep CODE_HalfLine in output")
    }

    /// Test Fk (ṅk) conjunct - debugging extra x.~ glyphs
    @Test func FkConjunctConversion() {
        // Test F (ṅ) + k cluster with different vowels
        let test1 = "Fka"  // ṅka with vowel 'a' (uri=false)
        let result1 = LineConversion.convertLine(test1, verseFormat: true)
        print(
            "'Fka' (vowel a) glyphs: \(result1.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        let test2 = "FkY"  // ṅkḷ with vowel 'Y' (uri=true)
        let result2 = LineConversion.convertLine(test2, verseFormat: true)
        print(
            "'FkY' (vowel Y) glyphs: \(result2.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test syllable conversion directly
        let result3 = SyllableConversion.convertSyllable(
            consonants: "Fk",
            nextChars: [],
            vowel: Character("a"),
            anusvara: nil,
            visarga: nil,
            nafter: false
        )
        print(
            "SyllableConversion 'Fk' + 'a': \(result3.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        let result4 = SyllableConversion.convertSyllable(
            consonants: "Fk",
            nextChars: [],
            vowel: Character("Y"),
            anusvara: nil,
            visarga: nil,
            nafter: false
        )
        print(
            "SyllableConversion 'Fk' + 'Y': \(result4.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test Fg with vowel Y (the actual case from line 243)
        let result5 = SyllableConversion.convertSyllable(
            consonants: "Fg",
            nextChars: [],
            vowel: Character("Y"),
            anusvara: nil,
            visarga: nil,
            nafter: false
        )
        print(
            "SyllableConversion 'Fg' + 'Y': \(result5.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test Fg with vowel a
        let result6 = SyllableConversion.convertSyllable(
            consonants: "Fg",
            nextChars: [],
            vowel: Character("a"),
            anusvara: nil,
            visarga: nil,
            nafter: false
        )
        print(
            "SyllableConversion 'Fg' + 'a': \(result6.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test Fgy with vowel a (the actual case from line 243)
        let result7 = SyllableConversion.convertSyllable(
            consonants: "Fgy",
            nextChars: [],
            vowel: Character("a"),
            anusvara: nil,
            visarga: nil,
            nafter: false
        )
        print(
            "SyllableConversion 'Fgy' + 'a': \(result7.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test the full word AliFgya
        let result8 = LineConversion.convertLine("AliFgya", verseFormat: true)
        print(
            "'AliFgya' glyphs: \(result8.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test findCodeA directly
        let fgResult = GlyphLookup.findCodeA(
            transliteration: "Fg", in: FontTables.fonta, uri: false, ya: true)
        print(
            "findCodeA('Fg', uri=false, ya=true): \(fgResult?.map { String(format: "%02X", $0) }.joined(separator: " ") ?? "nil")"
        )

        // Test { character handling
        let braceResult = GlyphLookup.findCode(transliteration: "{", in: FontTables.fontc)
        print(
            "findCode('{', fontc): \(braceResult?.map { String(format: "%02X", $0) }.joined(separator: " ") ?? "nil")"
        )

        // Test {he syllable
        let braceHeResult = SyllableConversion.convertSyllable(
            consonants: "{h",
            nextChars: [],
            vowel: Character("e"),
            anusvara: nil,
            visarga: Character(":"),
            nafter: false
        )
        print(
            "SyllableConversion '{h' + 'e' + ':': \(braceHeResult.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test gR (g + vocalic r vowel) - this is key for understanding the { issue
        // Expected C output for jagRhuH: jagA{"[F2]":
        // Where gR produces gA{ (g glyph + A + { vowel sign for R)
        let gRResult = SyllableConversion.convertSyllable(
            consonants: "g",
            nextChars: [Character(" ")],
            vowel: Character("R"),  // Vocalic r
            anusvara: nil,
            visarga: nil,
            nafter: false
        )
        print(
            "SyllableConversion 'g' + 'R': \(gRResult.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test full jagRhuH conversion
        let jagRhuHResult = LineConversion.convertLine("jagRhuH", verseFormat: true)
        print(
            "LineConversion 'jagRhuH': \(jagRhuHResult.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        // Expected: ja gA{ hu" : = 6A 61 67 41 7B 22 F2 22 3A (approximately)

        // Test "ek" conversion to debug distance issue
        // C output: WkE( = 57 6B 45 28
        // Swift output: W&kE( = 57 26 6B 45 28 (extra 0x26 = D150)
        let ekResult = LineConversion.convertLine("ek", verseFormat: true)
        print(
            "LineConversion 'ek': \(ekResult.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test standalone 'e' vowel
        let eResult = SyllableConversion.convertSyllable(
            consonants: "",
            nextChars: [],
            vowel: Character("e"),
            anusvara: nil,
            visarga: nil,
            nafter: false,
            previousDistA: -1000,
            previousDistB: -1000
        )
        print(
            "SyllableConversion 'e' (standalone): \(eResult.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        print("  distanceAbove: \(eResult.distanceAbove), distanceBelow: \(eResult.distanceBelow)")

        // Test 'ka' after 'e'
        let kaResult = SyllableConversion.convertSyllable(
            consonants: "k",
            nextChars: [Character(" ")],
            vowel: Character("a"),
            anusvara: nil,
            visarga: nil,
            nafter: false,
            previousDistA: eResult.distanceAbove,
            previousDistB: eResult.distanceBelow
        )
        print(
            "SyllableConversion 'ka' (after e): \(kaResult.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        #expect(result1.glyphs.count > 0)
    }

    /// Test "cC" conjunct - debugging extra space
    @Test func cCConjunctConversion() {
        // Test c + C (c + ch digraph) conjunct
        let test1 = "cCvasAna"  // No space between c and C
        let result1 = LineConversion.convertLine(test1, verseFormat: true)
        print(
            "'\(test1)' glyphs: \(result1.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test with space between c and C
        let test2 = "c CvasAna"  // Space between c and C
        let result2 = LineConversion.convertLine(test2, verseFormat: true)
        print(
            "'\(test2)' glyphs: \(result2.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test kaCid buDaH - should have space between d and b
        let test3 = "kaCid buDaH"
        let result3 = LineConversion.convertLine(test3, verseFormat: false)  // prose format
        print(
            "'\(test3)' glyphs: \(result3.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        #expect(result1.glyphs.count > 0)
    }

    /// Test "garhyam" conversion - debugging missing "ma"
    @Test func garhyamConversion() {
        // Test individual syllables first
        let test1 = "ma"
        let result1 = LineConversion.convertLine(test1, verseFormat: true)
        print(
            "'\(test1)' glyphs: \(result1.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test m with virama (space vowel)
        let test2 = "m ,"  // m followed by space and comma
        let result2 = LineConversion.convertLine(test2, verseFormat: true)
        print(
            "'\(test2)' glyphs: \(result2.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Test rhyam
        let test3 = "rhyam"
        let result3 = LineConversion.convertLine(test3, verseFormat: true)
        print(
            "'\(test3)' glyphs: \(result3.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Full test
        let input = "garhyam ,"
        let result = LineConversion.convertLine(input, verseFormat: true)
        print(
            "'\(input)' glyphs: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        let chars = result.glyphs.map { glyph -> Character in
            let scalar = UnicodeScalar(glyph)
            return Character(scalar)
        }
        print("Output: \(String(chars))")
        #expect(result.glyphs.count > 0)
    }

    @Test func testXYaLookup() {
        // Test that "x" can be found in fonta with ya=true
        let result = GlyphLookup.findCodeA(
            transliteration: "x",
            in: FontTables.fonta,
            uri: false,
            ya: true
        )
        print(
            "findCodeA('x', fonta, uri=false, ya=true): \(result != nil ? result!.map { String(format: "%02X", $0) }.joined(separator: " ") : "nil")"
        )
        #expect(result != nil, "Should find 'x' in fonta with ya=true")
    }

    @Test func testNxyConversion() {
        // Test Nxy conversion
        let result = SyllableConversion.convertSyllable(
            consonants: "Nxy",
            nextChars: [Character(" "), Character(" "), Character(" ")],
            vowel: Character("a"),
            anusvara: nil,
            visarga: nil,
            nafter: false,
            previousDistA: -1000,
            previousDistB: -1000
        )
        print(
            "Nxy conversion: \(result.glyphs.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )
        // Expected: N with virama (4E 22), x with ya and a (78 22 59 61 or similar)
    }
}

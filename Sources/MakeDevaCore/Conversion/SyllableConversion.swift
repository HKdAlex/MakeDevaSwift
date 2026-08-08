/// Syllable conversion for Devanagari text
///
/// This module provides the core syllable conversion function that converts
/// Sanskrit transliteration syllables to Devanagari glyph codes.
///
/// The implementation matches `convertsyllable()` in `devaline.c` lines 844-1258.

import Foundation

/// Result of syllable conversion
public struct SyllableConversionResult {
    /// Array of glyph codes representing the converted syllable
    public let glyphs: [UInt8]

    /// Distance metrics for anusvara positioning (if applicable)
    public let distanceAbove: Int
    public let distanceBelow: Int

    public init(glyphs: [UInt8], distanceAbove: Int = 0, distanceBelow: Int = 0) {
        self.glyphs = glyphs
        self.distanceAbove = distanceAbove
        self.distanceBelow = distanceBelow
    }
}

/// Syllable conversion utilities
public enum SyllableConversion {
    // Constants matching C source
    private static let CONSMAX = 20
    private static let DEVAMAX = 100

    /// Convert a Sanskrit transliteration syllable to Devanagari glyph codes
    ///
    /// This function matches the behavior of `convertsyllable()` in `devaline.c` lines 844-1258.
    ///
    /// - Parameters:
    ///   - consonants: The consonant string (empty for standalone vowels)
    ///   - nextChars: Array of next characters after each consonant (for lookahead)
    ///   - vowel: The vowel character (a, A, i, I, u, U, R, Y, L, e, E, o, O, or space for virama)
    ///   - anusvara: Anusvara character ('M' for anusvara, '*' for anunasika, or nil)
    ///   - visarga: Visarga character (':' or nil)
    ///   - nafter: Whether 'n' should be merged after the syllable
    ///   - previousDistA: Distance above from previous syllable (default -1000 for first syllable)
    ///   - previousDistB: Distance below from previous syllable (default -1000 for first syllable)
    /// - Returns: Result containing glyph codes and distance metrics
    public static func convertSyllable(
        consonants: String,
        nextChars: [Character] = [],
        vowel: Character?,
        anusvara: Character? = nil,
        visarga: Character? = nil,
        nafter: Bool = false,
        previousDistA: Int = -1000,
        previousDistB: Int = -1000
    ) -> SyllableConversionResult {
        var glyphs: [UInt8] = []
        var distanceAbove: Int = 0
        var distanceBelow: Int = 0
        
        // Use previous syllable's distance values for spacing calculation
        // In C, dista/distb are persistent and reset to 0 after each syllable
        // For the first syllable, they start at -1000 (meaning no spacing needed)
        var inputDistA = previousDistA
        var inputDistB = previousDistB

        let consn = consonants.count
        let consArray = Array(consonants)

        // Handle standalone vowels (no consonants)
        if consn == 0 {
            if let vowel = vowel {
                let (vowelGlyphs, aiafter, rbefore, vowelsign, anusvaraConsumed) = handleStandaloneVowel(
                    vowel, anusvara: anusvara)
                
                // Build buffer for distance calculation (matching C's buf array)
                var buf: [UInt8] = []
                buf.append(contentsOf: vowelGlyphs)

                // Handle aiafter (e.g., 'A' for long ā) - matching C lines 1085-1097
                if let ai = aiafter {
                    buf.append(UInt8(ai.asciiValue ?? 0))
                }
                
                // Handle rbefore (e.g., 'R' for long ī) - matching C lines 1059-1072
                if let rb = rbefore {
                    buf.append(UInt8(rb.asciiValue ?? 0))
                }
                
                // Handle vowelsign (e.g., 'e' for 'E') - matching C lines 1106-1177
                if let vs = vowelsign {
                    buf.append(vs)
                }
                
                // Handle anusvara for standalone vowels
                // Only append if not already consumed (e.g., 'o' with anusvara becomes 'om')
                if let anu = anusvara, !anusvaraConsumed {
                    buf.append(UInt8(anu.asciiValue ?? 0))
                }
                
                let bufn = buf.count
                
                // Calculate distances for spacing - matching C lines 1204-1231
                var dista: Int = inputDistA
                var distb: Int = inputDistB
                
                // Calculate dista (above) - lines 1205-1214
                for bufi in 0..<bufn {
                    let c = buf[bufi]
                    if MetricsTables.metricsAboveLeft[Int(c)] != 0 {
                        dista -= Int(MetricsTables.metricsAboveLeft[Int(c)])
                        break
                    }
                    dista -= Int(MetricsTables.width[Int(c)])
                }
                
                // Calculate distb (below) - lines 1215-1224
                for bufi in 0..<bufn {
                    let c = buf[bufi]
                    if MetricsTables.metricsBelowLeft[Int(c)] != 0 {
                        distb -= Int(MetricsTables.metricsBelowLeft[Int(c)])
                        break
                    }
                    distb -= Int(MetricsTables.width[Int(c)])
                }
                
                // Insert spacing before output - lines 1225-1231
                let finalDist = (dista > distb ? dista : distb) + FontConstants.MINDIST
                var remainingDist = finalDist
                while remainingDist > 0 {
                    let distCode = DistanceCalculation.distanceCode(for: remainingDist)
                    glyphs.append(distCode)
                    remainingDist -= Int(MetricsTables.width[Int(distCode)])
                }
                
                // Add the buffer contents
                glyphs.append(contentsOf: buf)
                
                // Calculate final distances for next syllable - lines 1236-1257
                dista = 0
                distb = 0
                
                // Calculate dista (above, backwards)
                for bufi in stride(from: bufn - 1, through: 0, by: -1) {
                    let c = buf[bufi]
                    dista -= Int(MetricsTables.width[Int(c)])
                    if MetricsTables.metricsAboveRight[Int(c)] != 0 {
                        dista += Int(MetricsTables.metricsAboveRight[Int(c)])
                        break
                    }
                }
                
                // Calculate distb (below, backwards)
                for bufi in stride(from: bufn - 1, through: 0, by: -1) {
                    let c = buf[bufi]
                    distb -= Int(MetricsTables.width[Int(c)])
                    if MetricsTables.metricsBelowRight[Int(c)] != 0 {
                        distb += Int(MetricsTables.metricsBelowRight[Int(c)])
                        break
                    }
                }
                
                distanceAbove = dista
                distanceBelow = distb
            }
        } else {
            // Handle consonants with vowels (lines 908-1037)
            var consi = 0
            var consn = consn
            var rbefore: Character? = nil
            var aiafter: Character? = nil
            var vowelsign: UInt8? = nil
            var yafter = false
            var uri = false
            var code: UInt32 = 0
            var deva: [UInt8] = []
            var devan = 0
            var lastvirama = 0  // Initialize to 0, matching C (line 874)

            // Handle r-before (repha) - lines 910-915
            if consn > 1 && consArray[0] == Character("r") {
                rbefore = Character("R")
                consn -= 1
                consi += 1
            }

            // Look up consonant+vowel combination - lines 917-974
            // Try progressively shorter substrings from the start
            var consn1 = consn
            var found = false
            var consumedChars = 0
            // Track if match was from vowel-specific table (fontu, fontuu, etc.)
            // Only clear vowel if found in these tables, not in fonta with uri=true
            var foundInVowelTable = false

            for offset in 0..<consn {
                let startIdx = consi + offset
                let remainingLen = consn - offset
                let endIdx = min(startIdx + remainingLen, consArray.count)
                let cons1 = String(consArray[startIdx..<endIdx])
                let cons1n = remainingLen

                // Try lookup based on vowel
                // IMPORTANT: uri must be set UNCONDITIONALLY for u/U/R/Y/L/space vowels
                // (matching C code lines 923, 927, 936, 945, 949, 953)
                // This affects which entries in fonta will match later
                if let vowel = vowel {
                    switch vowel {
                    case "u":
                        uri = true  // Set UNCONDITIONALLY, before lookup
                        if let foundCode = GlyphLookup.findCode(
                            transliteration: cons1, in: FontTables.fontu)
                        {
                            code = codeArrayToUInt32(foundCode)
                            found = true
                            foundInVowelTable = true  // Match from fontu - clear vowel
                            consn1 = cons1n
                        }
                    case "U":
                        uri = true  // Set UNCONDITIONALLY, before lookup
                        if let foundCode = GlyphLookup.findCode(
                            transliteration: cons1, in: FontTables.fontuu)
                        {
                            code = codeArrayToUInt32(foundCode)
                            found = true
                            foundInVowelTable = true  // Match from fontuu - clear vowel
                            consn1 = cons1n
                        }
                    case "R":
                        uri = true  // Set UNCONDITIONALLY, before lookup
                        if let foundCode = GlyphLookup.findCode(
                            transliteration: cons1, in: FontTables.fontR)
                        {
                            code = codeArrayToUInt32(foundCode)
                            if code == 1 {  // "rR"
                                code = 0x25205B
                                rbefore = Character("R")
                            }
                            found = true
                            foundInVowelTable = true  // Match from fontR - clear vowel
                            consn1 = cons1n
                        }
                    case "Y":
                        uri = true  // Set UNCONDITIONALLY, before lookup
                        if let foundCode = GlyphLookup.findCode(
                            transliteration: cons1, in: FontTables.fontY)
                        {
                            code = codeArrayToUInt32(foundCode)
                            if code == 2 {  // "rY"
                                code = 0x23205C
                                rbefore = Character("R")
                            }
                            found = true
                            foundInVowelTable = true  // Match from fontY - clear vowel
                            consn1 = cons1n
                        }
                    case "L":
                        uri = true  // Set UNCONDITIONALLY, before lookup
                        if let foundCode = GlyphLookup.findCode(
                            transliteration: cons1, in: FontTables.fontL)
                        {
                            code = codeArrayToUInt32(foundCode)
                            found = true
                            foundInVowelTable = true  // Match from fontL - clear vowel
                            consn1 = cons1n
                        }
                    case " ":
                        uri = true  // Set UNCONDITIONALLY, before lookup
                        if let foundCode = GlyphLookup.findCode(
                            transliteration: cons1, in: FontTables.fontv)
                        {
                            code = codeArrayToUInt32(foundCode)
                            found = true
                            foundInVowelTable = true  // Match from fontv - clear vowel
                            consn1 = cons1n
                        }
                    default:
                        uri = false
                    }
                }

                if found {
                    // Found a match - consume the matched substring
                    consn1 = cons1n
                    break
                }

                // Try findcodea with uri flag
                if let foundCode = GlyphLookup.findCodeA(
                    transliteration: cons1, in: FontTables.fonta, uri: uri, ya: false)
                {
                    code = codeArrayToUInt32(foundCode)
                    found = true
                    consn1 = cons1n
                    break
                }

                // Try findcodea with ya flag (if last char is 'y')
                // C code: if (consn1>1 && cons1[consn1-1]=='y' && findcodea(cons1,consn1-1,...))
                // The C code keeps consn1 as the REMAINING length at this offset, not the full length.
                // This is because cons1 points to the substring starting at offset, and consn1
                // is the length of that substring. When we match, we consume consn1 characters
                // from the END of the consonant string, leaving the characters before offset
                // for the while loop to process.
                if cons1n > 1 && endIdx > startIdx && consArray[endIdx - 1] == Character("y") {
                    let consWithoutY = String(consArray[startIdx..<(endIdx - 1)])
                    if let foundCode = GlyphLookup.findCodeA(
                        transliteration: consWithoutY, in: FontTables.fonta, uri: false, ya: true)
                    {
                        code = codeArrayToUInt32(foundCode)
                        yafter = true
                        found = true
                        // Set consn1 to the remaining length at this offset
                        // This leaves 'offset' characters for the while loop to process
                        consn1 = cons1n
                        break
                    }
                }
            }

            // Update consn based on what was consumed (matching C: consn -= consn1)
            // This removes the consumed characters from the remaining consonants
            consn -= consn1

            // If a match was found in vowel-specific table (fontu, fontuu, etc.),
            // clear the vowel (matching C: vowel=0 at line 962)
            // NOTE: Do NOT clear vowel when found in fonta with uri=true - the vowel
            // sign should still be added. Only clear when found in fontu/fontuu/fontR/fontY/fontL/fontv.
            // The 'uri' flag being set and 'found' being true from the vowel switch case
            // means it was found in a vowel-specific table.

            // Build deva array from remaining consonants - lines 977-1018
            while consn > 0 {
                var code1: UInt32 = 0
                var consumed = 0

                // Try 3-char, 2-char, then 1-char lookup in fontc
                if consn >= 3 {
                    let threeChar = String(consArray[consi..<(consi + 3)])
                    if let foundCode = GlyphLookup.findCode(
                        transliteration: threeChar, in: FontTables.fontc)
                    {
                        code1 = codeArrayToUInt32(foundCode)
                        consumed = 3
                    }
                }

                if code1 == 0 && consn >= 2 {
                    let twoChar = String(consArray[consi..<(consi + 2)])
                    if let foundCode = GlyphLookup.findCode(
                        transliteration: twoChar, in: FontTables.fontc)
                    {
                        code1 = codeArrayToUInt32(foundCode)
                        consumed = 2
                    }
                }

                if code1 == 0 {
                    let oneChar = String(consArray[consi])
                    if let foundCode = GlyphLookup.findCode(
                        transliteration: oneChar, in: FontTables.fontc)
                    {
                        code1 = codeArrayToUInt32(foundCode)
                        consumed = 1
                    }
                }

                if code1 == 0 {
                    break
                }

                consi += consumed
                consn -= consumed

                // Extract bytes from code1 and add to deva
                var virama = false
                while code1 != 0 {
                    let byte = UInt8(code1 & 0xFF)
                    if byte != UInt8(ascii: " ") {
                        deva.append(byte)
                        devan += 1
                    } else {
                        // Space indicates virama
                        if let rb = rbefore {
                            deva.append(UInt8(rb.asciiValue ?? 0))
                            devan += 1
                            rbefore = nil
                        }
                        virama = true
                    }
                    code1 >>= 8
                }

                if virama {
                    // C code: if (next[consi-1]==' ') deva[devan++]=' ';
                    // This adds a space to deva if the next character after this consonant is a space.
                    // This is needed for word boundaries where a consonant with virama is followed by
                    // a space and then another word (e.g., "kaCid buDaH" → "d" with virama + space + "bu").
                    // Note: consi was already incremented, so consi-1 is the index of the consonant just processed
                    let nextIdx = consi - 1
                    if nextIdx >= 0 && nextIdx < nextChars.count && nextChars[nextIdx] == Character(" ") {
                        deva.append(UInt8(ascii: " "))
                        devan += 1
                    }
                    lastvirama = devan
                }
            }

            // Set vowel signs - lines 1020-1036
            // Only set vowel signs if vowel wasn't consumed by a match in vowel-specific table
            var effectiveVowel = vowel
            // Only clear vowel if it was found in a vowel-specific table (fontu, fontuu, etc.)
            // NOT when found in fonta with uri=true - the vowel sign should still be added
            // (matching C: vowel=0 only happens at line 962, inside the fontu/fontuu/etc block)
            if foundInVowelTable
                && (vowel == "u" || vowel == "U" || vowel == "R" || vowel == "Y" || vowel == "L"
                    || vowel == " ")
            {
                effectiveVowel = nil  // Vowel was consumed by the vowel-specific table match
            }

            if let vowel = effectiveVowel {
                switch vowel {
                case " ":
                    vowelsign = UInt8(ascii: ",")
                case "a":
                    break
                case "A":
                    aiafter = Character("A")
                case "i":
                    vowelsign = UInt8(ascii: "i")
                case "I":
                    aiafter = Character("I")
                case "u":
                    vowelsign = UInt8(ascii: "u")
                case "U":
                    vowelsign = UInt8(ascii: "U")
                case "R":
                    vowelsign = 0x7B
                case "Y":
                    vowelsign = 0x7C
                case "L":
                    vowelsign = 0x7D
                case "e":
                    vowelsign = UInt8(ascii: "e")
                case "E":
                    vowelsign = UInt8(ascii: "E")
                case "o":
                    vowelsign = UInt8(ascii: "e")
                    aiafter = Character("A")
                case "O":
                    vowelsign = UInt8(ascii: "E")
                    aiafter = Character("A")
                default:
                    break
                }
            }

            // Build output buffer - lines 1039-1258
            var buf: [UInt8] = []
            var bufn = 0
            var dist = -1000  // distance between sign above and anusvara
            var anusvaraChar = anusvara
            var visargaChar = visarga

            // Build initial buffer from deva array - lines 1043-1058
            // NOTE: C uses for(devai=0;;devai++) with break when devai>=devan
            // This allows the 'i' insertion to happen even when deva is empty (devan=0)
            // because the check happens BEFORE the break condition
            var devai = 0
            while true {
                // Insert 'i' vowel sign after last virama or at beginning (line 1046)
                if devai == lastvirama, let vs = vowelsign, vs == UInt8(ascii: "i") {
                    buf.append(vs)
                    bufn += 1
                    vowelsign = nil
                    if anusvaraChar != nil {
                        let anusvaraCode =
                            anusvaraChar == "M" ? UInt8(ascii: "M") : UInt8(ascii: "*")
                        dist =
                            Int(MetricsTables.metricsAboveRight[Int(UInt8(ascii: "i"))])
                            - Int(MetricsTables.width[Int(UInt8(ascii: "i"))])
                            - Int(MetricsTables.metricsAboveLeft[Int(anusvaraCode)])
                            + FontConstants.MINDIST
                    }
                }

                // Check break condition AFTER 'i' insertion (line 1054)
                if devai >= devan {
                    break
                }

                buf.append(deva[devai])
                bufn += 1

                if anusvaraChar != nil {
                    dist -= Int(MetricsTables.width[Int(deva[devai])])
                }

                devai += 1
            }

            // Transform r-before character based on vowelsign/anusvara - lines 1060-1072
            // NOTE: This only TRANSFORMS rbefore, does NOT output it yet!
            // The actual output happens later inside the main code loop (lines 1127-1132)
            if rbefore != nil {
                if anusvaraChar == "M" {
                    if vowelsign == UInt8(ascii: "E") || aiafter == Character("I") {
                        rbefore = Character(UnicodeScalar(0x3E))  // '>'
                    } else {
                        rbefore = Character(UnicodeScalar(0x3C))  // '<'
                    }
                    anusvaraChar = nil
                } else if vowelsign == UInt8(ascii: "E") || aiafter == Character("I") {
                    rbefore = Character(UnicodeScalar(0x3D))  // '='
                }
                // rbefore stays as 'R' (0x52) in all other cases
            }

            // Process code (vowel/consonant combination) - lines 1074-1193
            var currentCode = code
            while true {
                if currentCode == 0 {
                    // Handle ya-after
                    if yafter {
                        buf.append(UInt8(ascii: "Y"))
                        buf.append(UInt8(ascii: "a"))
                        bufn += 2
                        if anusvaraChar != nil {
                            dist -= Int(MetricsTables.width[Int(UInt8(ascii: "Y"))])
                            dist += Int(MetricsTables.width[Int(UInt8(ascii: "a"))])
                        }
                        yafter = false
                    }

                    // Handle aiafter
                    if let ai = aiafter {
                        let aiCode = UInt8(ai.asciiValue ?? 0)
                        buf.append(aiCode)
                        bufn += 1
                        if anusvaraChar != nil {
                            if ai == Character("I") {
                                dist =
                                    Int(MetricsTables.metricsAboveRight[Int(aiCode)])
                                    - Int(
                                        MetricsTables.metricsAboveLeft[
                                            Int(
                                                anusvaraChar == "M"
                                                    ? UInt8(ascii: "M") : UInt8(ascii: "*"))])
                                    + FontConstants.MINDIST
                            }
                            dist -= Int(MetricsTables.width[Int(aiCode)])
                        }
                        aiafter = nil
                    }
                }

                // Extract next byte from code
                let codeByte = UInt8(currentCode & 0xFF)
                if codeByte > UInt8(ascii: " ") {
                    buf.append(codeByte)
                    bufn += 1
                    if anusvaraChar != nil {
                        dist -= Int(MetricsTables.width[Int(codeByte)])
                    }
                } else {
                    // Handle vowel signs and anusvara - lines 1106-1177
                    if !yafter {
                        // Insert vowel signs
                        if aiafter == nil {
                            if let vs = vowelsign {
                                if anusvaraChar != nil {
                                    if vs == UInt8(ascii: "e") || vs == UInt8(ascii: "E") {
                                        dist =
                                            Int(MetricsTables.metricsAboveRight[Int(vs)])
                                            - Int(
                                                MetricsTables.metricsAboveLeft[
                                                    Int(
                                                        anusvaraChar == "M"
                                                            ? UInt8(ascii: "M") : UInt8(ascii: "*"))
                                                ])
                                            + FontConstants.MINDIST
                                    }
                                }
                                buf.append(vs)
                                bufn += 1
                                vowelsign = nil
                            }

                            // Handle r-before output - lines 1127-1132
                            // Output rbefore AFTER vowelsign, with anusvara distance calculation
                            if let rb = rbefore {
                                let rbCode = UInt8(rb.asciiValue ?? 0)
                                if anusvaraChar != nil {
                                    // Calculate distance for anusvara positioning
                                    dist =
                                        Int(MetricsTables.metricsAboveRight[Int(rbCode)])
                                        - Int(
                                            MetricsTables.metricsAboveLeft[
                                                Int(
                                                    anusvaraChar == "M"
                                                        ? UInt8(ascii: "M") : UInt8(ascii: "*"))])
                                        + FontConstants.MINDIST
                                }
                                // Always output rbefore (matching C: buf[bufn++]=(char)rbefore;)
                                buf.append(rbCode)
                                bufn += 1
                                rbefore = nil
                            }

                            // Handle anusvara positioning - lines 1135-1177
                            if let anus = anusvaraChar {
                                let anusCode = anus == "M" ? UInt8(ascii: "M") : UInt8(ascii: "*")

                                if dist > 0 && codeByte == UInt8(ascii: " ") {
                                    // Extract next byte from code
                                    currentCode >>= 8
                                    let nextByte = UInt8(currentCode & 0xFF)
                                    var d = Int(MetricsTables.width[Int(nextByte)])

                                    if nextByte == FontConstants.F___
                                        || nextByte == FontConstants.f___
                                    {
                                        buf.append(nextByte)
                                        bufn += 1
                                        dist -= d
                                    } else {
                                        // Insert distance codes before anusvara
                                        while dist > 0 {
                                            let distCode = DistanceCalculation.distanceCode(
                                                for: dist)
                                            buf.append(distCode)
                                            bufn += 1
                                            dist -= Int(MetricsTables.width[Int(distCode)])
                                            d -= Int(MetricsTables.width[Int(distCode)])
                                        }
                                        buf.append(anusCode)
                                        bufn += 1
                                        anusvaraChar = nil

                                        // Insert distance codes after anusvara
                                        while d > 0 {
                                            let distCode = DistanceCalculation.distanceCode(for: d)
                                            buf.append(distCode)
                                            bufn += 1
                                            d -= Int(MetricsTables.width[Int(distCode)])
                                        }
                                    }
                                } else if dist <= 0 || currentCode == 0 {
                                    // Insert distance codes and anusvara
                                    while dist > 0 {
                                        let distCode = DistanceCalculation.distanceCode(for: dist)
                                        buf.append(distCode)
                                        bufn += 1
                                        dist -= Int(MetricsTables.width[Int(distCode)])
                                    }
                                    buf.append(anusCode)
                                    bufn += 1
                                    anusvaraChar = nil
                                }
                            }
                        } else if aiafter == Character("I") {
                            // Calculate distance for 'I' - lines 1179-1187
                            var dist1 = 0
                            var code1 = currentCode >> 8
                            while code1 != 0 {
                                let byte = UInt8(code1 & 0xFF)
                                dist1 += Int(MetricsTables.width[Int(byte)])
                                code1 >>= 8
                            }
                            if dist1 >= 150 {
                                aiafter = Character("L")
                            }
                        }
                    }
                }

                if currentCode == 0 {
                    break
                }
                currentCode >>= 8
            }

            // Handle visarga and nafter - lines 1195-1202
            if let vis = visargaChar {
                buf.append(UInt8(vis.asciiValue ?? 0))
                bufn += 1
            }

            if nafter {
                buf.append(UInt8(ascii: "n"))
                buf.append(UInt8(ascii: "a"))
                buf.append(UInt8(ascii: ","))
                bufn += 3
            }

            // Calculate distances for spacing - lines 1204-1231
            // Use the input distances from the previous syllable
            // In C, dista/distb are persistent: initialized to -1000 at line start,
            // then reset to 0 after each syllable (lines 1236-1237)
            var dista: Int = inputDistA
            var distb: Int = inputDistB

            // Calculate dista (above) - lines 1205-1214
            for bufi in 0..<bufn {
                let c = buf[bufi]
                if MetricsTables.metricsAboveLeft[Int(c)] != 0 {
                    dista -= Int(MetricsTables.metricsAboveLeft[Int(c)])
                    break
                }
                dista -= Int(MetricsTables.width[Int(c)])
            }

            // Calculate distb (below) - lines 1215-1224
            for bufi in 0..<bufn {
                let c = buf[bufi]
                if MetricsTables.metricsBelowLeft[Int(c)] != 0 {
                    distb -= Int(MetricsTables.metricsBelowLeft[Int(c)])
                    break
                }
                distb -= Int(MetricsTables.width[Int(c)])
            }

            // Insert spacing before output - lines 1225-1231
            let finalDist = (dista > distb ? dista : distb) + FontConstants.MINDIST
            var remainingDist = finalDist
            while remainingDist > 0 {
                let distCode = DistanceCalculation.distanceCode(for: remainingDist)
                glyphs.append(distCode)
                remainingDist -= Int(MetricsTables.width[Int(distCode)])
            }

            // Add the buffer contents
            glyphs.append(contentsOf: buf)

            // Calculate final distances - lines 1236-1257
            dista = 0
            distb = 0

            // Calculate dista (above, backwards)
            for bufi in stride(from: bufn - 1, through: 0, by: -1) {
                let c = buf[bufi]
                dista -= Int(MetricsTables.width[Int(c)])
                if MetricsTables.metricsAboveRight[Int(c)] != 0 {
                    dista += Int(MetricsTables.metricsAboveRight[Int(c)])
                    break
                }
            }

            // Calculate distb (below, backwards)
            for bufi in stride(from: bufn - 1, through: 0, by: -1) {
                let c = buf[bufi]
                distb -= Int(MetricsTables.width[Int(c)])
                if MetricsTables.metricsBelowRight[Int(c)] != 0 {
                    distb += Int(MetricsTables.metricsBelowRight[Int(c)])
                    break
                }
            }

            distanceAbove = dista
            distanceBelow = distb
        }

        return SyllableConversionResult(
            glyphs: glyphs,
            distanceAbove: distanceAbove,
            distanceBelow: distanceBelow
        )
    }

    /// Handle standalone vowel conversion (lines 880-907)
    /// Returns: glyphs, aiafter, rbefore, vowelsign, and whether anusvara was consumed
    private static func handleStandaloneVowel(
        _ vowel: Character,
        anusvara: Character?
    ) -> (glyphs: [UInt8], aiafter: Character?, rbefore: Character?, vowelsign: UInt8?, anusvaraConsumed: Bool) {
        var glyphs: [UInt8] = []
        var aiafter: Character? = nil
        var rbefore: Character? = nil
        var vowelsign: UInt8? = nil
        var anusvaraConsumed = false

        switch vowel {
        case "A":
            aiafter = Character("A")
            fallthrough
        case "a":
            glyphs.append(0x40)  // Devanagari 'a'

        case "I":
            rbefore = Character("R")
            fallthrough
        case "i":
            glyphs.append(UInt8(ascii: "w"))  // Devanagari 'i'

        case "u":
            glyphs.append(UInt8(ascii: "o"))  // Devanagari 'u'

        case "U":
            glyphs.append(UInt8(ascii: "O"))  // Devanagari 'U'

        case "R":
            // Multi-byte code: 0x25205B (little-endian)
            // C code: code=0x25205BU - the 0x20 (space) is a separator that triggers
            // vowel sign handling but is NOT output. Only 0x5B and 0x25 are output.
            glyphs.append(0x5B)
            glyphs.append(0x25)

        case "Y":
            // Multi-byte code: 0x23205C (little-endian)
            // C code: code=0x23205CU - the 0x20 (space) is a separator that triggers
            // vowel sign handling but is NOT output. Only 0x5C and 0x23 are output.
            glyphs.append(0x5C)
            glyphs.append(0x23)

        case "L":
            glyphs.append(0x61)
            glyphs.append(0x6C)
            vowelsign = 0x7B

        case "E":
            vowelsign = UInt8(ascii: "e")
            fallthrough
        case "e":
            glyphs.append(UInt8(ascii: "W"))  // Devanagari 'e'

        case "O":
            glyphs.append(0x40)  // Devanagari 'a'
            aiafter = Character("A")
            vowelsign = UInt8(ascii: "E")

        case "o":
            if anusvara != nil {
                glyphs.append(UInt8(ascii: "V"))  // om
                anusvaraConsumed = true  // anusvara is consumed (matching C: anusvara=0)
            } else {
                glyphs.append(0x40)  // Devanagari 'a'
                aiafter = Character("A")
                vowelsign = UInt8(ascii: "e")
            }

        default:
            break
        }

        return (glyphs, aiafter, rbefore, vowelsign, anusvaraConsumed)
    }

    /// Convert a code array to UInt32 (matching C getcode() behavior)
    private static func codeArrayToUInt32(_ codes: [UInt8]) -> UInt32 {
        guard !codes.isEmpty else { return 0 }

        var value: UInt32 = 0
        let count = min(codes.count, 4)

        for (index, byte) in codes.prefix(4).enumerated() {
            value |= UInt32(byte) << (index * 8)
        }

        // Apply length-based masking
        switch count {
        case 1:
            return value & 0x0000_00FF
        case 2:
            return value & 0x0000_FFFF
        case 3:
            return value & 0x00FF_FFFF
        case 4:
            return value
        default:
            return 0
        }
    }
}

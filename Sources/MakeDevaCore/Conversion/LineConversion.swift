/// Line conversion for Devanagari text
///
/// This module provides the line conversion function that processes
/// a line of Sanskrit transliteration and converts it to Devanagari glyph codes.
///
/// The implementation matches `convertline()` in `devaline.c` lines 1335-1628.

import Foundation

/// Result of line conversion
public struct LineConversionResult {
    /// Array of glyph codes representing the converted line
    public let glyphs: [UInt8]
    
    /// Number of syllables in the line (for verse format)
    public let syllableCount: Int
    
    public init(glyphs: [UInt8], syllableCount: Int = 0) {
        self.glyphs = glyphs
        self.syllableCount = syllableCount
    }
}

/// Line conversion utilities
public enum LineConversion {
    // Constants matching C source
    private static let CONSMAX = 20
    private static let CODE_Nothing: UInt8 = FontConstants.CODE_Nothing
    private static let CODE_HalfLine: UInt8 = FontConstants.CODE_HalfLine
    private static let CODE_HalfLineDash: UInt8 = FontConstants.CODE_HalfLineDash
    private static let CODE_EmDash: UInt8 = FontConstants.CODE_EmDash
    
    /// Convert a line of Sanskrit transliteration to Devanagari glyph codes
    ///
    /// This function matches the behavior of `convertline()` in `devaline.c` lines 1335-1628.
    ///
    /// - Parameters:
    ///   - line: The input line as a String
    ///   - verseFormat: Whether the line is in verse format (affects syllable counting and half-line handling)
    ///   - sannyasa: Whether to apply sannyasa conversion (convert "saF" to "saM" in certain contexts)
    /// - Returns: Result containing glyph codes and metadata
    public static func convertLine(
        _ line: String,
        verseFormat: Bool = false,
        sannyasa: Bool = false
    ) -> LineConversionResult {
        var glyphs: [UInt8] = []
        var lineArray = Array(line)
        let linelen = lineArray.count
        var dista: Int = -1000
        var distb: Int = -1000
        
        // Handle sannyasa option - lines 1362-1379
        if sannyasa && linelen >= 5 {
            for linei in 2..<(linelen - 2) {
                // Check for "saF" pattern: linebuf[linei]=='F' && linebuf[linei-1]=='a' && linebuf[linei-2]=='s'
                if lineArray[linei] == Character("F"),
                   lineArray[linei - 1] == Character("a"),
                   lineArray[linei - 2] == Character("s"),
                   linei + 1 < linelen
                {
                    let nextChar = lineArray[linei + 1]
                    let nextNextChar = linei + 2 < linelen ? lineArray[linei + 2] : Character(" ")
                    
                    // Check: strchr("kKgG",linebuf[linei+1])!=NULL && strchr("aAiIeEoO",linebuf[linei+2])==NULL
                    if "kKgG".contains(nextChar),
                       !"aAiIeEoO".contains(nextNextChar)
                    {
                        lineArray[linei] = Character("M")
                    }
                }
                
                // Check for "sanny" pattern: linebuf[linei]=='n' && linebuf[linei-1]=='a' && linebuf[linei-2]=='s' && linebuf[linei+1]=='n' && linebuf[linei+2]=='y'
                if lineArray[linei] == Character("n"),
                   lineArray[linei - 1] == Character("a"),
                   lineArray[linei - 2] == Character("s"),
                   linei + 2 < linelen,
                   lineArray[linei + 1] == Character("n"),
                   lineArray[linei + 2] == Character("y")
                {
                    lineArray[linei] = Character("M")
                }
            }
        }
        
        // Count syllables for verse format - lines 1381-1423
        var syln = 0
        if verseFormat {
            // Count syllables
            for i in 0..<linelen {
                if CharacterClassification.isVowel(lineArray[i]) {
                    syln += 1
                }
            }
            
            // Join or split half-lines based on syllable count
            if syln < 19 {
                // Join half-lines: replace CODE_HalfLine with ' ', CODE_HalfLineDash with CODE_Nothing
                for linei in 0..<linelen {
                    if let ascii = lineArray[linei].asciiValue {
                        if ascii == CODE_HalfLine {
                            lineArray[linei] = Character(" ")
                        } else if ascii == CODE_HalfLineDash {
                            // Replace CODE_HalfLineDash with CODE_Nothing character
                            if let scalar = UnicodeScalar(Int(CODE_Nothing)) {
                                lineArray[linei] = Character(scalar)
                            }
                        }
                    }
                }
            } else {
                // Split at correct place (32-syllable verse) - lines 1405-1422
                for linei in 0..<linelen {
                    if let ascii = lineArray[linei].asciiValue {
                        if ascii == CODE_HalfLine || ascii == CODE_HalfLineDash {
                            // Find optimal split point
                            let splitPos = WordMerging.splitLine(String(lineArray), at: linei)
                            if splitPos < linei {
                                // Move line break to split position
                                // Shift characters right to make room
                                for k in stride(from: linei, to: splitPos, by: -1) {
                                    lineArray[k] = lineArray[k - 1]
                                }
                                // Insert CODE_HalfLineDash at split position
                                if let scalar = UnicodeScalar(Int(CODE_HalfLineDash)) {
                                    lineArray[splitPos] = Character(scalar)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Convert to Devanagari and process line - lines 1425-1607
        var linei = 0
        var spaces = 0
        
        while linei < linelen {
            let c = lineArray[linei]
            guard let cAscii = c.asciiValue else {
                linei += 1
                continue
            }
            
            // Handle special codes - lines 1429-1510
            switch cAscii {
            case CODE_Nothing:
                linei += 1
                continue
                
            case UInt8(ascii: "-"), CODE_EmDash:
                glyphs.append(cAscii)
                dista = -1000
                distb = -1000
                linei += 1
                continue
                
            case UInt8(ascii: " "), UInt8(ascii: ","), UInt8(ascii: "."):
                // Handle punctuation and spaces - applies to BOTH verse and prose in SHELL mode
                // (C code: the #ifdef WIN block that skips this for verseformat is NOT in SHELL build)
                // Output accumulated spaces
                for _ in 0..<spaces {
                    glyphs.append(UInt8(ascii: " "))
                }
                spaces = 0
                
                // Output punctuation - comma becomes /, period becomes //
                switch c {
                case ".":
                    glyphs.append(UInt8(ascii: "/"))
                    glyphs.append(UInt8(ascii: "/"))
                case ",":
                    glyphs.append(UInt8(ascii: "/"))
                default:
                    glyphs.append(cAscii)
                }
                
                linei += 1
                // Skip following spaces
                while linei < linelen && lineArray[linei] == Character(" ") {
                    glyphs.append(UInt8(ascii: " "))
                    linei += 1
                }
                dista = -1000
                distb = -1000
                continue
                
            case UInt8(ascii: "'"):  // avagraha
                glyphs.append(cAscii)
                dista = -1000
                distb = -1000
                linei += 1
                continue
                
            case CODE_HalfLineDash:
                glyphs.append(UInt8(ascii: "-"))
                fallthrough
            case CODE_HalfLine:
                glyphs.append(CODE_HalfLine)
                dista = -1000
                distb = -1000
                linei += 1
                continue
                
            default:
                break
            }
            
            // Parse syllable - lines 1512-1594
            // NOTE: C initializes vowel to ' ' (space), not 0. If no vowel is found,
            // the space vowel triggers virama output (vowelsign=',')
            var vowel: Character? = Character(" ")  // Initialize to space (matching C line 1512)
            var anusvara: Character? = nil
            var visarga: Character? = nil
            var nafter = false
            spaces = 0
            var consn = 0
            var cons: [Character] = []
            var next: [Character] = []
            
            // Collect consonants and find vowel - lines 1519-1555
            while linei < linelen {
                let c = lineArray[linei]
                guard let cAscii = c.asciiValue else {
                    linei += 1
                    continue
                }
                
                // Handle space - in SHELL mode, applies to both verse and prose (lines 1526-1530)
                // Note: C code has #ifdef WIN that restricts this to !verseformat, but SHELL build doesn't
                if c == Character(" ") {
                    spaces += 1
                    linei += 1
                    continue
                }
                
                // Break on punctuation and digits - lines 1532-1536 (SHELL build)
                // This prevents comma, period, dash, and digits from being collected as consonants
                if ",.-0123456789".contains(c) {
                    break
                }
                
                if cAscii == CODE_Nothing {
                    linei += 1
                    continue
                }
                
                if cAscii == CODE_HalfLineDash || cAscii == CODE_HalfLine {
                    break
                }
                
                if CharacterClassification.isVowel(c) {
                    spaces = 0
                    vowel = c
                    break
                }
                
                if cAscii > UInt8(ascii: " ") && consn < CONSMAX {
                    spaces = 0
                    cons.append(c)
                    if linei + 1 < linelen {
                        next.append(lineArray[linei + 1])
                    } else {
                        next.append(Character(" "))
                    }
                    consn += 1
                }
                
                linei += 1
            }

            // Dead consonant + candrabindu: IAST `l̐` ingests as `lw`. C collects `w`
            // as a consonant; peel it as anunasika so virama-`l` keeps `*` (ICU `ल्̐`).
            if vowel == Character(" "), consn > 1, cons.last == Character("w") {
                cons.removeLast()
                consn -= 1
                anusvara = Character("*")
            }
            
            // Process vowel modifiers - lines 1557-1592
            // Only process modifiers if an actual vowel was found (not the default space)
            if vowel != Character(" ") {
                linei += 1
                
                // Check for anusvara, anunasika, visarga
                if linei < linelen {
                    if lineArray[linei] == Character("M") {
                        anusvara = Character("M")
                        linei += 1
                    }
                    if linei < linelen && lineArray[linei] == Character("w") {
                        anusvara = Character("*")
                        linei += 1
                    }
                    if linei < linelen && lineArray[linei] == Character("H") {
                        visarga = Character(":")
                        linei += 1
                    }
                    
                    // Check for avagraha and anusvara after vowel
                    for i in linei..<linelen {
                        let ch = lineArray[i]
                        if ch != Character(" ") && ch != Character("-") && ch != Character("'") {
                            if let chAscii = ch.asciiValue, chAscii != CODE_Nothing {
                                if ch == Character("M") {
                                    anusvara = Character("M")
                                }
                                break
                            }
                        }
                    }
                    
                    // Check for nx pattern
                    if anusvara == nil && visarga == nil {
                        if CharacterClassification.isNx(String(lineArray), at: linei) {
                            nafter = true
                            linei += 1
                        }
                    }
                }
            }
            
            // Convert syllable - line 1594
            let consonants = String(cons)
            let result = SyllableConversion.convertSyllable(
                consonants: consonants,
                nextChars: next,
                vowel: vowel,
                anusvara: anusvara,
                visarga: visarga,
                nafter: nafter,
                previousDistA: dista,
                previousDistB: distb
            )
            
            // Add glyphs from syllable conversion
            glyphs.append(contentsOf: result.glyphs)
            
            // Update distance metrics
            dista = result.distanceAbove
            distb = result.distanceBelow
            
            // Handle space after syllable - lines 1596-1606
            if linei < linelen && lineArray[linei] == Character(" ") {
                if linei + 1 >= linelen || lineArray[linei + 1] != Character("'") {
                    glyphs.append(UInt8(ascii: " "))
                    dista = -1000
                    distb = -1000
                }
                linei += 1
            }
        }
        
        // Handle trailing spaces for prose format - lines 1609-1627
        if !verseFormat {
            // Remove trailing spaces from output
            while !glyphs.isEmpty && glyphs.last == UInt8(ascii: " ") {
                glyphs.removeLast()
            }
            
            // Add trailing spaces from input
            for i in stride(from: linelen - 1, through: 0, by: -1) {
                if lineArray[i] == Character(" ") {
                    glyphs.append(UInt8(ascii: " "))
                } else {
                    break
                }
            }
        }
        
        return LineConversionResult(glyphs: glyphs, syllableCount: syln)
    }
}

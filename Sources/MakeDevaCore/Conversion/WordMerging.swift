/// Word merging and line splitting utilities for Devanagari text
///
/// This module provides functions for finding optimal line break positions
/// and handling word merging/hyphenation for prose format.
///
/// The implementation matches:
/// - `splitline()` in `devaline.c` lines 1303-1332
/// - Prose hyphenation logic in `makedeva.c` lines 297-364

import Foundation

/// Word merging utilities
public enum WordMerging {
    // Constants matching C source
    private static let CODE_Nothing: UInt8 = FontConstants.CODE_Nothing
    private static let CODE_Dash: UInt8 = FontConstants.CODE_Dash
    
    /// Find optimal line break position respecting syllable boundaries
    ///
    /// Matches `splitline()` in `devaline.c` lines 1303-1332.
    /// Finds the beginning of the syllable that contains the given index,
    /// respecting syllable boundaries, sandhi (isnx) patterns, and character types.
    ///
    /// - Parameters:
    ///   - line: The input line as a String
    ///   - index: The position in the line where we want to find the optimal break
    /// - Returns: The optimal break position (beginning of syllable)
    public static func splitLine(_ line: String, at index: Int) -> Int {
        guard index > 0 && index < line.count else { return index }
        
        let lineArray = Array(line)
        let linelen = line.count
        var i = index
        
        // Go to beginning of syllable - lines 1309-1316
        while i > 0 {
            let prevChar = lineArray[i - 1]
            
            // Check if previous character ends a syllable or is not Sanskrit
            if CharacterClassification.endsSyllable(prevChar)
                || !CharacterClassification.isSanskrit(prevChar)
                || CharacterClassification.isNx(line, at: i - 1)
            {
                break
            }
            i -= 1
        }
        
        // Skip whitespace and CODE_Nothing - lines 1317-1318
        while i < index {
            let char = lineArray[i]
            if let ascii = char.asciiValue {
                if ascii <= UInt8(ascii: " ") || ascii == CODE_Nothing {
                    i += 1
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        // Find second character of syllable - lines 1319-1329
        if i < index {
            // Find second character (skip whitespace and CODE_Nothing)
            var k = i + 1
            while k < linelen {
                let char = lineArray[k]
                if let ascii = char.asciiValue {
                    if ascii <= UInt8(ascii: " ") || ascii == CODE_Nothing {
                        k += 1
                    } else {
                        break
                    }
                } else {
                    break
                }
            }
            
            if k < linelen {
                let firstChar = lineArray[i]
                let secondChar = lineArray[k]
                
                // Check if we should move to second character
                // Conditions: (!sanschar(linebuf[k]) || ...)
                if !CharacterClassification.isSanskrit(secondChar)
                    || ("kgFqxNtdn".contains(firstChar)
                        && !CharacterClassification.isVowel(secondChar)
                        && (secondChar != Character("y") && secondChar != Character("v")
                            || (k + 1 < linelen && lineArray[k + 1] > Character(" "))))
                {
                    i = k
                }
            }
        }
        
        return i
    }
    
    /// Find word boundaries in text
    ///
    /// Finds the start and end of the current word, and the start of the next word.
    /// Matches word boundary detection logic from `makedeva.c` lines 311-331.
    ///
    /// - Parameters:
    ///   - text: The input text
    ///   - startIndex: Starting position to search from
    ///   - endIndex: Ending position (exclusive)
    /// - Returns: Tuple with (wordStart, wordEnd, nextWordStart)
    public static func findWordBoundaries(
        _ text: String,
        startIndex: Int,
        endIndex: Int
    ) -> (wordStart: Int, wordEnd: Int, nextWordStart: Int) {
        let textArray = Array(text)
        let textLen = min(endIndex, text.count)
        
        var wordStart = startIndex
        var wordEnd = startIndex
        var nextWordStart = textLen
        
        // Find beginning of current word (skip whitespace)
        while wordStart < textLen {
            let char = textArray[wordStart]
            if let ascii = char.asciiValue, ascii > UInt8(ascii: " ") {
                break
            }
            wordStart += 1
        }
        
        if wordStart >= textLen {
            return (wordStart, wordStart, textLen)
        }
        
        // Find end of word - lines 312-322
        wordEnd = wordStart
        while wordEnd < textLen {
            let char = textArray[wordEnd]
            guard let ascii = char.asciiValue else {
                wordEnd += 1
                continue
            }
            
            // End of word: space (but not before comma) or CODE_Dash
            if ascii <= UInt8(ascii: " ") {
                if wordEnd + 1 >= textLen || textArray[wordEnd + 1] != Character(",") {
                    break
                }
            }
            
            if ascii == CODE_Dash {
                break
            }
            
            wordEnd += 1
        }
        
        // Find beginning of next word - lines 324-330
        nextWordStart = wordEnd
        while nextWordStart < textLen {
            let char = textArray[nextWordStart]
            if let ascii = char.asciiValue {
                if ascii > UInt8(ascii: " ") && ascii != CODE_Dash {
                    break
                }
            }
            nextWordStart += 1
        }
        
        return (wordStart, wordEnd, nextWordStart)
    }
    
    /// Calculate width of a glyph sequence
    ///
    /// Calculates the total width of a sequence of glyph codes.
    /// Used for line width calculations in prose hyphenation.
    ///
    /// - Parameter glyphs: Array of glyph codes
    /// - Returns: Total width in units
    public static func calculateLineWidth(_ glyphs: [UInt8]) -> Int {
        var totalWidth = 0
        for glyph in glyphs {
            totalWidth += Int(MetricsTables.width[Int(glyph)])
        }
        return totalWidth
    }
}

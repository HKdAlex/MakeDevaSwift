/// Character classification utilities for Sanskrit transliteration
///
/// This module provides helper functions for classifying characters in
/// Sanskrit transliteration, matching the behavior of helper functions
/// in `devaline.c` lines 1261-1295.

import Foundation

/// Character classification utilities
public enum CharacterClassification {
    // Constants matching C source
    private static let CODE_Nothing: UInt8 = 0xF0
    
    /// Check if character is a vowel (sonant)
    ///
    /// Matches `sonant()` in `devaline.c` line 1261-1265.
    /// Returns true for: a, A, i, I, u, U, R, Y, L, e, E, o, O
    ///
    /// - Parameter character: The character to check
    /// - Returns: True if the character is a vowel
    public static func isVowel(_ character: Character) -> Bool {
        let vowels = "aAiIuURYLeEoO"
        return vowels.contains(character)
    }
    
    /// Check if character ends a syllable
    ///
    /// Matches `endsyllable()` in `devaline.c` line 1273-1276.
    /// Returns true for: a, A, i, I, u, U, R, Y, L, e, E, o, O, H, M, w
    ///
    /// - Parameter character: The character to check
    /// - Returns: True if the character ends a syllable
    public static func endsSyllable(_ character: Character) -> Bool {
        let endingChars = "aAiIuURYLeEoOHMw"
        return endingChars.contains(character)
    }
    
    /// Check if character is a Sanskrit character (letter)
    ///
    /// Matches `sanschar()` in `devaline.c` line 1291-1295.
    /// Returns true for ASCII letters (A-Z, a-z), case-insensitive.
    ///
    /// - Parameter character: The character to check
    /// - Returns: True if the character is a Sanskrit letter
    public static func isSanskrit(_ character: Character) -> Bool {
        guard let asciiValue = character.asciiValue else { return false }
        let upper = asciiValue & 0xDF  // Convert to uppercase
        return (upper >= UInt8(ascii: "A")) && (upper <= UInt8(ascii: "Z"))
    }
    
    /// Check if string at index represents "nx" pattern to be split
    ///
    /// Matches `isnx()` in `devaline.c` line 1281-1288.
    /// Returns true if: cp[0]=='n' && cp[1]<=' ' && cp[2] is in "kKgGcCjJpPbByrvZSsh"
    ///
    /// - Parameters:
    ///   - string: The string to check
    ///   - index: The starting index in the string
    /// - Returns: True if the pattern matches "nx" to be split
    public static func isNx(_ string: String, at index: Int) -> Bool {
        let chars = Array(string)
        guard index < chars.count,
              index + 2 < chars.count else { return false }
        
        // Check: cp[0]=='n' && cp[1]<=' '
        guard chars[index] == Character("n"),
              let cp1 = chars[index + 1].asciiValue,
              cp1 <= UInt8(ascii: " ") else { return false }
        
        // Check: cp[2] is in "kKgGcCjJpPbByrvZSsh"
        let cp2 = chars[index + 2]
        let validChars = "kKgGcCjJpPbByrvZSsh"
        return validChars.contains(cp2)
    }
}

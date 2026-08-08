/// Glyph lookup functions for Devanagari font tables
///
/// This module provides functions for looking up glyph codes in font tables based on
/// transliteration strings. The implementation matches:
/// - `findcode()` in `devaline.c` lines 796-824
/// - `findcodea()` in `devaline.c` lines 759-793

import Foundation

/// Glyph lookup utilities
public enum GlyphLookup {
    /// Convert a transliteration string to UInt32 value matching C `getcode()` macro
    ///
    /// The C macro `getcode(s)` reads a char* as a uint32_t, which means it reads
    /// up to 4 bytes in little-endian order. This function replicates that behavior.
    ///
    /// - Parameter string: The transliteration string (1-4 characters)
    /// - Returns: UInt32 value representing the string, masked based on length
    private static func transliterationToUInt32(_ string: String) -> UInt32 {
        let utf8 = string.utf8.prefix(4)
        let count = utf8.count

        guard count > 0 else { return 0 }

        // Build UInt32 from bytes (little-endian, matching C behavior)
        var value: UInt32 = 0
        for (index, byte) in utf8.enumerated() {
            value |= UInt32(byte) << (index * 8)
        }

        // Apply length-based masking (matching C switch statement)
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

    /// Find glyph code for a transliteration string in a FontInfoC table
    ///
    /// This matches the behavior of `findcode()` in `devaline.c` lines 796-824.
    /// It searches through the table for a matching transliteration string.
    ///
    /// - Parameters:
    ///   - transliteration: The transliteration string to search for (1-4 characters)
    ///   - table: The font table to search (FontInfoC array)
    /// - Returns: The glyph code array if found, nil otherwise
    public static func findCode(transliteration: String, in table: [FontInfoC]) -> [UInt8]? {
        let searchValue = transliterationToUInt32(transliteration)

        for entry in table {
            let entryValue = transliterationToUInt32(entry.transliteration)
            if entryValue == searchValue {
                return entry.code
            }
        }

        return nil
    }

    /// Find glyph code for a transliteration string in a FontInfoA table with flags
    ///
    /// This matches the behavior of `findcodea()` in `devaline.c` lines 759-793.
    /// It searches through the table for a matching transliteration string, respecting
    /// the `uri` and `ya` flags.
    ///
    /// - Parameters:
    ///   - transliteration: The transliteration string to search for (1-4 characters)
    ///   - table: The font table to search (FontInfoA array)
    ///   - uri: If true, only match entries where uri flag is set
    ///   - ya: If true, only match entries where ya flag is set
    /// - Returns: The glyph code array if found, nil otherwise
    public static func findCodeA(
        transliteration: String, in table: [FontInfoA], uri: Bool, ya: Bool
    ) -> [UInt8]? {
        let searchValue = transliterationToUInt32(transliteration)

        for entry in table {
            let entryValue = transliterationToUInt32(entry.transliteration)
            if entryValue == searchValue {
                // Check flags: (!uri || fontp->uri) && (!ya || fontp->ya)
                let uriMatch = !uri || entry.uri != 0
                let yaMatch = !ya || entry.ya != 0

                if uriMatch && yaMatch {
                    return entry.code
                }
            }
        }

        return nil
    }
}

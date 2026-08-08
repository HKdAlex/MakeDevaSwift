/// BBT encoding conversion functions
///
/// Provides conversion between BBT encoding and Unicode, matching the behavior
/// of `bbt_uni2bbt()` in `bbtlib.c` line 185.

import Foundation

/// BBT encoding conversion utilities
public enum BBTEncoding {
    /// Lazy-initialized reverse lookup table for Unicode to BBT conversion
    private static let unicodeToBBT: [UInt16: UInt8] = {
        var table: [UInt16: UInt8] = [:]

        // Initialize with '?' for all values (0x0000-0x20FF)
        // In practice, we only populate the range we care about

        // Build reverse lookup from bbt_bbt2uni for range 0x80-0x9F
        for i in 0x80..<0xA0 {
            let unicode = EncodingTables.bbtToUnicode[Int(i)]
            table[unicode] = UInt8(i)
        }

        // Special case: em-dash (0x2014) maps to 197 (0xC5)
        table[0x2014] = 197

        return table
    }()

    /// Convert BBT-encoded byte to Unicode code point
    ///
    /// - Parameter byte: BBT-encoded byte value (0-255)
    /// - Returns: Unicode code point
    public static func bbtToUnicode(_ byte: UInt8) -> UInt16 {
        return EncodingTables.bbtToUnicode[Int(byte)]
    }

    /// Convert Windows-1252 encoded byte to Unicode code point
    ///
    /// - Parameter byte: Windows-1252 encoded byte value (0-255)
    /// - Returns: Unicode code point
    public static func windowsToUnicode(_ byte: UInt8) -> UInt16 {
        return EncodingTables.windowsToUnicode[Int(byte)]
    }

    /// Convert Unicode code point to BBT-encoded byte
    ///
    /// This matches the behavior of `bbt_uni2bbt()` in `bbtlib.c` line 185.
    ///
    /// - Parameter codepoint: Unicode code point
    /// - Returns: BBT-encoded byte, or `nil` if the code point cannot be represented in BBT
    public static func unicodeToBBT(_ codepoint: UInt16) -> UInt8? {
        // ASCII characters (< 128) map directly
        if codepoint < 128 {
            return UInt8(codepoint)
        }

        // Code points >= 0x2100 cannot be represented
        if codepoint >= 0x2100 {
            return nil
        }

        // Look up in reverse table
        return unicodeToBBT[codepoint]
    }
}

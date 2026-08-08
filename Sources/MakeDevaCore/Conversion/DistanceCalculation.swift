/// Distance calculation for Devanagari diacritic positioning
///
/// This module provides functions for calculating distance codes used in positioning
/// diacritics (like anusvara) relative to base characters in Devanagari text.
///
/// The implementation matches `distchar()` in `devaline.c` lines 827-841.

import Foundation

/// Distance calculation utilities
public enum DistanceCalculation {
    /// Calculate distance code for a given distance value
    ///
    /// This function matches the behavior of `distchar()` in `devaline.c` lines 827-841.
    /// It returns the appropriate distance code based on threshold values:
    /// - d > 240 → D270 (0x28)
    /// - d > 120 → D150 (0x26)
    /// - d > 90 → D120 (0x25)
    /// - d > 60 → D090 (0x24)
    /// - d > 30 → D060 (0x23)
    /// - d <= 30 → D030 (0x22)
    ///
    /// - Parameter distance: The distance value in font units
    /// - Returns: The distance code (UInt8) corresponding to the distance threshold
    public static func distanceCode(for distance: Int) -> UInt8 {
        if distance > 240 {
            return FontConstants.D270
        }
        if distance > 120 {
            return FontConstants.D150
        }
        if distance > 90 {
            return FontConstants.D120
        }
        if distance > 60 {
            return FontConstants.D090
        }
        if distance > 30 {
            return FontConstants.D060
        }
        return FontConstants.D030
    }
}

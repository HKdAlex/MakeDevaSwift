/// BBT tag types and definitions
///
/// This module defines the types and constants for BBT tag parsing,
/// matching the tag definitions from `makedeva.c` and `bbtlib.c`.

import Foundation

/// BBT tag types recognized by the parser
public enum BBTTagType: String, CaseIterable {
    case devanagari = "DEVANAGARI"
    case devProse = "DEV PROSE"
    case devUvaca = "DEV UVACA"
    case dUvaca = "d-uvaca"
    case dAnustubh = "d-anustubh"
    case dTristubh = "d-tristubh"
    case dProse = "d-prose"

    // Other tag types that may be encountered
    case text = "TEXT"
    case chapter = "CHAPTER"
    case sanskrit = "SANSKRIT"
    case prose = "PROSE"
    case special = "SPECIAL"
    case deva = "DEVA"  // @dev uvaca, @Devanagari (already Devanagari)
    case unknown = "UNKNOWN"
}

/// Result of parsing a BBT tag
public struct BBTTagResult {
    /// The tag type
    public let tagType: BBTTagType

    /// The tag name (original case)
    public let tagName: String

    /// The tag value (text after '=')
    public let value: String

    /// The position where the tag was found
    public let position: Int

    /// The position where the tag value starts (after '=' and spaces)
    public let valueStartPosition: Int

    /// Whether this is a Devanagari tag
    public let isDevanagari: Bool

    public init(
        tagType: BBTTagType,
        tagName: String,
        value: String,
        position: Int,
        valueStartPosition: Int = 0,
        isDevanagari: Bool
    ) {
        self.tagType = tagType
        self.tagName = tagName
        self.value = value
        self.position = position
        self.valueStartPosition = valueStartPosition
        self.isDevanagari = isDevanagari
    }
}

/// Devanagari tag recognition
public enum DevanagariTags {
    /// List of recognized Devanagari tags (from bbtlib.c lines 100-109)
    private static let devanagariTags: Set<String> = [
        "DEVANAGARI",
        "DEV PROSE",
        "DEV UVACA",
        "d-uvaca",
        "d-anustubh",
        "d-tristubh",
        "d-prose",
    ]

    /// Check if a tag is a Devanagari tag
    ///
    /// Matches `bbt_isdevtag()` in `bbtlib.c` lines 798-804.
    ///
    /// - Parameter tag: The tag name to check (case-insensitive)
    /// - Returns: True if the tag is a recognized Devanagari tag
    public static func isDevanagariTag(_ tag: String) -> Bool {
        let upperTag = tag.uppercased()
        return devanagariTags.contains(upperTag)
    }
}

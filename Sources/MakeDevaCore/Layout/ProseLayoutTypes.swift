/// Prose layout types and configuration
///
/// This module defines the types and configuration structures for prose layout,
/// matching the layout options from `makedeva.c`.

import Foundation

/// Prose layout mode
public enum ProseLayoutMode {
    /// No hyphenation (use tag-based prose format)
    case none

    /// Justified prose (hyphenate > 0)
    case justified

    /// Ragged prose (hyphenate < 0)
    case ragged
}

/// End codes for paragraph boundaries
/// Matching constants from `makedeva.c` lines 20-24
public enum ParagraphEndCode: UInt8 {
    case endVerseLine = 10
    case endUvaca = 12
    case endVerse = 13
    case endProseLine = 14
    case endProse = 15
}

/// Prose layout configuration options
///
/// Matches the global variables from `makedeva.c`:
/// - `hyphenate` (line 49)
/// - `pagewid` (line 50)
/// - `maxspacewid` (line 51)
/// - `maxexspacewid` (line 52)
/// - `indent` (line 53)
public struct ProseLayoutOptions {
    /// Layout mode (justified, ragged, or none)
    public let mode: ProseLayoutMode

    /// Page width in font units (default: 29000)
    public let pageWidth: Int

    /// Maximum space width for justified composition (default: 1500)
    public let maxSpaceWidth: Int

    /// Maximum excess space width for ragged composition (default: 2500)
    public let maxExcessSpaceWidth: Int

    /// Indentation of first line after text number (default: 0)
    public let indent: Int

    /// Override verse format detection (nil = auto-detect from end codes)
    /// When set, bypasses end code scanning and uses this value directly.
    /// This is needed when content has already been split by end codes.
    public let verseFormatOverride: Bool?

    public init(
        mode: ProseLayoutMode = .none,
        pageWidth: Int = 29000,
        maxSpaceWidth: Int = 1500,
        maxExcessSpaceWidth: Int = 2500,
        indent: Int = 0,
        verseFormatOverride: Bool? = nil
    ) {
        self.mode = mode
        self.pageWidth = pageWidth
        self.maxSpaceWidth = maxSpaceWidth
        self.maxExcessSpaceWidth = maxExcessSpaceWidth
        self.indent = indent
        self.verseFormatOverride = verseFormatOverride
    }
}

/// Result of prose layout operation
public struct ProseLayoutResult {
    /// Array of formatted lines, each containing glyph codes
    public let lines: [[UInt8]]

    /// Array of line types (verse/prose/uvaca)
    public let lineTypes: [LineType]

    /// Total number of paragraphs processed
    public let paragraphCount: Int

    public init(
        lines: [[UInt8]],
        lineTypes: [LineType],
        paragraphCount: Int
    ) {
        self.lines = lines
        self.lineTypes = lineTypes
        self.paragraphCount = paragraphCount
    }
}

/// Line type for output formatting
public enum LineType {
    case verse
    case prose
    case uvaca
}

/// BBT tag parser for extracting tags and Sanskrit content
///
/// This module provides BBT tag parsing functionality, matching the behavior
/// of tag parsing in `makedeva.c` lines 803-1097.

import Foundation

/// BBT tag parser
public enum BBTTagParser {
    /// Parse a BBT tag from text starting at the given index
    ///
    /// Matches tag parsing logic from `makedeva.c` lines 803-822.
    /// Looks for `@TAG = value` format.
    ///
    /// - Parameters:
    ///   - text: The input text to parse
    ///   - index: The starting index (will be updated to after the tag)
    /// - Returns: Parsed tag result, or nil if no tag found
    public static func parseTag(_ text: String, at index: inout Int) -> BBTTagResult? {
        let textArray = Array(text)
        let textLen = text.count

        // Find '@' character - line 805
        while index < textLen {
            if textArray[index] == "@" {
                break
            }
            index += 1
        }

        if index >= textLen {
            return nil
        }

        let tagStart = index
        index += 1  // Skip '@'

        // Extract tag name - lines 809-816
        var tagChars: [Character] = []
        while index < textLen {
            let char = textArray[index]
            if char == "=" || char == "\n" || char == "\0" {
                break
            }
            // Convert to uppercase (matching ToUpper in C)
            if let ascii = char.asciiValue {
                let upperAscii = ascii >= 97 && ascii <= 122 ? ascii - 32 : ascii
                if let scalar = UnicodeScalar(Int(upperAscii)) {
                    tagChars.append(Character(scalar))
                } else {
                    tagChars.append(char)
                }
            } else {
                tagChars.append(char)
            }
            index += 1
        }

        // Check for '=' - line 811
        if index >= textLen || textArray[index] != "=" {
            return nil
        }

        // Trim trailing spaces from tag - lines 814-816
        while !tagChars.isEmpty && tagChars.last == " " {
            tagChars.removeLast()
        }

        let tagName = String(tagChars)
        index += 1  // Skip '='

        // Skip spaces after '=' - lines 817-819
        while index < textLen && textArray[index] == " " {
            index += 1
        }

        // Record where the value starts (for character-by-character processing)
        let valueStartPosition = index

        // Extract tag value - everything until next '@' or end
        // Note: The C code continues until next '@' (line 81), including newlines
        // The value is NOT trimmed in C - it includes all content until next tag
        var valueChars: [Character] = []
        while index < textLen {
            let char = textArray[index]
            if char == "@" || char == "\0" {
                break
            }
            valueChars.append(char)
            index += 1
        }

        // Don't trim - the value includes all content until next tag
        // This matches C behavior where content continues on multiple lines
        let value = String(valueChars)

        // Determine tag type
        let upperTag = tagName.uppercased()
        let tagType: BBTTagType
        let isDevanagari: Bool

        // First check for "dev" prefix tags (matching makedeva.c lines 124-125)
        // These are input tags that should be ignored (mapped to .deva)
        // BUT: "DEVANAGARI" is an OUTPUT tag, not an input tag to skip
        if upperTag == "DEVANAGARI" {
            // @DEVANAGARI is an output tag, not an input tag to skip
            tagType = .devanagari
            isDevanagari = true
        } else if upperTag.hasPrefix("DEV") && upperTag.count >= 3 {
            // @dev..., @DEV UVACA, etc. - all map to .deva to be skipped
            tagType = .deva
            isDevanagari = false  // These are input tags, not Devanagari output tags
        } else if upperTag.hasPrefix("D-") {
            // @d-... tags also map to .deva
            tagType = .deva
            isDevanagari = false  // These are input tags, not Devanagari output tags
        } else {
            // Check for other tag types
            isDevanagari = DevanagariTags.isDevanagariTag(tagName)

            if isDevanagari {
                // Map to specific Devanagari tag type (for output tags)
                switch upperTag {
                case "DEVANAGARI":
                    tagType = .devanagari
                case "DEV PROSE":
                    tagType = .devProse
                case "DEV UVACA":
                    tagType = .devUvaca
                case "D-UVACA":
                    tagType = .dUvaca
                case "D-ANUSTUBH":
                    tagType = .dAnustubh
                case "D-TRISTUBH":
                    tagType = .dTristubh
                case "D-PROSE":
                    tagType = .dProse
                default:
                    tagType = .unknown
                }
            } else {
                // Map other common tags (matching makedeva.c lines 124-133)
                switch upperTag {
                case "TEXT":
                    tagType = .text
                case "CHAPTER", "CHAPTNO":
                    tagType = .chapter
                case "SPECIAL":
                    tagType = .special
                case "SANSKRIT", "SANS SMALL", "V-ANUSTUBH", "V-TRISTUBH":
                    tagType = .sanskrit
                case "SANS UVACA", "PROSE UVACA", "V-UVACA":
                    // These are uvaca tags (matching lines 126-128)
                    tagType = .sanskrit  // Treat as Sanskrit for processing
                case "PROSE", "PROSE FOR DEV":
                    tagType = .prose
                default:
                    tagType = .unknown
                }
            }
        }

        return BBTTagResult(
            tagType: tagType,
            tagName: tagName,
            value: value,
            position: tagStart,
            valueStartPosition: valueStartPosition,
            isDevanagari: isDevanagari
        )
    }

    /// Check if a tag is a Devanagari tag
    ///
    /// Convenience wrapper around DevanagariTags.isDevanagariTag()
    ///
    /// - Parameter tag: The tag name to check
    /// - Returns: True if the tag is a Devanagari tag
    public static func isDevanagariTag(_ tag: String) -> Bool {
        return DevanagariTags.isDevanagariTag(tag)
    }

    /// Extract Sanskrit content between tags
    ///
    /// Extracts content between a start tag and an optional end tag.
    /// Matches content extraction logic from `makedeva.c` lines 951-1097.
    ///
    /// - Parameters:
    ///   - text: The input text
    ///   - startTag: The start tag name (e.g., "DEVANAGARI" without @)
    ///   - endTag: Optional end tag name (nil means extract until next non-Devanagari tag or end)
    /// - Returns: Extracted Sanskrit content
    public static func extractSanskritContent(
        _ text: String,
        startTag: String,
        endTag: String? = nil
    ) -> String {
        var content: [Character] = []
        var index = 0
        var inSanskrit = false
        let textArray = Array(text)
        let textLen = text.count

        while index < textLen {
            // Look for tags
            if textArray[index] == "@" {
                var tagIndex = index
                if let tagResult = parseTag(text, at: &tagIndex) {
                    // Check if this is the start tag
                    if tagResult.tagName.uppercased()
                        == startTag.uppercased().replacingOccurrences(of: "@", with: "")
                    {
                        // Content is the tag value (everything after '=' until next '@')
                        // The tagResult.value already contains this, but we need to collect
                        // character by character to handle special codes properly
                        inSanskrit = true
                        // tagIndex points to '@' of next tag
                        // Content starts from where value extraction began (after '=' and spaces)
                        // We can calculate this: tagIndex - (length of untrimmed value)
                        // But simpler: just use the value from tagResult and return it
                        // Content is the tag value (everything after '=' until next '@')
                        // For now, use the value directly. For full special code handling,
                        // we'd need to collect character by character, but this works for basic cases
                        content.append(contentsOf: tagResult.value)
                        index = tagIndex
                        // Continue to check for end tag in the loop below
                    } else {
                        // Check if this is the end tag
                        if let end = endTag {
                            let endTagName = end.uppercased().replacingOccurrences(
                                of: "@", with: "")
                            if tagResult.tagName.uppercased() == endTagName {
                                break
                            }
                        }

                        // If we're in Sanskrit and hit another tag, check if it ends Sanskrit
                        if inSanskrit {
                            // Most non-Devanagari tags end Sanskrit content
                            if !tagResult.isDevanagari {
                                break
                            }
                        }

                        index = tagIndex
                        continue
                    }
                }
            }

            // Collect content if in Sanskrit mode (character by character)
            // Note: This is a fallback for cases where we need to collect character by character
            // For the common case, we use the tag value directly above
            if inSanskrit && index < textLen {
                // Handle special character sequences - lines 972-997
                if textArray[index] == "<" {
                    // Look for special codes like <60>, <62>, <64>, <R>, <N>, etc.
                    var codeIndex = index + 1
                    var codeChars: [Character] = []

                    while codeIndex < textLen && textArray[codeIndex] != ">" {
                        codeChars.append(textArray[codeIndex])
                        codeIndex += 1
                    }

                    if codeIndex < textLen {
                        let code = String(codeChars)

                        // Handle numeric codes like <60>, <62>, <64>
                        if let num = Int(code) {
                            if num == 60 {
                                content.append("<")
                            } else if num == 62 {
                                content.append(">")
                            } else if num == 64 {
                                content.append("@")
                            }
                        } else {
                            // Handle special codes like <R>, <N>, etc.
                            // For now, we'll skip these or handle them as needed
                        }

                        index = codeIndex + 1
                        continue
                    }
                }

                // Regular character - add to content
                content.append(textArray[index])
            }

            index += 1
        }

        return String(content)
    }
}

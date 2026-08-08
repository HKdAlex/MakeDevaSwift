/// File processing for MakeDeva CLI
///
/// This module handles file I/O and main processing loop,
/// matching the behavior from `makedeva.c` lines 154-187 and 803-1097.

import Foundation
import MakeDevaCore

/// File processor for BBT to Devanagari conversion
public enum FileProcessor {
    /// Process input file and write output file
    ///
    /// Main processing function matching `makedeva.c` main() logic.
    ///
    /// - Parameters:
    ///   - input: Input file path
    ///   - output: Output file path
    ///   - options: CLI options
    /// - Throws: File processing errors
    public static func processFile(
        input: String,
        output: String,
        options: CLIOptions
    ) throws {
        // Read input file
        let inputContent = try readInputFile(input)

        // Determine input format (Unicode or Byte)
        let inputFormat = detectInputFormat(inputContent)

        // Determine output format
        let outputFormat = options.outputFormat == .same ? inputFormat : options.outputFormat

        // Process content
        let outputContent = try processContent(
            inputContent,
            inputFormat: inputFormat,
            outputFormat: outputFormat,
            options: options
        )

        // Write output file
        try writeOutputFile(output, content: outputContent, format: outputFormat)
    }

    /// Read input file
    ///
    /// Matches `readfile()` from `makedeva.c` lines 154-187.
    ///
    /// - Parameter path: File path
    /// - Returns: File content as String
    /// - Throws: File reading errors
    private static func readInputFile(_ path: String) throws -> String {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)

        // Try UTF-8 first
        if let content = String(data: data, encoding: .utf8) {
            return content
        }

        // Check for UTF-16 BOM (0xFFFE or 0xFEFF)
        // Only try UTF-16 if there's a BOM, otherwise it will incorrectly
        // interpret Latin-1 files as UTF-16
        if data.count >= 2 {
            let bom = (UInt16(data[0]) << 8) | UInt16(data[1])
            if bom == 0xFFFE || bom == 0xFEFF {
                if let content = String(data: data, encoding: .utf16) {
                    return content
                }
            }
        }

        // Fall back to Latin-1 (byte format)
        // This is the most common format for BBT files
        return String(data: data, encoding: .isoLatin1) ?? ""
    }

    /// Detect input format (Unicode or Byte)
    ///
    /// Matches format detection from `makedeva.c` lines 167-171.
    /// The C code uses f_Encoding() to check for BOM or other encoding markers.
    /// For our purposes:
    /// - If the file was read as UTF-8 and contains characters > U+00FF, it's Unicode
    /// - Otherwise, it's byte format (8-bit Latin-1 compatible)
    ///
    /// - Parameter content: File content
    /// - Returns: Detected format
    private static func detectInputFormat(_ content: String) -> OutputFormat {
        // Check if content contains characters outside Latin-1 range (> 0xFF)
        // Characters in 0x80-0xFF are valid 8-bit bytes and should be treated as byte format
        for char in content {
            for scalar in char.unicodeScalars {
                if scalar.value > 0xFF {
                    return .unicode
                }
            }
        }
        return .byte
    }

    /// Process content through conversion pipeline
    ///
    /// Main processing loop matching `makedeva.c` lines 803-1097.
    ///
    /// - Parameters:
    ///   - content: Input content
    ///   - inputFormat: Input format
    ///   - outputFormat: Output format
    ///   - options: CLI options
    /// - Returns: Processed output content
    /// - Throws: Processing errors
    private static func processContent(
        _ content: String,
        inputFormat: OutputFormat,
        outputFormat: OutputFormat,
        options: CLIOptions
    ) throws -> String {
        var output = ""
        var index = 0
        var inSanskrit = false
        var chapterNumber = 0  // Used for chapter tracking (future use)
        var textNumber = 0  // Used for text number tracking (future use)
        var textNumber1 = 0  // Used for text number range (future use)
        var verseFormat = false
        var sanskritBuffer: [Character] = []
        var isDevaContent = false  // Track if current content is from @dev tag (already Devanagari)
        var devaTagType: String? = nil  // Track the original tag name for @dev tags (e.g., "dev uvaca", "Devanagari")
        var isUvacaTag = false  // Track if current Sanskrit section came from a uvaca tag (@sans uvaca, @prose uvaca, @v-uvaca)
        var dashFlag = false  // Track if hyphen was encountered (matching C's dash variable)
        var needsShiftIn = true  // Track if we need 0x0F at start of Sanskrit block (reset on @TEXT)
        var newlineCode: UInt8 = 0  // Pending newline code (matching C's newline variable)
        var spaceCount = 0  // Pending space count (matching C's space variable)

        let contentArray = Array(content)

        // Main processing loop (matching lines 803-1097)
        while index < contentArray.count {
            // Look for tags starting with '@'
            if contentArray[index] == "@" {
                var tagIndex = index
                if let tagResult = BBTTagParser.parseTag(content, at: &tagIndex) {
                    // NOTE: Do NOT process Sanskrit buffer here for all tags!
                    // In C code, buffer is only processed for specific tags:
                    // - tagtext: calls writedeva() if sanslen!=0
                    // - tagdeva: sets sanslen=0 (clears buffer)
                    // - default (unknown): calls writedeva() if sanslen!=0
                    // For Sanskrit tags (taguvaca, tagsanskrit, etc.), buffer keeps accumulating

                    // Handle different tag types (matching lines 862-908)
                    // C code only explicitly handles: tagchaptno, tagrhchapter, tagtext, tagdeva,
                    // taguvaca, tagsanskrit, tagprosedev, tagprose, tagpush
                    // All other tags fall through to default: which calls writedeva() if sanslen!=0
                    switch tagResult.tagType {
                    case .chapter:
                        // tagchaptno: extract chapter number (matching lines 864-870)
                        // Note: C only handles "chaptno", not generic "chapter" tags
                        if tagResult.tagName.uppercased() == "CHAPTNO" {
                            chapterNumber = Int(tagResult.value) ?? 0
                        }
                        // Other chapter tags fall through to default behavior
                        index = tagIndex
                        continue

                    case .text:
                        // Handle @TEXT tag (matching lines 872-902)
                        // If there's pending Sanskrit content, process it first (matching line 873-874)
                        if !sanskritBuffer.isEmpty {
                            let sanskritText = String(sanskritBuffer)
                            let processed = processSanskritText(
                                sanskritText,
                                verseFormat: verseFormat,
                                options: options,
                                isAlreadyDevanagari: isDevaContent,
                                devaTagName: devaTagType,
                                isUvaca: isUvacaTag,
                                textNumber: textNumber,  // Current text number for verse ending
                                addShiftIn: needsShiftIn
                            )
                            output += processed
                            sanskritBuffer.removeAll()
                            isDevaContent = false
                            devaTagType = nil
                            isUvacaTag = false
                            needsShiftIn = false  // Already output 0x0F

                            // Output @SPECIAL at end of previous text block (matching C: line 544)
                            output += "@SPECIAL = \n\n\u{0E}\n"
                        }
                        // Reset shift-in flag for new text block
                        needsShiftIn = true

                        // Extract just the number from the value (matching readnum() line 876)
                        let textNum = extractTextNumber(tagResult.value)
                        textNumber = textNum.number
                        textNumber1 = textNum.number1

                        // Write @TEXT tag to output (matching lines 879-897)
                        output += "@\(tagResult.tagName.uppercased()) = "
                        if textNumber > 0 {
                            output += "\(textNumber)"
                            if let letter = textNum.letter {
                                output.append(letter)
                            }
                            if textNumber1 > textNumber {
                                output += "-\(textNumber1)"
                                if let letter = textNum.letter {
                                    output.append(letter)
                                }
                            }
                        }
                        output += "\n\n"

                        inSanskrit = true
                        index = tagIndex
                        continue

                    case .deva:
                        // ==========================================================
                        // ⚠️  DO NOT REMOVE OR MODIFY THIS COMMENT BLOCK  ⚠️
                        // ==========================================================
                        // IMPORTANT: @dev uvaca, @Devanagari tags are IGNORED!
                        // ==========================================================
                        // These tags contain PRE-CONVERTED Devanagari glyphs.
                        // The SOURCE OF TRUTH for conversion is @sans uvaca, @sanskrit, etc.
                        // which contain TRANSLITERATED Sanskrit that we actually convert.
                        //
                        // C code behavior (lines 904-907): sanslen=0; sanskrit=TRUE; continue;
                        // - Clears the buffer
                        // - Sets sanskrit=TRUE (but this only affects SUBSEQUENT tag processing)
                        // - Does NOT enter the Sanskrit content loop (cp1 is never set)
                        // - The content after @Devanagari is SKIPPED by the main loop
                        //   because the main loop only processes '@' characters
                        // ==========================================================
                        sanskritBuffer.removeAll()
                        // NOTE: Do NOT set inSanskrit = true here!
                        // The C code sets sanskrit=TRUE but then does 'continue' which
                        // goes back to the main loop that only looks for '@' characters.
                        // The content after @Devanagari is skipped until the next valid tag.
                        //
                        // IMPORTANT: The @Devanagari content may contain '@' characters that
                        // are NOT tags (e.g., "@Aila..." which is Devanagari content starting
                        // with '@'). We need to skip ALL content until we find a VALID tag
                        // (one that has '=' after the tag name).
                        //
                        // Skip past the tag value to find the next valid tag
                        index = tagIndex
                        while index < contentArray.count {
                            if contentArray[index] == "@" {
                                // Check if this is a valid tag (has '=')
                                var checkIdx = index + 1
                                while checkIdx < contentArray.count
                                    && contentArray[checkIdx] != "="
                                    && contentArray[checkIdx] != "\n"
                                    && contentArray[checkIdx] != "\0"
                                {
                                    checkIdx += 1
                                }
                                if checkIdx < contentArray.count && contentArray[checkIdx] == "=" {
                                    // Found a valid tag, stop here
                                    break
                                }
                            }
                            index += 1
                        }
                        continue

                    case .sanskrit:
                        // Sanskrit verse format (matching lines 920-923)
                        // In C, each Sanskrit tag type (uvaca, sanskrit) sets a different end code
                        // The end code determines the output tag (@DEV UVACA vs @DEVANAGARI)

                        // Check if this is a uvaca tag (matching lines 915-917)
                        let upperTag = tagResult.tagName.uppercased()
                        let thisIsUvaca =
                            (upperTag == "SANS UVACA" || upperTag == "PROSE UVACA"
                                || upperTag == "V-UVACA")

                        // If buffer has content, check if we need to output it first
                        // This matches C behavior (lines 824-860) where:
                        // 1. Tag type changes trigger section boundaries
                        // 2. Combined texts (textno3>textno2) with consecutive @sanskrit tags
                        //    output each verse separately with its number
                        if !sanskritBuffer.isEmpty {
                            // Check if this is a combined text that needs verse numbers
                            // Combined texts have textNumber1 > textNumber (e.g., "44-45")
                            // Each @sanskrit section should output separately with its number
                            // Note: We check isUvacaTag (the buffer's type), not thisIsUvaca (incoming tag)
                            // because we're outputting the buffer content, not the incoming content
                            let isCombinedText = textNumber1 > textNumber
                            let bufferIsVerse = !isUvacaTag  // Buffer contains verse content, not uvaca
                            let shouldOutputWithNumber =
                                isCombinedText && verseFormat && bufferIsVerse

                            // Output if:
                            // 1. Tag type changes (uvaca vs non-uvaca), OR
                            // 2. This is a combined text and we have verse content to output
                            if thisIsUvaca != isUvacaTag || shouldOutputWithNumber {
                                let sanskritText = String(sanskritBuffer)
                                let processed = processSanskritText(
                                    sanskritText,
                                    verseFormat: verseFormat,
                                    options: options,
                                    isAlreadyDevanagari: isDevaContent,
                                    devaTagName: devaTagType,
                                    isUvaca: isUvacaTag,
                                    textNumber: shouldOutputWithNumber ? textNumber : 0,
                                    addShiftIn: needsShiftIn
                                )
                                output += processed
                                sanskritBuffer.removeAll()
                                needsShiftIn = false  // Already output 0x0F

                                // Increment text number for next verse in combined text
                                if shouldOutputWithNumber && textNumber < textNumber1 {
                                    textNumber += 1
                                }
                            }
                        }

                        // Set tag type for this section
                        isUvacaTag = thisIsUvaca
                        verseFormat = true
                        inSanskrit = true

                        // Set index to start of value content so the main loop
                        // processes it character by character with proper charconv
                        // and special character handling (matching C behavior)
                        index = tagResult.valueStartPosition
                        continue

                    case .prose:
                        // Prose format (matching lines 932-937)
                        verseFormat = false
                        inSanskrit = true
                        index = tagIndex
                        continue

                    default:
                        // Other tags end Sanskrit section (matching lines 942-948)
                        // If there's Sanskrit content, process it first
                        if !sanskritBuffer.isEmpty {
                            let sanskritText = String(sanskritBuffer)
                            let processed = processSanskritText(
                                sanskritText,
                                verseFormat: verseFormat,
                                options: options,
                                isAlreadyDevanagari: isDevaContent,
                                devaTagName: devaTagType,
                                isUvaca: isUvacaTag,
                                textNumber: textNumber,  // Add verse number at end
                                addShiftIn: needsShiftIn
                            )
                            output += processed
                            sanskritBuffer.removeAll()
                            isDevaContent = false
                            devaTagType = nil
                            isUvacaTag = false
                            needsShiftIn = false  // Already output 0x0F

                            // Output @SPECIAL after Sanskrit conversion (matching C: line 544)
                            output += "@SPECIAL = \n\n\u{0E}\n"
                        }
                        inSanskrit = false
                        index = tagIndex
                        continue
                    }
                } else {
                    // Failed to parse tag, skip '@'
                    index += 1
                }
            } else if inSanskrit {
                // Collect Sanskrit content character by character (matching lines 955-1097)
                let char = contentArray[index]

                // Check for end of content (matching line 958)
                if char == "\0" {
                    break
                }

                // Check for next tag (matching line 961)
                if char == "@" {
                    // Don't advance - let tag processing handle it
                    continue
                }

                // Handle Unicode to BBT conversion if needed (matching line 963-964)
                // For now, we'll use characters directly
                // TODO: Implement bbt_uni2bbt conversion if inputFormat is Unicode

                // Handle special character sequences (matching lines 972-997)
                if char == "<" {
                    // Look for special codes like <R>, <N>, <_>, <~>, <M>, <MI>, etc.
                    var codeIndex = index + 1
                    var codeChars: [Character] = []

                    while codeIndex < contentArray.count && contentArray[codeIndex] != ">" {
                        codeChars.append(contentArray[codeIndex])
                        codeIndex += 1
                    }

                    if codeIndex < contentArray.count {
                        let codeStr = String(codeChars)

                        // Handle special codes (matching lines 976-996)
                        // IMPORTANT: <R> and <~> both set newlineCode, which is flushed
                        // when the next regular character is seen. This allows <~> to
                        // OVERWRITE <R> if it comes before the next character.
                        // This is critical for triṣṭubh verses where:
                        //   half1<R>\n<~><~>half2 -> buffer has [9] not [10]
                        // vs anuṣṭubh where:
                        //   half1<~><~>half2<R>\nchar -> buffer has [9]...[10]
                        switch codeStr {
                        case "R":
                            // <R> = line break (matching line 981)
                            // In C: newline = sansverse ? CODE_EndVerseLine : CODE_EndProseLine
                            // DEFERRED: Set newlineCode, don't append directly!
                            // This allows <~> to overwrite if it comes before next char.
                            newlineCode = verseFormat ? 10 : 14  // CODE_EndVerseLine or CODE_EndProseLine
                        case "N":
                            // <N> = space in prose, conditional space in verse (matching lines 983-987)
                            if !verseFormat {
                                sanskritBuffer.append(" ")
                            } else if !dashFlag {
                                if sanskritBuffer.last != " " {
                                    sanskritBuffer.append(" ")
                                }
                            }
                        case "_", "~":
                            // <_> = Em space, <~> = En space (matching lines 989-994)
                            // In verse mode: newline = CODE_HalfLine (OVERWRITES any previous newline!)
                            // In prose mode: space++
                            if verseFormat {
                                newlineCode = dashFlag ? 11 : 9  // CODE_HalfLine or CODE_HalfLineDash
                            } else {
                                spaceCount += 1
                            }
                        case "M", "MI", "B", "BI":
                            // <M>, <MI>, <B>, <BI> = formatting codes, skip
                            break
                        default:
                            // Unknown code, skip
                            break
                        }

                        index = codeIndex + 1
                        continue
                    }
                }

                // Handle special characters (matching lines 998-1012)
                // Spaces, newlines, hyphens are handled specially
                // Check for CRLF (Swift treats \r\n as single grapheme cluster)
                let isCRLF =
                    char.unicodeScalars.count == 2 && char.unicodeScalars.first?.value == 13
                    && char.unicodeScalars.dropFirst().first?.value == 10

                // Handle whitespace (space, newline, CR, CRLF)
                if char == " " || char == "\n" || char == "\r" || isCRLF {
                    // Space handling (matching lines 998-1007)
                    // In C: space is a counter, flushed when next regular char is seen
                    // We use spaceCount for this
                    if verseFormat {
                        // In verse format: if (!dash) space=1;
                        // Only set space count if dash was not set
                        if !dashFlag {
                            spaceCount = 1  // Set to 1, not increment (matching C)
                        }
                    } else {
                        // Prose format: space++
                        spaceCount += 1
                    }
                    index += 1
                    continue
                } else if char == "-" {
                    // Hyphen handling (matching lines 1008-1010)
                    // In C: dash=TRUE; continue; - skips adding hyphen to buffer
                    // The hyphen causes the next space to be skipped (words joined)
                    dashFlag = true
                    index += 1
                    continue
                } else if char == "\u{7F}" {
                    // Micro space (matching lines 1011-1012)
                    index += 1
                    continue
                }

                // Regular character - reset dash flag
                dashFlag = false

                // Regular character - apply charconv and add to buffer (matching lines 1048-1087)
                // For already-Devanagari content, skip charconv and digraph conversion
                var convertedChar = char
                if !isDevaContent {
                    // Convert high-ASCII characters (0x80-0x9F) using charconv table
                    if let scalar = char.unicodeScalars.first {
                        let charCode = Int(scalar.value)
                        if charCode >= 0x80 && charCode < 0x80 + EncodingTables.charConv.count {
                            // Apply charconv conversion
                            let converted = EncodingTables.charConv[charCode - 0x80]
                            let newScalar = UnicodeScalar(converted)
                            convertedChar = Character(newScalar)
                        }
                    }

                    // Digraph conversion (matching lines 1067-1084)
                    // Look ahead to next character for digraph combinations
                    let nextIdx = index + 1
                    if nextIdx < contentArray.count {
                        let nextChar = contentArray[nextIdx]
                        switch nextChar {
                        case "i":
                            // ai -> E
                            if convertedChar == "a" {
                                convertedChar = "E"
                                index = nextIdx  // Skip the 'i'
                            }
                        case "u":
                            // au -> O
                            if convertedChar == "a" {
                                convertedChar = "O"
                                index = nextIdx  // Skip the 'u'
                            }
                        case "h":
                            // Aspirated consonant digraphs
                            switch convertedChar {
                            case "k":
                                convertedChar = "K"
                                index = nextIdx
                            case "g":
                                convertedChar = "G"
                                index = nextIdx
                            case "c":
                                convertedChar = "C"
                                index = nextIdx
                            case "j":
                                convertedChar = "J"
                                index = nextIdx
                            case "q":
                                convertedChar = "Q"
                                index = nextIdx  // ṭh
                            case "x":
                                convertedChar = "X"
                                index = nextIdx  // ḍh
                            case "t":
                                convertedChar = "T"
                                index = nextIdx
                            case "d":
                                convertedChar = "D"
                                index = nextIdx
                            case "p":
                                convertedChar = "P"
                                index = nextIdx
                            case "b":
                                convertedChar = "B"
                                index = nextIdx
                            default: break
                            }
                        default:
                            break
                        }
                    }
                }

                // Flush pending newline/space before adding character (matching lines 1014-1032)
                if newlineCode != 0 {
                    // Add pending newline code (matching lines 1014-1032)
                    if !verseFormat && dashFlag {
                        sanskritBuffer.append("-")
                    }
                    if newlineCode == 10 {  // CODE_EndVerseLine
                        sanskritBuffer.append(" ")
                        sanskritBuffer.append(",")
                        sanskritBuffer.append(Character(UnicodeScalar(newlineCode)))
                    } else if newlineCode == 9 || newlineCode == 11 {
                        // CODE_HalfLine (9) or CODE_HalfLineDash (11)
                        // Add the code directly to buffer - LineConversion will decide
                        // whether to convert to space (syln < 19) or keep as-is (syln >= 19)
                        sanskritBuffer.append(Character(UnicodeScalar(newlineCode)))
                    } else {
                        sanskritBuffer.append(Character(UnicodeScalar(newlineCode)))
                    }
                    newlineCode = 0
                    spaceCount = 0
                } else {
                    // Add pending spaces
                    if !verseFormat && dashFlag {
                        sanskritBuffer.append(Character(UnicodeScalar(FontConstants.CODE_Nothing)))
                    }
                    for _ in 0..<spaceCount {
                        sanskritBuffer.append(" ")
                    }
                    spaceCount = 0
                }

                // Handle V (l candra bindu) - matching C lines 1059-1063
                // V (0x8F after charconv) becomes 'w' (anunasika) + 'l'
                if convertedChar == "V" {
                    sanskritBuffer.append("w")  // anunasika
                    convertedChar = "l"
                }

                sanskritBuffer.append(convertedChar)
                index += 1
            } else {
                // Not in Sanskrit mode, skip character
                index += 1
            }
        }

        // Flush any pending newlineCode before processing remaining Sanskrit
        if newlineCode != 0 {
            if newlineCode == 10 {  // CODE_EndVerseLine
                sanskritBuffer.append(" ")
                sanskritBuffer.append(",")
                sanskritBuffer.append(Character(UnicodeScalar(newlineCode)))
            } else {
                sanskritBuffer.append(Character(UnicodeScalar(newlineCode)))
            }
            newlineCode = 0
        }

        // Process any remaining Sanskrit
        if !sanskritBuffer.isEmpty {
            let sanskritText = String(sanskritBuffer)
            let processed = processSanskritText(
                sanskritText,
                verseFormat: verseFormat,
                options: options,
                isAlreadyDevanagari: isDevaContent,
                devaTagName: devaTagType,
                isUvaca: isUvacaTag,
                textNumber: textNumber,  // Add verse number at end
                addShiftIn: needsShiftIn
            )
            output += processed
        }

        return output
    }

    /// Process Sanskrit text through conversion pipeline
    ///
    /// Converts Sanskrit transliteration to Devanagari glyphs and applies layout.
    /// If the text is already Devanagari (from @dev uvaca or @Devanagari tags),
    /// it outputs directly without conversion.
    ///
    /// - Parameters:
    ///   - sanskrit: Sanskrit transliteration text (or already Devanagari)
    ///   - verseFormat: Whether text is in verse format
    ///   - options: CLI options
    ///   - isAlreadyDevanagari: If true, text is already Devanagari and should be output directly
    ///   - devaTagName: Original tag name for @dev tags (e.g., "dev uvaca", "Devanagari")
    ///   - textNumber: Text number to append at end of verse (for //N// format)
    /// - Returns: Processed output with @DEVANAGARI tags
    private static func processSanskritText(
        _ sanskrit: String,
        verseFormat: Bool,
        options: CLIOptions,
        isAlreadyDevanagari: Bool = false,
        devaTagName: String? = nil,
        isUvaca: Bool = false,
        textNumber: Int = 0,
        addShiftIn: Bool = true  // Whether to add 0x0F at start (first output in text block)
    ) -> String {
        // If already Devanagari, output directly without conversion
        // This matches C behavior: @dev uvaca and @Devanagari tags contain
        // already-converted Devanagari glyph codes that should be output as-is
        // The C code collects this content and processes it through writedeva()
        // which outputs it with the appropriate tag based on end codes in the buffer
        if isAlreadyDevanagari {
            // For already-Devangari content, we need to:
            // 1. Convert string to glyph codes (UInt8 array)
            // 2. Process through layout (matching writedeva() structure)
            // 3. Output with appropriate tag based on verseFormat

            // Create layout options (needed for layoutProse call)
            let layoutMode: ProseLayoutMode
            if let hyphenate = options.hyphenate {
                layoutMode = hyphenate ? .justified : .ragged
            } else {
                layoutMode = .none
            }

            let layoutOptions = ProseLayoutOptions(
                mode: layoutMode,
                pageWidth: options.pageWidth,
                maxSpaceWidth: options.maxSpaceWidth,
                maxExcessSpaceWidth: options.maxExcessSpaceWidth,
                indent: options.indent,
                verseFormatOverride: verseFormat  // Pass verseFormat for already-Devanagari content
            )

            // Process through layout to get lines (matching writedeva() structure)
            // The layout will handle line breaking, but content is already Devanagari
            let layoutResult = ProseLayout.layoutProse(sanskrit, options: layoutOptions)

            // Format output with appropriate tag based on verseFormat
            // Matching C's writedeva() output logic (lines 263-288)
            var output = ""
            for (lineIndex, line) in layoutResult.lines.enumerated() {
                if line.isEmpty {
                    continue
                }

                // Use devaTagName to determine output tag (matching C behavior)
                // The C code converts tag names to uppercase for output
                // @dev uvaca -> @DEV UVACA, @Devanagari -> @DEVANAGARI
                if let tagName = devaTagName {
                    let tagNameUpper = tagName.uppercased()
                    if tagNameUpper.contains("UVACA") {
                        output += "@DEV UVACA = <qc>"
                    } else {
                        output += "@DEVANAGARI = "
                    }
                } else if verseFormat {
                    // Fallback: use verseFormat if tag name not available
                    output += "@DEV UVACA = <qc>"
                } else {
                    output += "@DEVANAGARI = "
                }

                // Output glyphs directly (already Devanagari, no conversion needed)
                // Matching C's output format (lines 489-523)
                let CODE_HalfLine: UInt8 = 9
                let CODE_HalfLineDash: UInt8 = 11
                let CODE_EmDash: UInt8 = 0x97

                var newline = true
                for glyph in line {
                    switch glyph {
                    case CODE_HalfLine:
                        output += "<R>\n<_><_>"
                        newline = true
                    case CODE_HalfLineDash:
                        output += "<R>\n<_><_>-"
                        newline = true
                    case CODE_EmDash:
                        if let scalar = UnicodeScalar(0x2014) {
                            output.append(Character(scalar))
                        } else if let scalar = UnicodeScalar(0x97) {
                            output.append(Character(scalar))
                        }
                        newline = false
                    case 60, 62, 64:  // '<', '>', '@' in ASCII
                        output += String(format: "<%d>", glyph)
                        newline = false
                    case UInt8(ascii: " "):
                        if newline {
                            output += "<~>"
                        } else {
                            output += " "
                        }
                        newline = false
                    default:
                        if let scalar = UnicodeScalar(Int(glyph)) {
                            output.append(Character(scalar))
                            newline = false
                        }
                    }
                }
                output += "\n"
            }
            return output
        }
        // Split Sanskrit on line break markers (CODE_EndVerseLine = 10)
        // Each segment will be processed and output separately
        let lineBreakChar = Character(UnicodeScalar(10)!)
        let segments = sanskrit.split(separator: lineBreakChar, omittingEmptySubsequences: false)

        // Create prose layout options
        let layoutMode: ProseLayoutMode
        if let hyphenate = options.hyphenate {
            layoutMode = hyphenate ? .justified : .ragged
        } else {
            layoutMode = .none
        }

        let layoutOptions = ProseLayoutOptions(
            mode: layoutMode,
            pageWidth: options.pageWidth,
            maxSpaceWidth: options.maxSpaceWidth,
            maxExcessSpaceWidth: options.maxExcessSpaceWidth,
            indent: options.indent,
            verseFormatOverride: verseFormat  // Pass verseFormat since we've already split by end codes
        )

        // Format output with @DEVANAGARI tags (matching C lines 270-278, 486-510)
        // In C, the buffer is split by end codes and each section is output
        // The first line of each section gets a tag, continuation lines don't
        // Start with 0x0F (Shift In) control character (matching C line 237) if this is first output
        var output = addShiftIn ? "\u{0F}" : ""
        var needsTag = true  // First line needs a tag
        var isUvacaLocal = isUvaca  // Make mutable copy

        for (segmentIndex, segment) in segments.enumerated() {
            let segmentStr = String(segment).trimmingCharacters(in: .whitespaces)
            if segmentStr.isEmpty {
                continue
            }

            // Apply layout to this segment
            let layoutResult = ProseLayout.layoutProse(segmentStr, options: layoutOptions)

            for (lineIndex, line) in layoutResult.lines.enumerated() {
                // Skip empty lines
                if line.isEmpty {
                    continue
                }

                // Write tag only if this is the first line of a new section
                var wasUvaca = false
                if needsTag {
                    // If this Sanskrit came from a uvaca tag, use @DEV UVACA (matching line 284)
                    if isUvacaLocal {
                        output += "@DEV UVACA = <qc>"
                        wasUvaca = true
                        // After uvaca, subsequent content uses @DEVANAGARI
                        isUvacaLocal = false
                    } else {
                        output += "@DEVANAGARI = "
                    }
                    needsTag = false
                }

                // Convert glyphs to output format (matching lines 489-510)
                // In shell format, special codes need special handling
                let CODE_HalfLine: UInt8 = 9
                let CODE_HalfLineDash: UInt8 = 11
                let CODE_EmDash: UInt8 = 0x97

                var newline = true  // Track if we're at start of line
                for glyph in line {
                    switch glyph {
                    case CODE_HalfLine:
                        // Half line break (matching lines 494-501)
                        output += "<R>\n<_><_>"
                        newline = true
                    case CODE_HalfLineDash:
                        // Half line with dash
                        output += "<R>\n<_><_>-"
                        newline = true
                    case CODE_EmDash:
                        // Em dash
                        if let scalar = UnicodeScalar(0x2014) {
                            output.append(Character(scalar))
                        } else if let scalar = UnicodeScalar(0x97) {
                            output.append(Character(scalar))
                        }
                        newline = false
                    case 60, 62, 64:  // '<', '>', '@' in ASCII
                        // Escape special characters (matching lines 503-508)
                        output += String(format: "<%d>", glyph)
                        newline = false
                    case UInt8(ascii: " "):
                        // Space handling (matching lines 509-515)
                        if newline {
                            output += "<~>"  // En space at start of line
                        } else {
                            output += " "
                        }
                        newline = false
                    default:
                        // Regular glyph - write as character
                        if let scalar = UnicodeScalar(Int(glyph)) {
                            output.append(Character(scalar))
                            newline = false
                        }
                    }
                }

                // Add <R> and newline if this is not the last segment (more content follows)
                // The / before <R> comes from the comma in the content being converted to /
                if segmentIndex < segments.count - 1 {
                    output += "<R>\n"
                } else {
                    // Last segment - add verse number if applicable (matching C's puttextno())
                    // Format: //N// where N is the text number (no comma - comes from content)
                    // For single-digit numbers (1-9), wrap in 0x7F (matching C lines 575, 585)
                    if textNumber > 0 && !isUvacaLocal && !wasUvaca {
                        if textNumber <= 9 {
                            output += " //\u{7F}\(textNumber)\u{7F}//"
                        } else if textNumber <= 99 {
                            output += " //\(textNumber)//"
                        } else {
                            output += " //\(textNumber)//"
                        }
                    }
                    // End of verse/uvaca: output \n\n (matching C's default case at line 535-537)
                    // C outputs "\n\n" for CODE_EndVerse, CODE_EndUvaca, CODE_EndProse, etc.
                    output += "\n\n"
                    needsTag = true
                }
            }
        }

        return output
    }

    /// Write output file
    ///
    /// - Parameters:
    ///   - path: Output file path
    ///   - content: Content to write
    ///   - format: Output format
    /// - Throws: File writing errors
    private static func writeOutputFile(
        _ path: String,
        content: String,
        format: OutputFormat
    ) throws {
        let url = URL(fileURLWithPath: path)

        switch format {
        case .unicode:
            // For Unicode format, write as UTF-8
            try content.write(to: url, atomically: true, encoding: .utf8)
        case .byte, .same:
            // For byte format, write raw bytes (each Unicode scalar as a single byte)
            // This matches the C output which writes raw 8-bit values
            var bytes: [UInt8] = []
            for scalar in content.unicodeScalars {
                // Truncate to 8 bits - this handles high-byte glyphs correctly
                bytes.append(UInt8(truncatingIfNeeded: scalar.value))
            }
            let data = Data(bytes)
            try data.write(to: url)
        }
    }

    /// Extract text number from tag value (matching readnum() from makedeva.c lines 602-624)
    ///
    /// Extracts the number from strings like "<B>1 TEKSTAS<M>" -> 1
    ///
    /// - Parameter value: Tag value string
    /// - Returns: Extracted number, number1, and optional letter
    private static func extractTextNumber(_ value: String) -> (
        number: Int, number1: Int, letter: Character?
    ) {
        var number = 0
        var number1 = 0
        var letter: Character? = nil

        // Find first digit (matching line 610)
        let chars = Array(value)
        var i = 0
        while i < chars.count && (chars[i] == "\n" || (chars[i] < "0" || chars[i] > "9")) {
            i += 1
        }

        if i < chars.count {
            // Extract number (matching lines 612-618)
            let numStart = i
            var numEnd = i
            while numEnd < chars.count {
                let c = chars[numEnd]
                if c == "\n" {
                    break
                }
                if c == "." && numEnd + 1 < chars.count && chars[numEnd + 1] >= "0"
                    && chars[numEnd + 1] <= "9"
                {
                    numEnd += 1
                    continue
                }
                if c >= "0" && c <= "9" {
                    numEnd += 1
                    continue
                }
                break
            }

            // Find actual start of number (matching line 617)
            var numStart2 = numEnd
            while numStart2 > numStart && numStart2 > 0 && chars[numStart2 - 1] >= "0"
                && chars[numStart2 - 1] <= "9"
            {
                numStart2 -= 1
            }

            // Extract number string
            if numStart2 < numEnd {
                let numStr = String(chars[numStart2..<numEnd])
                number = Int(numStr.replacingOccurrences(of: ".", with: "")) ?? 0
            }

            // Check for letter (matching line 620)
            // C's IsAlpha only returns true for ASCII letters (a-z, A-Z)
            // Swift's isLetter returns true for Unicode letters like Ä (0xC4)
            // We need to match C's behavior
            if numEnd < chars.count {
                let c = chars[numEnd]
                if let scalar = c.unicodeScalars.first,
                    (scalar.value >= 0x41 && scalar.value <= 0x5A)
                        || (scalar.value >= 0x61 && scalar.value <= 0x7A)
                {
                    letter = c
                    numEnd += 1
                }
            }

            // Try to extract number1 (matching line 886)
            if numEnd < chars.count {
                var num1Start = numEnd
                while num1Start < chars.count
                    && (chars[num1Start] == "\n"
                        || (chars[num1Start] < "0" || chars[num1Start] > "9"))
                {
                    num1Start += 1
                }
                if num1Start < chars.count {
                    var num1End = num1Start
                    while num1End < chars.count && chars[num1End] >= "0" && chars[num1End] <= "9" {
                        num1End += 1
                    }
                    if num1Start < num1End {
                        let num1Str = String(chars[num1Start..<num1End])
                        number1 = Int(num1Str) ?? 0
                    }
                }
            }
        }

        if number1 < number {
            number1 = number
        }

        return (number, number1, letter)
    }
}

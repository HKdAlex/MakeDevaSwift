/// Command-line options for MakeDeva CLI
///
/// This module parses command-line arguments matching the behavior
/// of option parsing in `makedeva.c` lines 688-784.

import Foundation

/// Output format options
public enum OutputFormat {
    case same  // Use same format as input
    case unicode
    case byte
}

/// CLI options structure
///
/// Matches the global variables and options from `makedeva.c`:
/// - `pagewid` (line 50)
/// - `maxspacewid` (line 51)
/// - `maxexspacewid` (line 52)
/// - `indent` (line 53)
/// - `hyphenate` (line 49)
/// - `newformat` (line 56)
/// - `oformat` (line 55)
public struct CLIOptions {
    /// Page width for prose (default: 29000)
    public var pageWidth: Int = 29000
    
    /// Maximum space width for justified composition (default: 1500)
    public var maxSpaceWidth: Int = 1500
    
    /// Maximum excess space width for ragged composition (default: 2500)
    public var maxExcessSpaceWidth: Int = 2500
    
    /// Indentation of first line (default: 0)
    public var indent: Int = 0
    
    /// Hyphenation mode: nil = none, true = justified, false = ragged
    public var hyphenate: Bool? = nil
    
    /// New format option (default: false)
    public var newFormat: Bool = false
    
    /// Output format (default: .same)
    public var outputFormat: OutputFormat = .same
    
    /// Sannyasa option (default: false)
    public var sannyasa: Bool = false
    
    /// Split nx option (default: false)
    public var splitNx: Bool = false
    
    /// Input file path
    public var inputFile: String?
    
    /// Output file path
    public var outputFile: String?
    
    public init() {}
}

/// CLI option parser
public enum CLIOptionParser {
    /// Parse command-line arguments
    ///
    /// Matches argument parsing from `makedeva.c` lines 688-784.
    ///
    /// - Parameter arguments: Command-line arguments (excluding program name)
    /// - Returns: Parsed options, or nil if parsing failed
    public static func parse(_ arguments: [String]) -> CLIOptions? {
        var options = CLIOptions()
        var num = 0  // Number of non-option arguments (file names)
        
        var i = 0
        while i < arguments.count {
            let arg = arguments[i]
            
            if arg.hasPrefix("-") {
                let c = arg.dropFirst(1).first
                guard let char = c else {
                    i += 1
                    continue
                }
                
                switch char {
                case "l", "j", "r", "i":
                    // Options with numeric values
                    var val: Int = -1
                    var valueArg: String
                    
                    // Check if value is in next argument or after option
                    if arg.count == 2 && i + 1 < arguments.count && isDigit(arguments[i + 1].first) {
                        i += 1
                        valueArg = arguments[i]
                    } else if arg.count > 2 {
                        valueArg = String(arg.dropFirst(2))
                    } else {
                        valueArg = ""
                    }
                    
                    if !valueArg.isEmpty && isDigit(valueArg.first) {
                        // Parse integer with optional decimal part (3 decimal places)
                        // Format: integer or integer.decimal (up to 3 decimal places)
                        // Example: "12" -> 12, "12.345" -> 12345
                        val = parseDecimalValue(valueArg)
                    }
                    
                    switch char {
                    case "l":
                        if val > 0 {
                            options.pageWidth = val
                        }
                    case "j":
                        if val >= 0 {
                            options.maxSpaceWidth = val
                        }
                        options.hyphenate = true  // Justified
                    case "r":
                        if val >= 0 {
                            options.maxExcessSpaceWidth = val
                        }
                        options.hyphenate = false  // Ragged
                    case "i":
                        if val >= 0 {
                            options.indent = val
                        }
                    default:
                        break
                    }
                    
                case "m":
                    // Sannyasa option
                    options.sannyasa = true
                case "n":
                    // Split nx option
                    options.splitNx = true
                case "f":
                    // New format option
                    options.newFormat = true
                case "u":
                    // Unicode output format
                    options.outputFormat = .unicode
                case "b":
                    // Byte output format
                    options.outputFormat = .byte
                default:
                    // Unknown option, ignore
                    break
                }
            } else {
                // Non-option argument (file name)
                switch num {
                case 0:
                    options.inputFile = arg
                case 1:
                    options.outputFile = arg
                default:
                    // Too many arguments
                    return nil
                }
                num += 1
            }
            
            i += 1
        }
        
        // Require exactly 2 file arguments
        if num != 2 {
            return nil
        }
        
        return options
    }
    
    /// Check if character is a digit
    private static func isDigit(_ char: Character?) -> Bool {
        guard let char = char, let ascii = char.asciiValue else { return false }
        return ascii >= UInt8(ascii: "0") && ascii <= UInt8(ascii: "9")
    }
    
    /// Parse decimal value with 3 decimal places
    ///
    /// Matches the decimal parsing logic from `makedeva.c` lines 712-723.
    /// The C code uses strtoul to parse integer, then if there's a '.',
    /// it multiplies by 10 for each of 3 decimal places:
    /// - "12" -> 12 (no decimal point, strtoul returns 12)
    /// - "12.3" -> 123 (12 * 10 + 3)
    /// - "12.345" -> 12345 (12 * 1000 + 345)
    ///
    /// - Parameter value: String value to parse
    /// - Returns: Integer value with 3 decimal places (e.g., "12.345" -> 12345)
    private static func parseDecimalValue(_ value: String) -> Int {
        var val: Int = 0
        var chars = value.makeIterator()
        var char = chars.next()
        
        // Parse integer part (matching strtoul)
        while let c = char, isDigit(c) {
            val = val * 10 + Int(c.asciiValue! - UInt8(ascii: "0"))
            char = chars.next()
        }
        
        // Check if there's a decimal point (matching line 713)
        if char == "." {
            char = chars.next()  // Skip '.'
            
            // Parse up to 3 decimal places (matching lines 715-723)
            for _ in 0..<3 {
                val *= 10  // Multiply first (matching line 717)
                if let c = char, isDigit(c) {
                    val += Int(c.asciiValue! - UInt8(ascii: "0"))  // Add digit (matching line 720)
                    char = chars.next()
                }
                // If no digit, val is already multiplied by 10 (padding with zero)
            }
        }
        // If no decimal point, return integer value as-is
        
        return val
    }
}

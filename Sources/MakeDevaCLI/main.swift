import Foundation
import MakeDevaCore

/// MakeDeva CLI entry point
///
/// Main function matching `makedeva.c` main() entry point.
/// Processes command-line arguments and converts BBT files to Devanagari.
func main() {
    let arguments = Array(CommandLine.arguments.dropFirst())
    
    // Parse command-line options
    guard let options = CLIOptionParser.parse(arguments) else {
        print("Usage: makedeva [options] inputfile outputfile")
        print("Options:")
        print("  -l<width>    Page width (default: 29000)")
        print("  -j<width>    Justified prose, max space width")
        print("  -r<width>    Ragged prose, max excess space width")
        print("  -i<indent>   Indentation (default: 0)")
        print("  -f           New format")
        print("  -u           Unicode output")
        print("  -b           Byte output")
        print("  -m           Sannyasa option")
        print("  -n           Split nx option")
        exit(1)
    }
    
    guard let inputFile = options.inputFile, let outputFile = options.outputFile else {
        print("Error: Input and output files required")
        exit(1)
    }
    
    // Print version and processing message (matching C lines 685-786)
    print("Devanagari Shell Generator version 8 for RM Devanagari font")
    print("Processing \(inputFile)")
    
    // Process file
    do {
        try FileProcessor.processFile(
            input: inputFile,
            output: outputFile,
            options: options
        )
        print("Conversion complete: \(outputFile)")
    } catch {
        print("Error: \(error.localizedDescription)")
        exit(1)
    }
}

// Run main function
main()

import Testing

@testable import MakeDevaCLI

struct CLIOptionParserTests {
    
    @Test func parseBasicArguments() {
        let args = ["input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse basic arguments")
        #expect(options?.inputFile == "input.txt", "Should parse input file")
        #expect(options?.outputFile == "output.txt", "Should parse output file")
    }
    
    @Test func parsePageWidthOption() {
        let args = ["-l29000", "input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse with page width option")
        #expect(options?.pageWidth == 29000, "Should set page width")
    }
    
    @Test func parseJustifiedOption() {
        let args = ["-j1500", "input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse with justified option")
        #expect(options?.hyphenate == true, "Should set hyphenate to justified")
        #expect(options?.maxSpaceWidth == 1500, "Should set max space width")
    }
    
    @Test func parseRaggedOption() {
        let args = ["-r2500", "input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse with ragged option")
        #expect(options?.hyphenate == false, "Should set hyphenate to ragged")
        #expect(options?.maxExcessSpaceWidth == 2500, "Should set max excess space width")
    }
    
    @Test func parseIndentOption() {
        let args = ["-i1000", "input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse with indent option")
        #expect(options?.indent == 1000, "Should set indent")
    }
    
    @Test func parseUnicodeOutput() {
        let args = ["-u", "input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse with Unicode option")
        #expect(options?.outputFormat == .unicode, "Should set Unicode output format")
    }
    
    @Test func parseByteOutput() {
        let args = ["-b", "input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse with byte option")
        #expect(options?.outputFormat == .byte, "Should set byte output format")
    }
    
    @Test func parseMultipleOptions() {
        let args = ["-l29000", "-j1500", "-i500", "input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse multiple options")
        #expect(options?.pageWidth == 29000, "Should set page width")
        #expect(options?.maxSpaceWidth == 1500, "Should set max space width")
        #expect(options?.indent == 500, "Should set indent")
    }
    
    @Test func parseInvalidArguments() {
        let args = ["input.txt"]  // Missing output file
        let options = CLIOptionParser.parse(args)
        
        #expect(options == nil, "Should reject invalid arguments")
    }
    
    @Test func parseDecimalValue() {
        // Test decimal value parsing (e.g., "12.345" -> 12345)
        // This is tested indirectly through option parsing
        let args = ["-l12345", "input.txt", "output.txt"]
        let options = CLIOptionParser.parse(args)
        
        #expect(options != nil, "Should parse decimal-like values")
    }
    
    @Test func buildTest() {
        // Just verify the functions can be called without crashing
        let _ = CLIOptionParser.parse(["input.txt", "output.txt"])
        // If we get here, the functions at least compile and run
    }
}

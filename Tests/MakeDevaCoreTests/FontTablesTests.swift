import Testing

@testable import MakeDevaCore

struct FontTablesTests {

    // MARK: - Table Size Tests

    @Test func fontuCount() {
        #expect(FontTables.fontu.count == 31)
    }

    @Test func fontuuCount() {
        #expect(FontTables.fontuu.count == 27)
    }

    @Test func fontRCount() {
        #expect(FontTables.fontR.count == 18)
    }

    @Test func fontYCount() {
        #expect(FontTables.fontY.count == 4)
    }

    @Test func fontLCount() {
        #expect(FontTables.fontL.count == 2)
    }

    @Test func fontvCount() {
        #expect(FontTables.fontv.count == 8)
    }

    @Test func fontaCount() {
        #expect(FontTables.fonta.count == 151, "fonta should have 151 entries (matching C source)")
    }

    @Test func fontcCount() {
        // Note: 70 entries = 69 from C source + 1 for '{' pass-through character
        #expect(FontTables.fontc.count == 70, "fontc should have 70 entries (69 from C + 1 for '{')")
    }

    // MARK: - Sample Value Tests

    @Test func fontuFirstEntry() {
        let first = FontTables.fontu[0]
        #expect(first.transliteration == "F")
        #expect(first.code == [0x78, 0x5D, 0x20, FontConstants.F___])
    }

    @Test func fontuuFirstEntry() {
        let first = FontTables.fontuu[0]
        #expect(first.transliteration == "F")
        #expect(first.code == [0x78, 0x5E, 0x20, FontConstants.F___])
    }

    @Test func fontRFirstEntry() {
        let first = FontTables.fontR[0]
        #expect(first.transliteration == "F")
        #expect(first.code == [0x78, 0x2B, 0x20, FontConstants.F___])
    }

    @Test func fontYFirstEntry() {
        let first = FontTables.fontY[0]
        #expect(first.transliteration == "d")
        #expect(first.code == [FontConstants.d___, 0x7C, 0x20, FontConstants.D030])
    }

    @Test func fontLFirstEntry() {
        let first = FontTables.fontL[0]
        #expect(first.transliteration == "d")
        #expect(first.code == [FontConstants.d___, 0x7D, 0x20, FontConstants.D030])
    }

    @Test func fontvFirstEntry() {
        let first = FontTables.fontv[0]
        #expect(first.transliteration == "F")
        #expect(first.code == [0x78, 0x2E, 0x20, FontConstants.F___])
    }

    @Test func fontaFirstEntry() {
        let first = FontTables.fonta[0]
        #expect(first.transliteration == "k")
        #expect(first.code == [0x6B, 0x20, FontConstants.D270])
        #expect(first.uri == 1)
        #expect(first.ya == 0)
    }

    @Test func fontcFirstEntry() {
        let first = FontTables.fontc[0]
        #expect(first.transliteration == "k")
        #expect(first.code == [0x66])
    }

    // MARK: - Additional Sample Tests

    @Test func fontaSampleEntries() {
        // Test a few more entries from fonta to verify structure
        let kEntry = FontTables.fonta[0]
        #expect(kEntry.transliteration == "k")
        #expect(kEntry.uri == 1)
        #expect(kEntry.ya == 0)

        let fEntry = FontTables.fonta[15]
        #expect(fEntry.transliteration == "F")
        #expect(fEntry.uri == 1)
        #expect(fEntry.ya == 1)

        // Find dm entry by searching (index may vary)
        let dmEntry = FontTables.fonta.first { $0.transliteration == "dm" }
        #expect(dmEntry != nil, "Should find 'dm' entry in fonta")
        #expect(dmEntry?.code == [FontConstants.dma_])
        #expect(dmEntry?.uri == 1)
        #expect(dmEntry?.ya == 1)
    }

    @Test func fontcSampleEntries() {
        // Test a few more entries from fontc
        let kSEntry = FontTables.fontc[1]
        #expect(kSEntry.transliteration == "kS")
        #expect(kSEntry.code == [FontConstants.kS__])

        let fEntry = FontTables.fontc[9]
        #expect(fEntry.transliteration == "F")
        #expect(fEntry.code == [0x78, 0x20, 0x2E, FontConstants.F___])
    }
}

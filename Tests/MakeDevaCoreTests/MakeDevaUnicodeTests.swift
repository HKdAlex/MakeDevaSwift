import Testing
@testable import MakeDevaCore

struct MakeDevaUnicodeTests {
    @Test("Unicode path applies shared sandhi before transliteration")
    func sandhiPrePass() {
        #expect(MakeDevaUnicode.prepareIAST("k g") == "kg")
        #expect(MakeDevaUnicode.convertLine("k a") == "ka")
    }

    @Test("prepareIAST matches IndicSandhi devanagari rules")
    func prepareMatchesPackage() {
        let input = "n m k a"
        #expect(MakeDevaUnicode.prepareIAST(input) == "nm ka")
    }
}

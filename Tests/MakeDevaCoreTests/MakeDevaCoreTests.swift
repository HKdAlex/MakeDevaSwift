import Testing

@testable import MakeDevaCore

struct MakeDevaCoreTests {
    @Test func placeholder() {
        let core = MakeDevaCore()
        #expect(core != nil)
    }
}

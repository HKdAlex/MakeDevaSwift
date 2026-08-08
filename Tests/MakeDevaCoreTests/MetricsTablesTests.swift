import Testing

@testable import MakeDevaCore

struct MetricsTablesTests {

    // MARK: - Array Size Tests

    @Test func widthSize() {
        #expect(MetricsTables.width.count == 256)
    }

    @Test func metricsAboveLeftSize() {
        #expect(MetricsTables.metricsAboveLeft.count == 256)
    }

    @Test func metricsAboveRightSize() {
        #expect(MetricsTables.metricsAboveRight.count == 256)
    }

    @Test func metricsBelowLeftSize() {
        #expect(MetricsTables.metricsBelowLeft.count == 256)
    }

    @Test func metricsBelowRightSize() {
        #expect(MetricsTables.metricsBelowRight.count == 256)
    }

    // MARK: - Sample Value Tests

    @Test func widthSampleValues() {
        // Test first few values (all zeros for indices 0-31)
        #expect(MetricsTables.width[0] == 0)
        #expect(MetricsTables.width[1] == 0)
        #expect(MetricsTables.width[15] == 0)
        #expect(MetricsTables.width[31] == 0)

        // Test some non-zero values from C source
        #expect(MetricsTables.width[0x20] == 500)  // space
        #expect(MetricsTables.width[0x21] == 382)
        #expect(MetricsTables.width[0x22] == 30)  // D030
        #expect(MetricsTables.width[0x23] == 60)  // D060
        #expect(MetricsTables.width[0x24] == 90)  // D090
        #expect(MetricsTables.width[0x25] == 120)  // D120
        #expect(MetricsTables.width[0x26] == 150)  // D150
        #expect(MetricsTables.width[0x28] == 270)  // D270
    }

    @Test func metricsAboveLeftSampleValues() {
        // Most values are 0, test non-zero ones
        #expect(MetricsTables.metricsAboveLeft[0x2A] == -370)  // index 42
        #expect(MetricsTables.metricsAboveLeft[0x3C] == -330)  // index 60
        #expect(MetricsTables.metricsAboveLeft[0x3D] == -250)  // index 61
        #expect(MetricsTables.metricsAboveLeft[0x3E] == -250)  // index 62
        #expect(MetricsTables.metricsAboveLeft[0x45] == -670)  // index 69
        #expect(MetricsTables.metricsAboveLeft[0x49] == -220)  // index 73
        #expect(MetricsTables.metricsAboveLeft[0x4C] == -439)  // index 76
        #expect(MetricsTables.metricsAboveLeft[0x4D] == -261)  // index 77
        #expect(MetricsTables.metricsAboveLeft[0x52] == -330)  // index 82
        #expect(MetricsTables.metricsAboveLeft[0x65] == -610)  // index 101 (row 6, 6th value)
        #expect(MetricsTables.metricsAboveLeft[0x69] == 100)  // index 105
    }

    @Test func metricsAboveRightSampleValues() {
        // Most values are 0, test non-zero ones
        #expect(MetricsTables.metricsAboveRight[0x2A] == 150)  // index 42
        #expect(MetricsTables.metricsAboveRight[0x3C] == 17)  // index 60
        #expect(MetricsTables.metricsAboveRight[0x3D] == 87)  // index 61
        #expect(MetricsTables.metricsAboveRight[0x3E] == 87)  // index 62
        #expect(MetricsTables.metricsAboveRight[0x45] == -210)  // index 69
        #expect(MetricsTables.metricsAboveRight[0x49] == 110)  // index 73
        #expect(MetricsTables.metricsAboveRight[0x4C] == 10)  // index 76
        #expect(MetricsTables.metricsAboveRight[0x4D] == -59)  // index 77
        #expect(MetricsTables.metricsAboveRight[0x52] == 17)  // index 82
        #expect(MetricsTables.metricsAboveRight[0x65] == -310)  // index 101 (row 6, 6th value)
        #expect(MetricsTables.metricsAboveRight[0x69] == 550)  // index 105
    }

    @Test func metricsBelowLeftSampleValues() {
        // Test some non-zero values
        #expect(MetricsTables.metricsBelowLeft[0x29] == -520)  // index 41
        #expect(MetricsTables.metricsBelowLeft[0x2B] == -470)  // index 43
        #expect(MetricsTables.metricsBelowLeft[0x2C] == -220)  // index 44
        #expect(MetricsTables.metricsBelowLeft[0x2E] == -320)  // index 46
        #expect(MetricsTables.metricsBelowLeft[0x55] == -300)  // index 85
        #expect(MetricsTables.metricsBelowLeft[0x57] == 620)  // index 87
        #expect(MetricsTables.metricsBelowLeft[0x5D] == -490)  // index 93
        #expect(MetricsTables.metricsBelowLeft[0x5E] == -420)  // index 94
        #expect(MetricsTables.metricsBelowLeft[0x5F] == -590)  // index 95
        #expect(MetricsTables.metricsBelowLeft[0x60] == -480)  // index 96
        #expect(MetricsTables.metricsBelowLeft[0x64] == 520)  // index 100
        #expect(MetricsTables.metricsBelowLeft[0x75] == -380)  // index 117 (row 7, 6th value)
        #expect(MetricsTables.metricsBelowLeft[0x7B] == -330)  // index 123
        #expect(MetricsTables.metricsBelowLeft[0x7C] == -350)  // index 124
        #expect(MetricsTables.metricsBelowLeft[0x7D] == -410)  // index 125
        #expect(MetricsTables.metricsBelowLeft[0x89] == 140)  // index 137
        #expect(MetricsTables.metricsBelowLeft[0xA8] == 150)  // index 168
        // Row C (0xC0-0xCF): values at 0xC4-0xCB are non-zero
        #expect(MetricsTables.metricsBelowLeft[0xC4] == 150)  // index 196 (row C, 5th value)
        #expect(MetricsTables.metricsBelowLeft[0xC5] == 200)  // index 197 (row C, 6th value)
        #expect(MetricsTables.metricsBelowLeft[0xC6] == 210)  // index 198 (row C, 7th value)
        #expect(MetricsTables.metricsBelowLeft[0xC7] == 60)  // index 199 (row C, 8th value)
        #expect(MetricsTables.metricsBelowLeft[0xC8] == 250)  // index 200 (row C, 9th value)
        #expect(MetricsTables.metricsBelowLeft[0xC9] == 130)  // index 201 (row C, 10th value)
        #expect(MetricsTables.metricsBelowLeft[0xCA] == 170)  // index 202 (row C, 11th value)
        #expect(MetricsTables.metricsBelowLeft[0xCB] == 150)  // index 203 (row C, 12th value)
        #expect(MetricsTables.metricsBelowLeft[0xCC] == 0)  // index 204 (row C, 13th value)
        #expect(MetricsTables.metricsBelowLeft[0xCD] == 0)  // index 205 (row C, 14th value)
        #expect(MetricsTables.metricsBelowLeft[0xCE] == 0)  // index 206 (row C, 15th value)
        #expect(MetricsTables.metricsBelowLeft[0xCF] == 160)  // index 207 (row C, 16th value)
        // Row D (0xD0-0xDF): mostly zeros, 0xD6 has 140
        #expect(MetricsTables.metricsBelowLeft[0xD0] == 0)  // index 208 (row D, 1st value)
        #expect(MetricsTables.metricsBelowLeft[0xD1] == 0)  // index 209 (row D, 2nd value)
        #expect(MetricsTables.metricsBelowLeft[0xD2] == 0)  // index 210 (row D, 3rd value)
        #expect(MetricsTables.metricsBelowLeft[0xD3] == 0)  // index 211 (row D, 4th value)
        #expect(MetricsTables.metricsBelowLeft[0xD4] == 0)  // index 212 (row D, 5th value)
        #expect(MetricsTables.metricsBelowLeft[0xD6] == 140)  // index 214
        #expect(MetricsTables.metricsBelowLeft[0xDA] == 550)  // index 218
        #expect(MetricsTables.metricsBelowLeft[0xDB] == 190)  // index 219
        #expect(MetricsTables.metricsBelowLeft[0xDC] == 780)  // index 220
        #expect(MetricsTables.metricsBelowLeft[0xDF] == 700)  // index 223
        #expect(MetricsTables.metricsBelowLeft[0xE3] == 700)  // index 227
        #expect(MetricsTables.metricsBelowLeft[0xEE] == 150)  // index 238
        #expect(MetricsTables.metricsBelowLeft[0xF2] == 150)  // index 242
        #expect(MetricsTables.metricsBelowLeft[0xF3] == 190)  // index 243
        #expect(MetricsTables.metricsBelowLeft[0xFA] == -550)  // index 250 (row F, 11th value)
        #expect(MetricsTables.metricsBelowLeft[0xFB] == -430)  // index 251 (row F, 12th value)
        #expect(MetricsTables.metricsBelowLeft[0xFC] == -450)  // index 252 (row F, 13th value)
    }

    @Test func metricsBelowRightSampleValues() {
        // Test some non-zero values
        #expect(MetricsTables.metricsBelowRight[0x29] == -70)  // index 41
        #expect(MetricsTables.metricsBelowRight[0x2B] == -10)  // index 43
        #expect(MetricsTables.metricsBelowRight[0x2C] == 130)  // index 44
        #expect(MetricsTables.metricsBelowRight[0x2E] == 30)  // index 46
        #expect(MetricsTables.metricsBelowRight[0x55] == 130)  // index 85
        #expect(MetricsTables.metricsBelowRight[0x57] == 810)  // index 87
        #expect(MetricsTables.metricsBelowRight[0x5D] == -30)  // index 93
        #expect(MetricsTables.metricsBelowRight[0x5E] == 20)  // index 94
        #expect(MetricsTables.metricsBelowRight[0x5F] == 20)  // index 95
        #expect(MetricsTables.metricsBelowRight[0x60] == 20)  // index 96
        #expect(MetricsTables.metricsBelowRight[0x64] == 730)  // index 100
        #expect(MetricsTables.metricsBelowRight[0x75] == 90)  // index 117 (row 7, 6th value)
        #expect(MetricsTables.metricsBelowRight[0x7B] == 120)  // index 123
        #expect(MetricsTables.metricsBelowRight[0x7C] == -10)  // index 124
        #expect(MetricsTables.metricsBelowRight[0x7D] == 20)  // index 125
        #expect(MetricsTables.metricsBelowRight[0x89] == 730)  // index 137
        #expect(MetricsTables.metricsBelowRight[0xA8] == 730)  // index 168
        // Row C (0xC0-0xCF): values at 0xC4-0xCB are non-zero
        #expect(MetricsTables.metricsBelowRight[0xC4] == 610)  // index 196 (row C, 5th value)
        #expect(MetricsTables.metricsBelowRight[0xC5] == 660)  // index 197 (row C, 6th value)
        #expect(MetricsTables.metricsBelowRight[0xC6] == 850)  // index 198 (row C, 7th value)
        #expect(MetricsTables.metricsBelowRight[0xC7] == 820)  // index 199 (row C, 8th value)
        #expect(MetricsTables.metricsBelowRight[0xC8] == 900)  // index 200 (row C, 9th value)
        #expect(MetricsTables.metricsBelowRight[0xC9] == 760)  // index 201 (row C, 10th value)
        #expect(MetricsTables.metricsBelowRight[0xCA] == 770)  // index 202 (row C, 11th value)
        #expect(MetricsTables.metricsBelowRight[0xCB] == 600)  // index 203 (row C, 12th value)
        #expect(MetricsTables.metricsBelowRight[0xCC] == 0)  // index 204 (row C, 13th value)
        #expect(MetricsTables.metricsBelowRight[0xCD] == 0)  // index 205 (row C, 14th value)
        #expect(MetricsTables.metricsBelowRight[0xCE] == 0)  // index 206 (row C, 15th value)
        #expect(MetricsTables.metricsBelowRight[0xCF] == 620)  // index 207 (row C, 16th value)
        // Row D (0xD0-0xDF): mostly zeros, 0xD6 has 590
        #expect(MetricsTables.metricsBelowRight[0xD0] == 0)  // index 208 (row D, 1st value)
        #expect(MetricsTables.metricsBelowRight[0xD1] == 0)  // index 209 (row D, 2nd value)
        #expect(MetricsTables.metricsBelowRight[0xD2] == 0)  // index 210 (row D, 3rd value)
        #expect(MetricsTables.metricsBelowRight[0xD3] == 0)  // index 211 (row D, 4th value)
        #expect(MetricsTables.metricsBelowRight[0xD4] == 0)  // index 212 (row D, 5th value)
        #expect(MetricsTables.metricsBelowRight[0xD6] == 590)  // index 214
        #expect(MetricsTables.metricsBelowRight[0xDA] == 740)  // index 218
        #expect(MetricsTables.metricsBelowRight[0xDB] == 740)  // index 219
        #expect(MetricsTables.metricsBelowRight[0xDC] == 840)  // index 220
        #expect(MetricsTables.metricsBelowRight[0xDF] == 750)  // index 223
        #expect(MetricsTables.metricsBelowRight[0xE3] == 750)  // index 227
        #expect(MetricsTables.metricsBelowRight[0xEE] == 700)  // index 238
        #expect(MetricsTables.metricsBelowRight[0xF2] == 620)  // index 242
        #expect(MetricsTables.metricsBelowRight[0xF3] == 630)  // index 243
        #expect(MetricsTables.metricsBelowRight[0xFA] == -70)  // index 250 (row F, 11th value)
        #expect(MetricsTables.metricsBelowRight[0xFB] == -60)  // index 251 (row F, 12th value)
        #expect(MetricsTables.metricsBelowRight[0xFC] == -100)  // index 252 (row F, 13th value)
    }
}

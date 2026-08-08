import Testing

@testable import MakeDevaCore

struct DistanceCalculationTests {
    
    @Test func distanceCodeThreshold240() {
        // Distance > 240 should return D270
        #expect(DistanceCalculation.distanceCode(for: 241) == FontConstants.D270)
        #expect(DistanceCalculation.distanceCode(for: 300) == FontConstants.D270)
        #expect(DistanceCalculation.distanceCode(for: 1000) == FontConstants.D270)
    }
    
    @Test func distanceCodeThreshold120() {
        // Distance > 120 but <= 240 should return D150
        #expect(DistanceCalculation.distanceCode(for: 121) == FontConstants.D150)
        #expect(DistanceCalculation.distanceCode(for: 240) == FontConstants.D150)
        #expect(DistanceCalculation.distanceCode(for: 200) == FontConstants.D150)
    }
    
    @Test func distanceCodeThreshold90() {
        // Distance > 90 but <= 120 should return D120
        #expect(DistanceCalculation.distanceCode(for: 91) == FontConstants.D120)
        #expect(DistanceCalculation.distanceCode(for: 120) == FontConstants.D120)
        #expect(DistanceCalculation.distanceCode(for: 100) == FontConstants.D120)
    }
    
    @Test func distanceCodeThreshold60() {
        // Distance > 60 but <= 90 should return D090
        #expect(DistanceCalculation.distanceCode(for: 61) == FontConstants.D090)
        #expect(DistanceCalculation.distanceCode(for: 90) == FontConstants.D090)
        #expect(DistanceCalculation.distanceCode(for: 75) == FontConstants.D090)
    }
    
    @Test func distanceCodeThreshold30() {
        // Distance > 30 but <= 60 should return D060
        #expect(DistanceCalculation.distanceCode(for: 31) == FontConstants.D060)
        #expect(DistanceCalculation.distanceCode(for: 60) == FontConstants.D060)
        #expect(DistanceCalculation.distanceCode(for: 45) == FontConstants.D060)
    }
    
    @Test func distanceCodeThreshold30Boundary() {
        // Distance <= 30 should return D030
        #expect(DistanceCalculation.distanceCode(for: 30) == FontConstants.D030)
        #expect(DistanceCalculation.distanceCode(for: 0) == FontConstants.D030)
        #expect(DistanceCalculation.distanceCode(for: 15) == FontConstants.D030)
        #expect(DistanceCalculation.distanceCode(for: -10) == FontConstants.D030)  // Negative values also return D030
    }
    
    @Test func distanceCodeExactBoundaries() {
        // Test exact boundary values
        #expect(DistanceCalculation.distanceCode(for: 30) == FontConstants.D030)
        #expect(DistanceCalculation.distanceCode(for: 31) == FontConstants.D060)
        #expect(DistanceCalculation.distanceCode(for: 60) == FontConstants.D060)
        #expect(DistanceCalculation.distanceCode(for: 61) == FontConstants.D090)
        #expect(DistanceCalculation.distanceCode(for: 90) == FontConstants.D090)
        #expect(DistanceCalculation.distanceCode(for: 91) == FontConstants.D120)
        #expect(DistanceCalculation.distanceCode(for: 120) == FontConstants.D120)
        #expect(DistanceCalculation.distanceCode(for: 121) == FontConstants.D150)
        #expect(DistanceCalculation.distanceCode(for: 240) == FontConstants.D150)
        #expect(DistanceCalculation.distanceCode(for: 241) == FontConstants.D270)
    }
}

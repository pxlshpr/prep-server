import Foundation
import PrepDataTypes

public struct FoodDensity: Codable {
    public var weightAmount: Double
    public var weightUnit: WeightUnit
    public var volumeAmount: Double
    public var volumeExplicitUnit: VolumeExplicitUnit
}

extension FoodDensity {
    func validate() throws {
        guard weightAmount > 0 else {
            throw FoodDensityError.nonPositiveWeight
        }
        guard volumeAmount > 0 else {
            throw FoodDensityError.nonPositiveVolume
        }
    }
}

enum FoodDensityError: Error {
    case nonPositiveWeight
    case nonPositiveVolume
}

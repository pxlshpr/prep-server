import Foundation
import PrepDataTypes

public struct FoodValue: Codable {
    public var value: Double
    public var unitType: UnitType
    public var weightUnit: WeightUnit?
    public var volumeExplicitUnit: VolumeExplicitUnit?
    public var sizeUnitId: String?
    public var sizeUnitVolumePrefixExplicitUnit: VolumeExplicitUnit?
}

extension FoodValue {
    func validate(within form: UserFoodCreateForm) throws {
        
        guard value > 0 else {
            throw FoodValueError.nonPositiveValue
        }
        
        /// if `unitType`is serving, the rest should be `nil`
        if unitType == .serving {
            guard weightUnit == nil, volumeExplicitUnit == nil, sizeUnitId == nil, sizeUnitVolumePrefixExplicitUnit == nil else {
                throw FoodValueError.extraneousUnits
            }
        }

        /// if `unitType`is weight, we should have a `weightUnit`, and the rest should be `nil`
        if unitType == .weight {
            guard weightUnit != nil else {
                throw FoodValueError.missingWeightUnit
            }
            guard volumeExplicitUnit == nil, sizeUnitId == nil, sizeUnitVolumePrefixExplicitUnit == nil else {
                throw FoodValueError.extraneousUnits
            }
        }
        
        /// if `unitType`is volume, we should have a `volumeExplicitUnit`, and the rest should be `nil`
        if unitType == .volume {
            guard volumeExplicitUnit != nil else {
                throw FoodValueError.missingVolumeUnit
            }
            guard weightUnit == nil, sizeUnitId == nil, sizeUnitVolumePrefixExplicitUnit == nil else {
                throw FoodValueError.extraneousUnits
            }
        }

        ///  if `unitType` is size
        if unitType == .size {
            /// we should have a `sizeUnitId`
            guard let sizeUnitId else {
                throw FoodValueError.missingSizeUnitId
            }

            /// we should have a size matched that `sizeUnitId`
            guard let size = form.sizes.size(for: sizeUnitId) else {
                throw FoodValueError.invalidSizeId
            }
            
            /// if the size is volume-prefixed
            if size.volumePrefixExplicitUnit != nil {
                /// we should have a `sizeUnitVolumePrefixExplicitUnit` specified
                guard sizeUnitVolumePrefixExplicitUnit != nil else {
                    throw FoodValueError.missingSizeVolumePrefixUnit
                }
            } else {
                /// otherwise, we shouldn't have a `sizeUnitVolumePrefixExplicitUnit`
                guard sizeUnitVolumePrefixExplicitUnit == nil else {
                    throw FoodValueError.extraneousUnits
                }
            }
            
            /// we shouldn't have a `weightUnit` or a `volumeExplicitUnit` specified
            guard weightUnit == nil, volumeExplicitUnit == nil else {
                throw FoodValueError.extraneousUnits
            }
        }
    }
}

enum FoodValueError: Error {
    case nonPositiveValue
    case extraneousUnits
    case missingWeightUnit
    case missingVolumeUnit
    case missingSizeUnitId
    case invalidSizeId
    case missingSizeVolumePrefixUnit
}

import Foundation
import PrepDataTypes

public struct FoodSize: Codable {
    public var name: String
    public var volumePrefixExplicitUnit: VolumeExplicitUnit?
    public var quantity: Double
    public var value: FoodValue
    
    public var id: String {
        if let volumePrefixExplicitUnit {
            return "\(name)\(volumePrefixExplicitUnit.volumeUnit.rawValue)"
        } else {
            return name
        }
    }
}

extension FoodSize {
    func validate(within form: UserFoodCreateForm) throws {
        /// Check that the quantity is positive
        guard quantity > 0 else {
            throw FoodSizeError.nonPositiveQuantity
        }
        
        /// Make sure the value is `valid`
        do {
            try value.validate(within: form)
        } catch let foodValueError as FoodValueError {
            throw FoodSizeError.amountError(foodValueError)
        }
        
        if volumePrefixExplicitUnit != nil {
            guard value.unitType == .weight else {
                throw FoodSizeError.volumePrefixProvidedForNonWeightBasedSize
            }
        }
    }
}

extension Array where Element == FoodSize {
    func validate(within form: UserFoodCreateForm) throws {
        guard map({$0.id}).isDistinct() else {
            throw FoodSizeError.duplicateSize
        }
        
        for size in self {
            try size.validate(within: form)
        }
    }
    
    func size(for sizeId: String) -> FoodSize? {
        first(where: { $0.id == sizeId })
    }

    func containsSize(with sizeId: String) -> Bool {
        contains(where: { $0.id == sizeId })
    }
}

enum FoodSizeError: Error {
    case duplicateSize
    case nonPositiveQuantity
    case amountError(FoodValueError)
    case volumePrefixProvidedForNonWeightBasedSize
}


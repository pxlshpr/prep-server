import Fluent
import Vapor
import PrepDataTypes

final class DatabaseFood: Model, Content {
    static let schema = "database_foods"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?

    @Field(key: "amount") var amount: FoodValue
    @Field(key: "serving") var serving: FoodValue?
    @Field(key: "nutrients") var nutrients: FoodNutrients
    @Field(key: "sizes") var sizes: [FoodSize]
    @OptionalField(key: "density") var density: FoodDensity?
   
    @OptionalField(key: "database") var database: FoodDatabase?
    @OptionalField(key: "database_food_id") var databaseFoodId: String?

    @Timestamp(key: "created_at", on: .create, format: .unix) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update, format: .unix) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete, format: .unix) var deletedAt: Date?
    
    @Children(for: \.$databaseFood) var barcodes: [Barcode]
    
    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

public struct FoodBarcode: Codable {
    public var payload: String
    public var symbology: BarcodeSymbology
    
    public init(payload: String, symbology: BarcodeSymbology) {
        self.payload = payload
        self.symbology = symbology
    }
}

public struct UserFoodUpdate: Codable {
    public let type: UserFoodUpdateType
    public let newStatus: UserFoodStatus?
    public let timestamp: Double
    public let userId: UUID
}

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

//MARK: - FoodNutrients

enum FoodNutrientsError: Error {
    case negativeEnergyValue
    case negativeCarbValue
    case negativeFatValue
    case negativeProteinValue
    case negativeNutrientValue
    case nutrientTypeAndUSDATypeIsNil
}

public struct FoodNutrients: Codable {
    
    public var energyInKcal: Double
    public var carb: Double
    public var protein: Double
    public var fat: Double
    public var micros: [FoodNutrient]
    
}

extension FoodNutrients {
    func validate() throws {
        //TODO: Check that we don't have absurd values [50655A1F7E07]
        guard energyInKcal >= 0 else { throw FoodNutrientsError.negativeEnergyValue }
        guard carb >= 0 else { throw FoodNutrientsError.negativeCarbValue }
        guard fat >= 0 else { throw FoodNutrientsError.negativeFatValue }
        guard protein >= 0 else { throw FoodNutrientsError.negativeProteinValue }

        for micro in micros {
            guard (micro.nutrientType != nil || micro.usdaType != nil) else {
                throw FoodNutrientsError.nutrientTypeAndUSDATypeIsNil
            }
            //TODO: Check that we have a valid NutrientUnit here [12C85AAA025D]
            //TODO: Check that we don't have absurd values [50655A1F7E07]

            guard micro.value >= 0 else {
                throw FoodNutrientsError.negativeNutrientValue
            }
        }
    }
}

public struct FoodNutrient: Codable {
    /**
     This can only be `nil` for USDA imported nutrients that aren't yet supported (and must therefore have a `usdaType` if so).
     */
    public var nutrientType: NutrientType?
    
    /**
     This is used to store the id of a USDA nutrient.
     */
    public var usdaType: Int16?
    public var value: Double
    public var nutrientUnit: NutrientUnit
}

//MARK: - FoodDensity

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

//MARK: - FoodValue

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

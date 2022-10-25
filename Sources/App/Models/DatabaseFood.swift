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

    @Field(key: "amount") var amount: FoodAmountWithUnit
    @Field(key: "serving") var serving: FoodAmountWithUnit?
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
    public var amountWithUnit: FoodAmountWithUnit
}


public struct FoodNutrients: Codable {
    public var energyInKcal: Double
    public var carb: Double
    public var protein: Double
    public var fat: Double
    public var micros: [FoodNutrient]
}

public struct FoodDensity: Codable {
    public var weightAmount: Double
    public var weightUnit: WeightUnit
    public var volumeAmount: Double
    public var volumeExplicitUnit: VolumeExplicitUnit
}

public struct FoodNutrient: Codable {
    /**
     This can only be `nil` for USDA imported nutrients that aren't yet supported (and must therefore have a `usdaType` if so).
     */
    public var nutrientType: NutrientType?
    
    /**
     This is used to store the id of a USDA nutrient.
     */
    public var usdaType: Int16
    public var amount: Double
    public var unit: NutrientUnit
}

public struct FoodAmountWithUnit: Codable {
    public var amount: Double
    public var unitType: UnitType
    public var weightUnit: WeightUnit?
    public var volumeExplicitUnit: VolumeExplicitUnit?
    public var sizeUnitId: UUID?
    public var sizeUnitVolumePrefixExplicitUnit: VolumeExplicitUnit?
}

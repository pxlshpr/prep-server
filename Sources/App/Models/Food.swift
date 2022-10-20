import Fluent
import Vapor

struct AmountWithUnit: Codable {
    var double: Double
    var unit: Int16
    var weightUnit: Int16?
    var volumeUnit: Int16?
    var sizeUnitId: UUID?
    var sizeUnitVolumePrefixUnit: Int16?
}

struct Density: Codable {
    var weightDouble: Double
    var weightUnit: Int16
    var volumeDouble: Double
    var volumeUnit: Int16
}

struct Barcode: Codable {
    var payload: String
    var symbology: Int16
}

struct Micronutrient: Codable {
    var name: String
    var amount: Double
    var unit: Int16
}

struct Nutrients: Codable {
    var energyAmount: Double
    var energyUnit: Double
    var carb: Double
    var protein: Double
    var fat: Double
    var micronutrients: [Micronutrient]
}

struct Size: Codable {
    var name: String
    var volumePrefixUnit: Int16?
    
    var quantity: Double
    var amount: Double
    var unit: Int16
    var weightUnit: Int16?
    var volumeUnit: Int16?
    var sizeUnitId: UUID?
    var sizeUnitVolumePrefixUnit: Int16?
}

final class Food: Model, Content {
    static let schema = "foods"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?
    @OptionalField(key: "barcodes") var barcodes: [Barcode]?

    @Field(key: "amount") var amount: AmountWithUnit
    @Field(key: "serving") var serving: AmountWithUnit   
    @Field(key: "nutrients") var nutrients: Nutrients
    @Field(key: "sizes") var sizes: [Size]
    @OptionalField(key: "density") var density: Density?
   
    @OptionalField(key: "link_url") var linkeUrl: String?
    @OptionalField(key: "prefilled_url") var prefilled_url: String?
    @OptionalField(key: "image_ids") var imageIds: [UUID]?

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

import Fluent
import Vapor

final class AmountWithUnit: Fields {
    @Field(key: "double") var double: Double
    @Field(key: "unit") var unit: Int16
    @OptionalField(key: "weight_unit") var weightUnit: Int16?
    @OptionalField(key: "volume_unit") var volumeUnit: Int16?
    @OptionalField(key: "size_unit_id") var sizeUnitId: UUID?
    @OptionalField(key: "size_unit_volume_prefix_explicit_unit") var sizeUnitVolumePrefixUnit: Int16?
    init() { }
}

final class Density: Fields {
    @OptionalField(key: "weight_double") var weightDouble: Double?
    @OptionalField(key: "weight_unit") var weightUnit: Int16?
    @OptionalField(key: "volume_double") var volumeDouble: Double?
    @OptionalField(key: "volume_unit") var volumeUnit: Int16?
}

struct Barcode: Codable {
    var payload: String
    var symbology: Int16
}

struct Micronutrient: Codable {
    var name: String
    var amount: Double
}

final class Food: Model, Content {
    static let schema = "foods"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?
    
    @Group(key: "amount") var amount: AmountWithUnit
    @Group(key: "serving") var serving: AmountWithUnit
   
    @Field(key: "energy") var energy: Double
    @Field(key: "carb") var carb: Double
    @Field(key: "fat") var fat: Double
    @Field(key: "protein") var protein: Double

    @Field(key: "micronutrients") var micronutrients: [Micronutrient]

    @Group(key: "density") var density: Density
   
    @OptionalField(key: "link_url") var linkeUrl: String?
    @OptionalField(key: "prefilled_url") var prefilled_url: String?
    
    @OptionalField(key: "barcodes") var barcodes: [Barcode]?

//    @Field(key: "amount") var amount: Double
//    @Field(key: "amount_unit") var amountUnit: Int
//    @OptionalField(key: "amount_weight_unit") var amountWeightUnit: Int?
//    @OptionalField(key: "amount_volume_explicit_unit") var amountVolumeExplicitUnit: Int?
//    @OptionalParent(key: "amount_size_unit_id") var amountSizeUnit: Size?
//    @OptionalField(key: "amount_size_unit_volume_prefix_explicit_unit") var amountSizeUnitVolumePrefixExplicitUnit: Int?
//
//    @Field(key: "serving") var serving: Double
//    @Field(key: "serving_unit") var servingUnit: Int
//    @OptionalField(key: "serving_weight_unit") var servingWeightUnit: Int?
//    @OptionalField(key: "serving_volume_explicit_unit") var servingVolumeExplicitUnit: Int?
//    @OptionalParent(key: "serving_size_unit_id") var servingSizeUnit: Size?
//    @OptionalField(key: "serving_size_unit_volume_prefix_explicit_unit") var servingSizeUnitVolumePrefixExplicitUnit: Int?


    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

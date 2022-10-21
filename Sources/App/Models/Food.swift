import Fluent
import Vapor
import PrepUnits

final class Barcode: Model, Content {
    static let schema = "barcodes"
    
    @ID(custom: "payload", generatedBy: .user) var id: String?
    @Field(key: "symbology") var symbology: Int16
    @Parent(key: "food_id") var food: Food
    
    init() { }
    
    init(payload: String? = nil, symbology: Int16, foodId: Food.IDValue) {
        self.id = payload
        self.symbology = symbology
        self.$food.id = foodId
    }
}

final class Food: Model, Content {
    static let schema = "foods"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?

    @Field(key: "amount") var amount: ServerAmountWithUnit
    @Field(key: "serving") var serving: ServerAmountWithUnit
    @Field(key: "nutrients") var nutrients: ServerNutrients
    @Field(key: "sizes") var sizes: [ServerSize]
    @OptionalField(key: "density") var density: ServerDensity?
   
    @OptionalField(key: "link_url") var linkUrl: String?
    @OptionalField(key: "prefilled_url") var prefilledUrl: String?
    @OptionalField(key: "image_ids") var imageIds: [UUID]?

    @Field(key: "type") var type: Int16
    @OptionalField(key: "verification_status") var verificationStatus: Int16?
    @OptionalField(key: "database") var database: Int16?

    @Children(for: \.$food) var barcodes: [Barcode]
    
    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

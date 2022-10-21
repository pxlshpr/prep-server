import Fluent
import Vapor
import PrepUnits

final class Food: Model, Content {
    static let schema = "foods"
    
    @ID(key: .id) var id: UUID?

    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?
    @OptionalField(key: "barcodes") var barcodes: [ServerBarcode]?

    @Field(key: "amount") var amount: ServerAmountWithUnit
    @Field(key: "serving") var serving: ServerAmountWithUnit
    @Field(key: "nutrients") var nutrients: ServerNutrients
    @Field(key: "sizes") var sizes: [ServerSize]
    @OptionalField(key: "density") var density: ServerDensity?
   
    @OptionalField(key: "link_url") var linkUrl: String?
    @OptionalField(key: "prefilled_url") var prefilledUrl: String?
    @OptionalField(key: "image_ids") var imageIds: [UUID]?

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

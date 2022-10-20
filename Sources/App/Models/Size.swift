//import Fluent
//import Vapor
//
//final class Size: Model, Content {
//    static let schema = "sizes"
//    
//    @ID(key: .id) var id: UUID?
//    @Field(key: "name") var name: String
//    @Field(key: "quantity") var quantity: Double
//    @OptionalField(key: "volume_prefix_unit") var volumePrefixUnit: Int16?
//    
//    @Group(key: "amount") var amount: AmountWithUnit
//    
//    init() { }
//
//    init(id: UUID? = nil) {
//        self.id = id
//    }
//}

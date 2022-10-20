//import Fluent
//
//struct CreateSize: AsyncMigration {
//    func prepare(on database: Database) async throws {
//        try await database.schema("sizes")
//            .id()
//            .field("name", .string, .required)
//            .field("quantity", .string, .required)
//            .field("volume_prefix_unit", .int16)
//        
//            .field("amount_double", .double, .required)
//            .field("amount_unit", .int16, .required)
//            .field("amount_weight_unit", .int16)
//            .field("amount_volume_unit", .int16)
//            .field("amount_size_unit_id", .uuid)
//            .field("amount_size_unit_volume_prefix_unit", .int16)
//
//            .create()
//    }
//    
//    func revert(on database: Database) async throws {
//        try await database.schema("sizes").delete()
//    }
//}

import Fluent

struct CreateFood: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("foods")
            .id()
            .field("name", .string, .required)
            .field("emoji", .string, .required)
            .field("detail", .string)
            .field("brand", .string)
        
            .field("amount", .json, .required)
//            .field("amount_double", .double, .required)
//            .field("amount_unit", .int16, .required)
//            .field("amount_weight_unit", .int16)
//            .field("amount_volume_unit", .int16)
//            .field("amount_size_unit_id", .uuid)
//            .field("amount_size_unit_volume_prefix_unit", .int16)
        
            .field("serving", .json, .required)
//            .field("serving_double", .double, .required)
//            .field("serving_unit", .int16, .required)
//            .field("serving_weight_unit", .int16)
//            .field("serving_volume_unit", .int16)
//            .field("serving_size_unit_id", .uuid)
//            .field("serving_size_unit_volume_prefix_unit", .int16)
        
            .field("energy", .double, .required)
            .field("carb", .double, .required)
            .field("fat", .double, .required)
            .field("protein", .double, .required)
        
            .field("micronutrients", .array(of: .dictionary(of: .double)), .required)

            .field("link_url", .string)
            .field("prefilled_url", .string)
        
            .field("barcodes", .array(of: .dictionary(of: .int16)))

            .field("sizes", .array(of: .json), .required)
        
            .field("density", .json)
//            .field("density_weight_double", .double)
//            .field("density_weight_unit", .int16)
//            .field("density_volume_double", .double)
//            .field("density_volume_unit", .int16)
        
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("foods").delete()
    }
}

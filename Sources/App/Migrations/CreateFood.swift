import Fluent

struct CreateFood: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("foods")
            .id()
            .field("name", .string, .required)
            .field("emoji", .string, .required)
            .field("detail", .string)
            .field("brand", .string)
            .field("barcodes", .array(of: .dictionary(of: .int16)))

            .field("amount", .json, .required)
            .field("serving", .json)
            .field("nutrients", .json, .required)
            .field("sizes", .array(of: .json), .required)
            .field("density", .json)

            .field("link_url", .string)
            .field("prefilled_url", .string)
            .field("image_ids", .array(of: .uuid))
        
            .field("type", .int16, .required)
            .field("verification_status", .int16)
            .field("database", .int16)
            .field("database_food_id", .string)

            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("foods").delete()
    }
}

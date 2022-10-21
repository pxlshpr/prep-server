import Fluent

struct CreateBarcode: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("barcodes")
            .field("payload", .string)
            .field("symbology", .int16)
            .field("food_id", .uuid, .required, .references(Food.schema, .id))

            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("barcodes").delete()
    }
}

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
        
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("foods").delete()
    }
}

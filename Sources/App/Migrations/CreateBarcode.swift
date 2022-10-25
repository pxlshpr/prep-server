import Fluent

struct CreateBarcode: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        
        let symbology = try await database.enum("barcode_symbology")
            .case("aztec")
            .case("code39")
            .case("code39Checksum")
            .case("code39FullASCII")
            .case("code39FullASCIIChecksum")
            .case("code93")
            .case("code93i")
            .case("code128")
            .case("dataMatrix")
            .case("ean8")
            .case("ean13")
            .case("i2of5")
            .case("i2of5Checksum")
            .case("itf14")
            .case("pdf417")
            .case("qr")
            .case("upce")
            .case("codabar")
            .case("gs1DataBar")
            .case("gs1DataBarExpanded")
            .case("gs1DataBarLimited")
            .case("microPDF417")
            .case("microQR")
            .create()
        
        try await database.schema("barcodes")
            .field("payload", .string)
            .field("symbology", symbology, .required)
            .field("user_food_id", .uuid, .references(UserFood.schema, .id))
            .field("database_food_id", .uuid, .references(DatabaseFood.schema, .id))

            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("barcodes").delete()
    }
}

import Fluent
import Vapor
import PrepUnits

enum FoodUpdateType: String, Codable {
    case typeChanged
    case updated
    case spawned
}

struct ServerFoodUpdate: Codable {
    let type: FoodUpdateType
    let foodType: FoodType
    let timestamp: Double
    let userId: UUID
}

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

final class TokenAwards: Model, Content {
    static let schema = "token_awards"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "tokens_awarded") var tokensAwarded: Int32
    @Parent(key: "user_id") var user: User
    @Parent(key: "user_food_id") var food: UserFood
    @OptionalParent(key: "other_user_id") var otherUser: User?
    @Timestamp(key: "created_at", on: .create, format: .unix) var createdAt: Date?

    init() { }

    init(id: UUID? = nil) {
        self.id = id
    }
}

final class TokenRedemptions: Model, Content {
    static let schema = "token_redemptions"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "tokens_redeemed") var tokensRedeemed: Int32
    @Parent(key: "user_id") var user: User
    @Timestamp(key: "created_at", on: .create, format: .unix) var createdAt: Date?

    init() { }

    init(id: UUID? = nil) {
        self.id = id
    }
}

final class UserFood: Model, Content {
    static let schema = "user_foods"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?

    @Field(key: "amount") var amount: ServerAmountWithUnit
    @Field(key: "serving") var serving: ServerAmountWithUnit?
    @Field(key: "nutrients") var nutrients: ServerNutrients
    @Field(key: "sizes") var sizes: [ServerSize]
    @OptionalField(key: "density") var density: ServerDensity?
   
    @OptionalField(key: "link_url") var linkUrl: String?
    @OptionalField(key: "prefilled_url") var prefilledUrl: String?
    @OptionalField(key: "image_ids") var imageIds: [UUID]?

    @Field(key: "type") var type: Int16
    @OptionalField(key: "verification_status") var verificationStatus: Int16?

    @OptionalParent(key: "spawned_food_id") var spawnedFood: UserFood?
    @Field(key: "updates") var updates: [ServerFoodUpdate]
    @Field(key: "use_count_others") var useCountByOthers: Int32
    @Field(key: "use_count_owner") var useCountByOwner: Int32

    @Timestamp(key: "created_at", on: .create, format: .unix) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update, format: .unix) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete, format: .unix) var deletedAt: Date?
    @OptionalField(key: "deleted_for_owner_at") var deletedForOwnerAt: Double?

    @Parent(key: "user_id") var user: User
    @Children(for: \.$userFood) var barcodes: [Barcode]
    
    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

final class DatabaseFood: Model, Content {
    static let schema = "database_foods"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?

    @Field(key: "amount") var amount: ServerAmountWithUnit
    @Field(key: "serving") var serving: ServerAmountWithUnit?
    @Field(key: "nutrients") var nutrients: ServerNutrients
    @Field(key: "sizes") var sizes: [ServerSize]
    @OptionalField(key: "density") var density: ServerDensity?
   
    @OptionalField(key: "database") var database: Int16?
    @OptionalField(key: "database_food_id") var databaseFoodId: String?

    @Timestamp(key: "created_at", on: .create, format: .unix) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update, format: .unix) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete, format: .unix) var deletedAt: Date?
    
    @Children(for: \.$databaseFood) var barcodes: [Barcode]
    
    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

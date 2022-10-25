import Fluent
import Vapor
import PrepDataTypes
import SwiftSugar

final class UserFood: Model, Content {
    static let schema = "user_foods"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?

    @Field(key: "amount") var amount: FoodValue
    @Field(key: "serving") var serving: FoodValue?
    @Field(key: "nutrients") var nutrients: FoodNutrients
    @Field(key: "sizes") var sizes: [FoodSize]
    @OptionalField(key: "density") var density: FoodDensity?
   
    @OptionalField(key: "link_url") var linkUrl: String?
    @OptionalField(key: "prefilled_url") var prefilledUrl: String?
    @OptionalField(key: "image_ids") var imageIds: [UUID]?

    @Field(key: "status") var status: UserFoodStatus
    @OptionalParent(key: "spawned_user_food_id") var spawnedUserFood: UserFood?
    @OptionalParent(key: "spawned_database_food_id") var spawnedDatabaseFood: DatabaseFood?
    @Field(key: "changes") var changes: [UserFoodChange]
    @Field(key: "use_count_others") var numberOfUsesByOthers: Int32
    @Field(key: "use_count_owner") var numberOfUsesByOwner: Int32

    @Timestamp(key: "created_at", on: .create, format: .unix) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update, format: .unix) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete, format: .unix) var deletedAt: Date?
    @OptionalField(key: "deleted_for_owner_at") var deletedForOwnerAt: Double?

    @Parent(key: "user_id") var user: User
    @Children(for: \.$userFood) var barcodes: [Barcode]
    
    init() { }

    init(_ form: UserFoodCreateForm, for db: Database) async throws {
        
        do {
            try await form.validate()
        } catch let formError as UserFoodCreateFormError {
            throw UserFoodCreateError.formError(formError)
        }
        
        let spawnedUserFood: UserFood?
        if let userFoodId = form.spawnedUserFoodId {
            guard let userFood = try await UserFood.find(userFoodId, on: db) else {
                throw UserFoodCreateFormError.nonExistentSpawnedUserFood
            }
            spawnedUserFood = userFood
        } else {
            spawnedUserFood = nil
        }

        let spawnedDatabaseFood: DatabaseFood?
        if let databaseFoodId = form.spawnedDatabaseFoodId {
            guard let databaseFood = try await DatabaseFood.find(databaseFoodId, on: db) else {
                throw UserFoodCreateFormError.nonExistentSpawnedDatabaseFood
            }
            spawnedDatabaseFood = databaseFood
        } else {
            spawnedDatabaseFood = nil
        }
        
        guard !(spawnedUserFood != nil && spawnedDatabaseFood != nil) else {
            throw UserFoodCreateFormError.bothSpawnedUserAndDatabaseFoodsWereProvided
        }

        /// Check that the provided `userId` is for an existing user
        guard let user = try await User.find(form.userId, on: db) else {
            throw UserFoodCreateFormError.nonExistentUser
        }
        
        //MARK: Now we can create the UserFood
        
        self.name = form.name
        self.emoji = form.emoji
        self.detail = form.detail
        self.brand = form.brand
        self.amount = form.amount
        self.serving = form.serving
        self.nutrients = form.nutrients
        self.sizes = form.sizes
        self.density = form.density
        self.linkUrl = form.linkUrl
        self.prefilledUrl = form.prefilledUrl
        self.imageIds = form.imageIds
        self.status = form.status
        
        self.$user.id = form.userId
        
        self.changes = []
        self.numberOfUsesByOwner = 0
        self.numberOfUsesByOthers = 0
        
        self.createdAt = Date()
        self.updatedAt = Date()        
    }
}

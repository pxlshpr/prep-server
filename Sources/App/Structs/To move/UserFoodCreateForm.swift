import Foundation
import PrepDataTypes

struct UserFoodCreateForm: Codable {
    var name: String
    var emoji: String
    var detail: String?
    var brand: String?
    var amount: FoodValue
    var serving: FoodValue?
    var nutrients: FoodNutrients
    var sizes: [FoodSize]
    var density: FoodDensity?
    var linkUrl: String?
    var prefilledUrl: String?
    var imageIds: [UUID]?
    var status: UserFoodStatus
    
    var spawnedFoodId: UUID?
    var userId: UUID
    
    var barcodes: [FoodBarcode]
}

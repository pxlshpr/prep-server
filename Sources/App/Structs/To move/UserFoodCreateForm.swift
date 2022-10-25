import Foundation
import PrepDataTypes

struct UserFoodCreateForm: Codable {
    var name: String
    var emoji: String
    var detail: String?
    var brand: String?
    var amount: FoodAmountWithUnit
    var serving: FoodAmountWithUnit?
    var nutrients: FoodNutrients
    var sizes: [FoodSize]
    var density: FoodDensity?
    var linkUrl: String?
    var prefilledUrl: String?
    var imageIds: [String]?
    var status: UserFoodStatus
    
    var spawnedFoodId: String?
    var userId: String
    
    var barcodes: [FoodBarcode]
}

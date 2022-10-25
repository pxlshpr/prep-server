import PrepDataTypes

struct UserFoodForm: Codable {
    var food: UserFood
    var barcodes: [FoodBarcode]
}

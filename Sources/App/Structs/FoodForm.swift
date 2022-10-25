import PrepUnits

struct UserFoodForm: Codable {
    var food: UserFood
    var barcodes: [ServerBarcode]
}

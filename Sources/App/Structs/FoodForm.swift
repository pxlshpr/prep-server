import PrepUnits

struct FoodForm: Codable {
    var food: Food
    var barcodes: [ServerBarcode]
}

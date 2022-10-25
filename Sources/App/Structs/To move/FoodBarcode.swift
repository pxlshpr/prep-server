import Foundation

public struct FoodBarcode: Codable {
    public var payload: String
    public var symbology: BarcodeSymbology
    
    public init(payload: String, symbology: BarcodeSymbology) {
        self.payload = payload
        self.symbology = symbology
    }
}

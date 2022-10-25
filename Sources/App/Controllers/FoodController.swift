import Fluent
import Vapor
import PrepDataTypes

struct UserFoodController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let foods = routes.grouped("user_foods")
        foods.post(use: create)
    }
    
    func create(req: Request) async throws -> String {
        
        let foodForm = try req.content.decode(UserFoodCreateForm.self)
        
        print("We here with: \(foodForm.name)")
        
        return ""
//        guard let foodId = foodForm.food.id else {
//            throw APIError.missingFoodId
//        }
//
//        /// Save the `UserFood`
//        try await foodForm.food.save(on: req.db)
//
//        /// Now save all the `Barcode`s
//        for barcode in foodForm.barcodes {
//            let barcode = Barcode(barcode: barcode, userFoodId: foodId)
//            try await barcode.save(on: req.db)
//        }
//
//        return foodForm.food
    }
    
}

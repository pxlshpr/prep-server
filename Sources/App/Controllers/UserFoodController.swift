import Fluent
import Vapor
import PrepDataTypes

struct UserFoodController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let foods = routes.grouped("user_foods")
        foods.post(use: create)
    }
    
    func create(req: Request) async throws -> UserFood {
        let createForm = try req.content.decode(UserFoodCreateForm.self)
        let userFood = try await UserFood(createForm, for: req.db)
        try await userFood.save(on: req.db)
        guard let userFoodId = userFood.id else {
            throw UserFoodCreateError.missingFoodId
        }
        for barcode in createForm.barcodes {
            let barcode = Barcode(barcode: barcode, userFoodId: userFoodId)
            try await barcode.save(on: req.db)
        }
        return userFood
    }
}

enum UserFoodCreateError: Error {
    case formError(UserFoodCreateFormError)
    case missingFoodId
}

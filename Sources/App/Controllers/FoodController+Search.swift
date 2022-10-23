import Fluent
import Vapor
import PrepUnits

extension FoodController {
    func search(req: Request) async throws -> String {
        let params = try req.query.decode(ServerFoodSearchParams.self)
        return "Searching for: \(params.string)"
    }
}

extension ServerFoodSearchParams: Content {
    
}

import Fluent
import Vapor
import PrepUnits

//extension QueryBuilder {
//    func caseInsensitiveFilter<Field>(of string: String, on field: KeyPath<Model, Field>) -> QueryBuilder<Food> {
//        self
//        .filter(field ~~ string)
//        .filter(field ~~ string.uppercased())
//        .filter(field ~~ string.lowercased())
//        .filter(field ~~ string.capitalized)
//    }
//}
extension FoodController {
    
    
    func search(req: Request) async throws -> Page<FoodSearchResult> {
        let params = try req.query.decode(ServerFoodSearchParams.self)
        
        guard let primaryResults = try await primaryResults(params: params, db: req.db) else {
            print("🔎 No primary reuslts for \(params.string)")
            throw APIError.foodNotFound
        }
        
        return primaryResults
    }
    
    //TODO: The page and per for the search should be provided here and converted to the page and per for the actual results
    func primaryResults(params: ServerFoodSearchParams, db: Database) async throws -> Page<FoodSearchResult>? {
        /// Foods with a name that starts with the *full* string
        let query = Food.query(on: db)
            .filter(\.$name, .custom("ILIKE"), "\(params.string)%")

        /// First count how many, and determine that the page we are looking for is amongst it
        let count = try await query.count()
        guard count > params.startIndex else {
            return nil
        }
        
        let page = params.page
        let per = params.per
        
        return try await query
            .sort(\.$name)
            .sort(\.$id)
            .paginate(PageRequest(page: page, per: per))
            .map { FoodSearchResult($0) }
    }
}

extension ServerFoodSearchParams {
    var startIndex: Int {
        (page-1) * per
    }
    
    var endIndex: Int {
        (page * per) - 1
    }
}

extension ServerFoodSearchParams: Content { }
extension FoodSearchResult: Content { }

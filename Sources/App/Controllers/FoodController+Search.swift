import Fluent
import Vapor
import PrepUnits

protocol SearchResultsProvider {
    
    var name: String { get }
    var params: ServerFoodSearchParams { get }
    var db: Database { get }
    var query: QueryBuilder<Food> { get }
    func count() async throws -> Int
    func results(startingFrom: Int, previousResults: [FoodSearchResult]) async throws -> Page<FoodSearchResult>
}

extension SearchResultsProvider {
    
    func count() async throws -> Int {
        try await query.count()
    }

    func results(startingFrom position: Int, previousResults: [FoodSearchResult]) async throws -> Page<FoodSearchResult> {
        print("** \(name) **")
        let count = try await count()

        let weNeedToStartAt = previousResults.count == 0 ? position : 0
        print ("    🔍 weNeedToStartAt: \(weNeedToStartAt)")
        let whatIsNeeded = params.per - previousResults.count
        print ("    🔍 whatIsNeeded: \(whatIsNeeded)")
        let whatCanBeProvided = min(params.per, count - weNeedToStartAt)
        print ("    🔍 whatCanBeProvided: \(whatCanBeProvided)")
        let whatWillBeProvided = min(whatIsNeeded, whatCanBeProvided)
        print ("    🟪 whatWillBeProvided: \(whatWillBeProvided), starting from: \(weNeedToStartAt)")

        let endPosition = position + whatWillBeProvided

//        let endIndex = min(params.endIndex, (count + previousResults.count) - 1)
        print ("    🔍 Filling allPositions: \(position)...\(endPosition) with localPositions: \(weNeedToStartAt)...\(weNeedToStartAt + whatWillBeProvided)")

        let countThatWeNeed = endPosition - position
        
        let internalPosition = position - previousResults.count
        let per = min(countThatWeNeed, params.per)
        let page = previousResults.count == 0 ? (internalPosition / per) + 1 : 1
        print ("    Getting page \(page) per \(per)")
        return try await query
            .sort(\.$name)
            .sort(\.$id)
            .paginate(PageRequest(page: page, per: per))
            .map { FoodSearchResult($0) }
    }
}

struct SearchNamePrefix: SearchResultsProvider {
    
    let name = "SearchNamePrefix"
    let params: ServerFoodSearchParams
    let db: Database
 
    var query: QueryBuilder<Food> {
        Food.query(on: db)
            .filter(\.$name, .custom("ILIKE"), "\(params.string)%")
    }
}

struct SearchDetailPrefix: SearchResultsProvider {
    
    let name = "SearchDetailPrefix"
    let params: ServerFoodSearchParams
    let db: Database
 
    var query: QueryBuilder<Food> {
        Food.query(on: db)
            .filter(\.$detail, .custom("ILIKE"), "\(params.string)%")
    }
}

class SearchCoordinator {
    let params: ServerFoodSearchParams
    let db: Database

    var position: Int
    
    init(params: ServerFoodSearchParams, db: Database) {
        self.params = params
        self.db = db
        
        self.position = params.startIndex
    }
    
    func search() async throws -> Page<FoodSearchResult> {
        let searches: [SearchResultsProvider] = [
            SearchNamePrefix(params: params, db: db),
            SearchDetailPrefix(params: params, db: db),
        ]
        
        var allResults: [FoodSearchResult] = []
        var count = 0
        for search in searches {
            count += try await search.count()
            
            /// If we have enough, stop getting the results (we'll still keep getting the total count though)
            if position < params.endIndex {
                let results = try await search.results(startingFrom: position, previousResults: allResults).items
                allResults += results
                position += results.count
            }
        }
        let metadata = PageMetadata(page: params.page, per: params.per, total: count)
        return Page(items: allResults, metadata: metadata)
    }
}

extension FoodController {
    
    func search(req: Request) async throws -> Page<FoodSearchResult> {
        let params = try req.query.decode(ServerFoodSearchParams.self)
        return try await SearchCoordinator(params: params, db: req.db).search()
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

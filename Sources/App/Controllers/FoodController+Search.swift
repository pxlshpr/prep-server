import Fluent
import Vapor
import PrepUnits

protocol SearchResultsProvider {
    
    var name: String { get }
    var params: ServerFoodSearchParams { get }
    var db: Database { get }
    var query: QueryBuilder<Food> { get }
    func count(previousResults: [FoodSearchResult]) async throws -> Int
    func results(startingFrom: Int, totalCount: Int, previousResults: [FoodSearchResult]) async throws -> [FoodSearchResult]
}

extension Array where Element == FoodSearchResult {
    var ids: [UUID] {
        map { $0.id }
    }
}

extension SearchResultsProvider {
    
    func count(previousResults: [FoodSearchResult]) async throws -> Int {
        try await query
            .filter(\.$id !~ previousResults.ids)
            .count()
    }

    func results(startingFrom position: Int, totalCount: Int, previousResults: [FoodSearchResult]) async throws -> [FoodSearchResult] {
        print("** \(name) **")
        let count = try await count(previousResults: previousResults)
        
//        let weNeedToStartAt = isFirstSearch ? position : 0
        let weNeedToStartAt = position - totalCount
        print ("    🔍 weNeedToStartAt: \(weNeedToStartAt)")
        let whatIsNeeded = params.per - previousResults.count
        print ("    🔍 whatIsNeeded: \(whatIsNeeded)")
        let whatCanBeProvided = max(min(params.per, count - weNeedToStartAt), 0)
        print ("    🔍 whatCanBeProvided: \(whatCanBeProvided)")
        let whatWillBeProvided = min(whatIsNeeded, whatCanBeProvided)
        print ("    🟪 whatWillBeProvided: \(whatWillBeProvided), starting from: \(weNeedToStartAt)")

        guard whatWillBeProvided > 0 else {
            return []
        }
        
        let endPosition = position + whatWillBeProvided

//        let endIndex = min(params.endIndex, (count + previousResults.count) - 1)
        print ("    🔍 Filling allPositions: \(position)...\(endPosition) with localPositions: \(weNeedToStartAt)...\(weNeedToStartAt + whatWillBeProvided)")

        /// For 2, 100, Chicken—it should be
        /// Gett
        print ("    Getting \(whatWillBeProvided) foods offset by \(weNeedToStartAt)")
        return try await query
            .filter(\.$id !~ previousResults.ids)
            .sort(\.$name)
            .sort(\.$id)
            .offset(weNeedToStartAt)
            .limit(whatWillBeProvided)
            .all()
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
        var totalCount = 0
        for index in searches.indices {
            let search = searches[index]
            
            let count = try await search.count(previousResults: allResults)
            let previousTotalCount = totalCount
            totalCount += count

            /// If we have enough, stop getting the results (we're still getting the total count though)
            guard position < params.endIndex else { continue }

            let results = try await search.results(startingFrom: position, totalCount: previousTotalCount, previousResults: allResults)
            allResults += results
            
            position += results.count
        }
        let metadata = PageMetadata(page: params.page, per: params.per, total: totalCount)
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

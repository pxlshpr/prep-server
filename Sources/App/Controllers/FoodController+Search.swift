import Fluent
import Vapor
import PrepUnits

struct SearchResultsProvider {
    let name: String
    let params: ServerFoodSearchParams
    let db: Database
    let query: QueryBuilder<Food>
    
    func results(startingFrom position: Int, totalCount: Int, previousResults: [FoodSearchResult], idsToIgnore: [UUID]) async throws -> [FoodSearchResult] {
        print("** \(name) **")
        let count = try await count(idsToIgnore: idsToIgnore)
        
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
            .filter(\.$id !~ idsToIgnore)
//            .sort(.sql(raw: "CHAR_LENGTH(CONCAT(name,' ',detail))-CHAR_LENGTH('\(params.string)')"))
//            .sort(\.$name)
            .sort(\.$id) /// have this to ensure we always have a uniquely identifiable sort order (to disallow overlaps in pagination)
            .offset(weNeedToStartAt)
            .limit(whatWillBeProvided)
            .all()
            .map { FoodSearchResult($0) }
    }
    
    func allResultIds(ignoring idsToIgnore: [UUID]) async throws -> [UUID] {
        try await query
            .filter(\.$id !~ idsToIgnore)
            .all()
            .map { $0.id! }
    }
    
    func count(idsToIgnore: [UUID]) async throws -> Int {
        try await query
            .filter(\.$id !~ idsToIgnore)
            .count()
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
        
        var idsToIgnore: [UUID] = []
        var candidateResults: [FoodSearchResult] = []
        var totalCount = 0
        
        for (name, query) in queries(string: params.string, db: db) {
            let provider = SearchResultsProvider(name: name, params: params, db: db, query: query)
            let count = try await provider.count(idsToIgnore: idsToIgnore)
            let previousTotalCount = totalCount
            totalCount += count

            print("🔎 \(name) has \(count) matches")
            /// If we have enough, stop getting the results (we're still getting the total count though)
            guard position < params.endIndex else { continue }
            
            let preFetchedIdsToIgnore = try await provider.allResultIds(ignoring: [])

            let results = try await provider.results(startingFrom: position, totalCount: previousTotalCount, previousResults: candidateResults, idsToIgnore: idsToIgnore)
            candidateResults += results

            idsToIgnore += preFetchedIdsToIgnore
            print("✨ idsToIgnore: \(idsToIgnore.count)")

            position += results.count
        }
        let metadata = PageMetadata(page: params.page, per: params.per, total: totalCount)
        return Page(items: candidateResults, metadata: metadata)
    }
    

}

extension FoodController {
    
    func search(req: Request) async throws -> Page<FoodSearchResult> {
        let params = try req.content.decode(ServerFoodSearchParams.self)
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

extension Array where Element == FoodSearchResult {
    var ids: [UUID] {
        map { $0.id }
    }
}

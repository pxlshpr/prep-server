import Fluent
import Vapor
import PrepUnits

func queryNamePrefix(string: String, db: Database) -> QueryBuilder<Food> {
    Food.query(on: db)
        .filter(\.$name, .custom("ILIKE"), "\(string)%")
}

func queryDetailPrefix(string: String, db: Database) -> QueryBuilder<Food> {
    Food.query(on: db)
        .filter(\.$detail, .custom("ILIKE"), "\(string)%")
}

func queries(string: String, db: Database) -> [String: QueryBuilder<Food>] {
    [
        "NamePrefix": queryNamePrefix(string: string, db: db),
        "DetailPrefix": queryDetailPrefix(string: string, db: db)
    ]
}

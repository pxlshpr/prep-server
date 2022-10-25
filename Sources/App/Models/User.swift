import Fluent
import Vapor
import PrepDataTypes

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
    }
    
    func create(req: Request) async throws -> User {
        let createForm = try req.content.decode(UserCreateForm.self)
        let user = User(createForm)
        try await user.save(on: req.db)
        return user
    }
    
}

enum UserCreateError: Error {
}

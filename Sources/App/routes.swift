import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("createFood") { req async in
        let food = Food()
        food.name = "Food"
        return "HI"
    }

//    try app.register(collection: TodoController())
}

import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("createFood") { req async throws in
        let food = Food()
        food.name = "Food"
        food.emoji = "🤖"
        food.amount = AmountWithUnit(double: 1, unit: 1)
        food.serving = AmountWithUnit(double: 25, unit: 2)
        food.nutrients = Nutrients(
            energyAmount: 500,
            energyUnit: 1,
            carb: 20,
            protein: 45,
            fat: 60,
            micronutrients: [
            ]
        )
        food.sizes = []
        try await food.save(on: req.db)
        return "Food saved"
    }

//    try app.register(collection: TodoController())
}

import Foundation

struct UserCreateForm: Codable {
    var name: String
}

enum UserCreateFormError: Error {
}

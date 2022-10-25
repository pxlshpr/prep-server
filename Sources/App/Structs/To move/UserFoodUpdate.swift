import Foundation
import PrepDataTypes

public struct UserFoodChange: Codable {
    public let type: UserFoodChangeType
    public let newStatus: UserFoodStatus?
    public let timestamp: Double
    public let userId: UUID
}

import Foundation

public enum UserFoodUpdateType: String, Codable {
    case statusChange
    
    /// Used to indicate that a combination of front-facing fields and metadata were updated
    case dataUpdate
    
    /// Used to indicate that only metadata (not front-facing fields like name, energy, nutrients etc) were updated
    case metadataOnlyUpdate
    case spawned
}

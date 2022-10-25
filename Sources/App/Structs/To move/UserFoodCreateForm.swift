import Foundation
import PrepDataTypes
import Fluent

struct UserFoodCreateForm: Codable {
    var name: String
    var emoji: String
    var detail: String?
    var brand: String?
    var amount: FoodValue
    var serving: FoodValue?
    var nutrients: FoodNutrients
    var sizes: [FoodSize]
    var density: FoodDensity?
    var linkUrl: String?
    var prefilledUrl: String?
    var imageIds: [UUID]?
    var status: UserFoodStatus
    
    var spawnedUserFoodId: UUID?
    var spawnedDatabaseFoodId: UUID?
    var userId: UUID
    
    var barcodes: [FoodBarcode]
}

extension UserFoodCreateForm {
    
    func validate() async throws {
        /// `emoji` should be an emoji
        guard emoji.isSingleEmoji else {
            throw UserFoodCreateFormError.invalidEmoji
        }
        
        /// `amount` should have a valid `FoodValue`
        do {
            try amount.validate(within: self)
        } catch let error as FoodValueError {
            throw UserFoodCreateFormError.amountError(error)
        }
        
        /// `serving` should have a valid `FoodValue` if provided
        do {
            try serving?.validate(within: self)
        } catch let error as FoodValueError {
            throw UserFoodCreateFormError.servingError(error)
        }

        do {
            try nutrients.validate()
        } catch let error as FoodNutrientsError {
            throw UserFoodCreateFormError.nutrientsError(error)
        }

        do {
            try sizes.validate(within: self)
        } catch let error as FoodSizeError {
            throw UserFoodCreateFormError.sizesError(error)
        }
        
        do {
            try density?.validate()
        } catch let error as FoodDensityError {
            throw UserFoodCreateFormError.densityError(error)
        }
        
        if let linkUrl {
            guard linkUrl.isValidURL else {
                throw UserFoodCreateFormError.invalidLinkUrl
            }
        }
        if let prefilledUrl {
            guard prefilledUrl.isValidURL else {
                throw UserFoodCreateFormError.invalidPrefilledUrl
            }
        }
        
        guard status == .notPublished || status == .pendingReview else {
            throw UserFoodCreateFormError.initialStatusMustPendingReviewOrNotPublished
        }
        
        //TODO: For each barcode—check that the payload we have is valid for the symbology
    }
}

enum UserFoodCreateFormError: Error {
    case invalidEmoji
    case amountError(FoodValueError)
    case servingError(FoodValueError)
    case nutrientsError(FoodNutrientsError)
    case sizesError(FoodSizeError)
    case densityError(FoodDensityError)
    case invalidLinkUrl
    case invalidPrefilledUrl
    case initialStatusMustPendingReviewOrNotPublished
    case nonExistentUser
    case nonExistentSpawnedUserFood
    case nonExistentSpawnedDatabaseFood
    case bothSpawnedUserAndDatabaseFoodsWereProvided
}

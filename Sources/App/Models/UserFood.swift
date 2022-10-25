import Fluent
import Vapor
import PrepDataTypes
import SwiftSugar

final class UserFood: Model, Content {
    static let schema = "user_foods"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "emoji") var emoji: String
    @OptionalField(key: "detail") var detail: String?
    @OptionalField(key: "brand") var brand: String?

    @Field(key: "amount") var amount: FoodValue
    @Field(key: "serving") var serving: FoodValue?
    @Field(key: "nutrients") var nutrients: FoodNutrients
    @Field(key: "sizes") var sizes: [FoodSize]
    @OptionalField(key: "density") var density: FoodDensity?
   
    @OptionalField(key: "link_url") var linkUrl: String?
    @OptionalField(key: "prefilled_url") var prefilledUrl: String?
    @OptionalField(key: "image_ids") var imageIds: [UUID]?

    @Field(key: "status") var status: UserFoodStatus
    @OptionalParent(key: "spawned_food_id") var spawnedFood: UserFood?
    @Field(key: "updates") var updates: [UserFoodUpdate]
    @Field(key: "use_count_others") var numberOfUsesByOthers: Int32
    @Field(key: "use_count_owner") var numberOfUsesByOwner: Int32

    @Timestamp(key: "created_at", on: .create, format: .unix) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update, format: .unix) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete, format: .unix) var deletedAt: Date?
    @OptionalField(key: "deleted_for_owner_at") var deletedForOwnerAt: Double?

    @Parent(key: "user_id") var user: User
    @Children(for: \.$userFood) var barcodes: [Barcode]
    
    init() { }

    init?(_ form: UserFoodCreateForm) throws {
        
        do {
            try form.validate()
        } catch let formError as UserFoodCreateFormError {
            throw UserFoodCreateError.formError(formError)
        }
        
        return nil
    }
}

extension UserFoodCreateForm {
    func validate() throws {
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
        
        /// If a spawnedFoodId was provided—check that it exists
        
        /// Check that the provided `userId` is for an existing user
        
        /// For each barcode—check that the payload we have is valid for the symbology
    }
}
extension Array where Element == FoodSize {
    func validate(within form: UserFoodCreateForm) throws {
        guard map({$0.id}).isDistinct() else {
            throw FoodSizeError.duplicateSize
        }
        
        for size in self {
            try size.validate(within: form)
        }
    }
}

extension Sequence where Element: Hashable {

    /// Returns true if no element is equal to any other element.
    func isDistinct() -> Bool {
        var set = Set<Element>()
        for e in self {
            if set.insert(e).inserted == false { return false }
        }
        return true
    }
}

extension FoodSize {
    func validate(within form: UserFoodCreateForm) throws {
        /// Check that the quantity is positive
        guard quantity > 0 else {
            throw FoodSizeError.nonPositiveQuantity
        }
        
        /// Make sure the value is `valid`
        do {
            try value.validate(within: form)
        } catch let foodValueError as FoodValueError {
            throw FoodSizeError.amountError(foodValueError)
        }
        
        if volumePrefixExplicitUnit != nil {
            guard value.unitType == .weight else {
                throw FoodSizeError.volumePrefixProvidedForNonWeightBasedSize
            }
        }
    }
}

enum UserFoodCreateError: Error {
    case formError(UserFoodCreateFormError)
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
}

enum FoodSizeError: Error {
    case duplicateSize
    case nonPositiveQuantity
    case amountError(FoodValueError)
    case volumePrefixProvidedForNonWeightBasedSize
}

enum FoodValueError: Error {
    case nonPositiveValue
    case extraneousUnits
    case missingWeightUnit
    case missingVolumeUnit
    case missingSizeUnitId
    case invalidSizeId
    case missingSizeVolumePrefixUnit
}


extension Array where Element == FoodSize {
    func size(for sizeId: String) -> FoodSize? {
        first(where: { $0.id == sizeId })
    }

    func containsSize(with sizeId: String) -> Bool {
        contains(where: { $0.id == sizeId })
    }
}

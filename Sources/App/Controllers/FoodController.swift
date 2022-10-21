import Fluent
import Vapor

struct FoodController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let foods = routes.grouped("foods")
        foods.on(.POST, "image", body: .collect(maxSize: "20mb"), use: image)
        foods.get(use: index)
        foods.post(use: create)
        
        //        foods.group(":foodId") { food in
        //            food.delete(use: delete)
        //        }
    }
    
    func image(req: Request) async throws -> String {
        let image = try req.content.decode(Image.self)
        saveImage(image, to: .repository)
        return ""
    }
    
    func create(req: Request) async throws -> Food {
        let food = try req.content.decode(Food.self)
        try await food.save(on: req.db)
        return food
    }
    
    func index(req: Request) async throws -> [Food] {
        try await Food.query(on: req.db)
            .all()
    }
    //
    //
    //    func delete(req: Request) async throws -> HTTPStatus {
    //        guard let food = try await Food.find(req.parameters.get("foodId"), on: req.db) else {
    //            throw Abort(.notFound)
    //        }
    //        try await food.delete(on: req.db)
    //        return .noContent
    //    }
}

struct Image: Content {
    var id: String
    var data: Data
}

enum ImageLocation {
    case holdingArea
    case repository
    
    func directoryPath(for imageId: String) -> String? {
        let path = FileManager.default.currentDirectoryPath
        switch self {
        case .holdingArea:
            return "\(path)/Public/Uploads/tmp"
        case .repository:
            let suffix = imageId.suffix(6)
            guard suffix.count == 6 else { return nil }
            let folder1 = suffix.prefix(3)
            let folder2 = suffix.suffix(3)
            return "\(path)/Public/Uploads/images/\(folder1)/\(folder2)"
        }
    }
    
    func filePath(for imageId: String) -> String? {
        guard let directoryPath = directoryPath(for: imageId) else { return nil }
        return "\(directoryPath)/\(imageId).jpg"
    }
}

func saveImage(_ image: Image, to location: ImageLocation = .holdingArea) {
    guard let filePath = location.filePath(for: image.id),
          let directoryPath = location.directoryPath(for: image.id) else {
        print("Couldn't get paths")
        return
    }
    
    if !FileManager.default.fileExists(atPath: directoryPath) {
        do {
            print("Creating: \(directoryPath)")
            try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error.localizedDescription)");
        }
    }
    
    let result = FileManager.default.createFile(atPath: filePath, contents: image.data, attributes: nil)
    print("saving at \(filePath)")
    print("success: \(result)")
}

extension Data {
    var sizeDescription: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(count))
    }
}

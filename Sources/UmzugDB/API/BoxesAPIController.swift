import Vapor
import Fluent
import FluentPostgresDriver
import Leaf

struct BoxesAPIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get(use: list(request:))
        routes.post(use: create(request:))
        routes.get(":id", use: find(request:))
        routes.patch(":id", use: update(request:))
        routes.delete(":id", use: delete(request:))
    }
    
    @Sendable
    func list(request req: Request) async throws -> some Content {
        // parse list options
        struct QueryOptions: Codable {
            var limit: Int?
        }
        guard let options = try? req.query.decode(QueryOptions.self) else {
            throw APIError.invalidQueryOptions
        }
        
        // prepare list query
        var query = Box.query(on: req.db)
        if let limit = options.limit {
            query = query.limit(limit)
        }
        
        // query and return boxes
        let boxes = try await query.all()
        return boxes.map { $0.toDTO() }
    }
    
    @Sendable
    func create(request req: Request) async throws -> some Content {
        // parse box properties
        struct QueryOptions: Codable {
            var title: String
        }
        guard let options = try? req.query.decode(QueryOptions.self) else {
            throw APIError.invalidQueryOptions
        }
        
        // create box
        let box = Box(title: options.title)
        do {
            try await box.create(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(.boxes(title: box.title))
        }
        
        return box.toDTO()
    }
    
    @Sendable
    func find(request req: Request) async throws -> some Content {
        // get box id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let boxID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // find box and its packings
        guard let box = try await Box.find(boxID, on: req.db) else {
            throw APIError.modelNotFound(boxID)
        }
        try await box.$items.$pivots.load(on: req.db)
        
        return box.toDTO()
    }
    
    @Sendable
    func update(request req: Request) async throws -> some Content {
        // get box id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let boxID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // parse box properties
        struct QueryOptions: Codable {
            var title: String?
        }
        guard let options = try? req.query.decode(QueryOptions.self) else {
            throw APIError.invalidQueryOptions
        }
        
        // find box to update
        guard let box = try await Box.find(boxID, on: req.db) else {
            throw APIError.modelNotFound(boxID)
        }
        
        
        // update box fields
        
        if let title = options.title {
            box.title = title
        }
        
        do {
            try await box.update(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(.boxes(title: box.title))
        }
        
        return box.toDTO()
    }
    
    @Sendable
    func delete(request req: Request) async throws -> some Content {
        // get box id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let boxID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // find and delete box
        guard let box = try await Box.find(boxID, on: req.db) else {
            throw APIError.modelNotFound(boxID)
        }
        try await box.delete(on: req.db)
        
        return box.toDTO()
    }
}

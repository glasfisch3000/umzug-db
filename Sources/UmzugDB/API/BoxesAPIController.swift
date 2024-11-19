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
        struct QueryOptions: Codable {
            var limit: Int?
        }
        
        let options = try req.query.decode(QueryOptions.self)
        
        var query = Box.query(on: req.db)
        
        if let limit = options.limit {
            query = query.limit(limit)
        }
        
        let boxes = try await query.all()
        
        return boxes.map { $0.toDTO() }
    }
    
    @Sendable
    func create(request req: Request) async throws -> some Content {
        struct QueryOptions: Codable {
            var title: String
        }
        
        let options = try req.query.decode(QueryOptions.self)
        
        let box = Box(title: options.title)
        do {
            try await box.create(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(box.title)
        }
        
        return box.toDTO()
    }
    
    @Sendable
    func find(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let boxID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        guard let box = try await Box.find(boxID, on: req.db) else {
            throw APIError.modelNotFound(boxID)
        }
        try await box.$items.$pivots.load(on: req.db)
        
        return box.toDTO()
    }
    
    @Sendable
    func update(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let boxID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        struct QueryOptions: Codable {
            var title: String?
        }
        
        let options = try req.query.decode(QueryOptions.self)
        
        guard let box = try await Box.find(boxID, on: req.db) else {
            throw APIError.modelNotFound(boxID)
        }
        
        if let title = options.title {
            box.title = title
        }
        
        do {
            try await box.update(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(box.title)
        }
        
        return box.toDTO()
    }
    
    @Sendable
    func delete(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let boxID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        guard let box = try await Box.find(boxID, on: req.db) else {
            throw APIError.modelNotFound(boxID)
        }
        try await box.delete(on: req.db)
        
        return box.toDTO()
    }
}

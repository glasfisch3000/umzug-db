import Vapor
import Fluent
import FluentPostgresDriver
import Leaf

struct ItemsAPIController: RouteCollection {
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
        
        var query = Item.query(on: req.db)
        
        if let limit = options.limit {
            query = query.limit(limit)
        }
        
        let items = try await query.all()
        
        return items.map { $0.toDTO() }
    }
    
    @Sendable
    func create(request req: Request) async throws -> some Content {
        struct QueryOptions: Codable {
            var title: String
        }
        
        let options = try req.query.decode(QueryOptions.self)
        
        let item = Item(title: options.title)
        do {
            try await item.create(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(item.title)
        }
        
        return item.toDTO()
    }
    
    @Sendable
    func find(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let itemID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        guard let item = try await Item.find(itemID, on: req.db) else {
            throw APIError.modelNotFound(itemID)
        }
        try await item.$packings.load(on: req.db)
        
        return item.toDTO()
    }
    
    @Sendable
    func update(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let itemID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        struct QueryOptions: Codable {
            var title: String?
        }
        
        let options = try req.query.decode(QueryOptions.self)
        
        guard let item = try await Item.find(itemID, on: req.db) else {
            throw APIError.modelNotFound(itemID)
        }
        
        if let title = options.title {
            item.title = title
        }
        
        do {
            try await item.update(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(item.title)
        }
        
        return item.toDTO()
    }
    
    @Sendable
    func delete(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let itemID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        guard let item = try await Item.find(itemID, on: req.db) else {
            throw APIError.modelNotFound(itemID)
        }
        try await item.delete(on: req.db)
        
        return item.toDTO()
    }
}

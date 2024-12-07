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
        // parse list options
        struct QueryOptions: Codable {
            var limit: Int?
        }
        guard let options = try? req.query.decode(QueryOptions.self) else {
            throw APIError.invalidQueryOptions
        }
        
        // prepare list query
        var query = Item.query(on: req.db)
        if let limit = options.limit {
            query = query.limit(limit)
        }
        
        // query and return items
        let items = try await query.all()
        return items.map { $0.toDTO() }
    }
    
    @Sendable
    func create(request req: Request) async throws -> some Content {
        // parse item properties
        struct QueryOptions: Codable {
            var title: String
            var priority: Priority?
        }
        guard let options = try? req.query.decode(QueryOptions.self) else {
            throw APIError.invalidQueryOptions
        }
        
        // create item
        let item = Item(title: options.title, priority: options.priority)
        do {
            try await item.create(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(.items(title: item.title))
        }
        
        return item.toDTO()
    }
    
    @Sendable
    func find(request req: Request) async throws -> some Content {
        // get item id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let itemID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // find item and its packings
        guard let item = try await Item.find(itemID, on: req.db) else {
            throw APIError.modelNotFound(itemID)
        }
        try await item.$packings.load(on: req.db)
        
        return item.toDTO()
    }
    
    @Sendable
    func update(request req: Request) async throws -> some Content {
        // get item id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let itemID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // parse item properties
        struct QueryOptions: Codable {
            var title: String?
        }
        guard let options = try? req.query.decode(QueryOptions.self) else {
            throw APIError.invalidQueryOptions
        }
        
        // find item to update
        guard let item = try await Item.find(itemID, on: req.db) else {
            throw APIError.modelNotFound(itemID)
        }
        
        // update item fields
        
        if let title = options.title {
            item.title = title
        }
        
        do {
            try await item.update(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(.items(title: item.title))
        }
        
        return item.toDTO()
    }
    
    @Sendable
    func delete(request req: Request) async throws -> some Content {
        // get item id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let itemID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // find and delete item
        guard let item = try await Item.find(itemID, on: req.db) else {
            throw APIError.modelNotFound(itemID)
        }
        try await item.delete(on: req.db)
        
        return item.toDTO()
    }
}

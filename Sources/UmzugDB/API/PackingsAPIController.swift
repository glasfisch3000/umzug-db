import Vapor
import Fluent
import FluentPostgresDriver
import Leaf

struct PackingsAPIController: RouteCollection {
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
        var query = Packing.query(on: req.db)
            .with(\.$item)
            .with(\.$box)
        if let limit = options.limit {
            query = query.limit(limit)
        }
        
        // list and return packings
        let packings = try await query.all()
        return packings.map { $0.toDTO() }
    }
    
    @Sendable
    func create(request req: Request) async throws -> some Content {
        // parse packing properties
        struct QueryOptions: Codable {
            var itemID: UUID
            var boxID: UUID
            var amount: Int
        }
        guard let options = try? req.query.decode(QueryOptions.self) else {
            throw APIError.invalidQueryOptions
        }
        
        // create packing
        let packing = Packing(itemID: options.itemID, boxID: options.boxID, amount: options.amount)
        do {
            try await packing.create(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(.packing(item: packing.$item.id, box: packing.$box.id))
        }
        
        return packing.toDTO()
    }
    
    @Sendable
    func find(request req: Request) async throws -> some Content {
        // get packing id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let packingID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // load packing + item and box
        guard let packing = try await Packing.find(packingID, on: req.db) else {
            throw APIError.modelNotFound(packingID)
        }
        try await packing.$item.load(on: req.db)
        try await packing.$box.load(on: req.db)
        
        return packing.toDTO()
    }
    
    @Sendable
    func update(request req: Request) async throws -> some Content {
        // get packing id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let packingID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // parse packing properties
        struct QueryOptions: Codable {
            var itemID: UUID?
            var boxID: UUID?
            var amount: Int?
        }
        guard let options = try? req.query.decode(QueryOptions.self) else {
            throw APIError.invalidQueryOptions
        }
        
        // find packing to update
        guard let packing = try await Packing.find(packingID, on: req.db) else {
            throw APIError.modelNotFound(packingID)
        }
        
        // update packing's fields
        
        if let itemID = options.itemID {
            packing.$item.id = itemID
        }
        
        if let boxID = options.boxID {
            packing.$box.id = boxID
        }
        
        if let amount = options.amount {
            packing.amount = amount
        }
        
        do {
            try await packing.update(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.uniqueConstraintViolation(.packing(item: packing.$item.id,
                                                              box: packing.$box.id))
        }
        
        return packing.toDTO()
    }
    
    @Sendable
    func delete(request req: Request) async throws -> some Content {
        // get packing id
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        guard let packingID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        // find and delete packing
        guard let packing = try await Packing.find(packingID, on: req.db) else {
            throw APIError.modelNotFound(packingID)
        }
        try await packing.delete(on: req.db)
        
        return packing.toDTO()
    }
}

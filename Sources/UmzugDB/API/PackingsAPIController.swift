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
        struct QueryOptions: Codable {
            var limit: Int?
        }
        
        let options = try req.query.decode(QueryOptions.self)
        
        var query = Packing.query(on: req.db)
            .with(\.$item)
            .with(\.$box)
        
        if let limit = options.limit {
            query = query.limit(limit)
        }
        
        let packings = try await query.all()
        
        return packings.map { $0.toDTO() }
    }
    
    @Sendable
    func create(request req: Request) async throws -> some Content {
        struct QueryOptions: Codable {
            var itemID: UUID
            var boxID: UUID
            var amount: Int
        }
        
        let options = try req.query.decode(QueryOptions.self)
        
        let packing = Packing(itemID: options.itemID, boxID: options.boxID, amount: options.amount)
        do {
            try await packing.create(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            struct ConstraintViolation: Encodable {
                var itemID: UUID
                var boxID: UUID
            }
            throw APIError.uniqueConstraintViolation(ConstraintViolation(itemID: packing.$item.id,
                                                                         boxID: packing.$box.id))
        }
        
        return packing.toDTO()
    }
    
    @Sendable
    func find(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let packingID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        guard let packing = try await Packing.find(packingID, on: req.db) else {
            throw APIError.modelNotFound(packingID)
        }
        try await packing.$item.load(on: req.db)
        try await packing.$box.load(on: req.db)
        
        return packing.toDTO()
    }
    
    @Sendable
    func update(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let packingID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        struct QueryOptions: Codable {
            var itemID: UUID?
            var boxID: UUID?
            var amount: Int?
        }
        
        let options = try req.query.decode(QueryOptions.self)
        
        guard let packing = try await Packing.find(packingID, on: req.db) else {
            throw APIError.modelNotFound(packingID)
        }
        
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
            struct ConstraintViolation: Encodable {
                var itemID: UUID
                var boxID: UUID
            }
            throw APIError.uniqueConstraintViolation(ConstraintViolation(itemID: packing.$item.id,
                                                                         boxID: packing.$box.id))
        }
        
        return packing.toDTO()
    }
    
    @Sendable
    func delete(request req: Request) async throws -> some Content {
        guard let idString = req.parameters.get("id") else {
            throw APIError.missingID
        }
        
        guard let packingID = UUID(idString) else {
            throw APIError.invalidUUID(idString)
        }
        
        guard let packing = try await Packing.find(packingID, on: req.db) else {
            throw APIError.modelNotFound(packingID)
        }
        try await packing.delete(on: req.db)
        
        return packing.toDTO()
    }
}

import Fluent

struct CreatePriority: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let priority = try await database.enum("priority")
            .case("immediate")
            .case("standard")
            .case("convenience")
            .case("long_term")
            .create()
        
        try await database.schema("items")
            .field("priority", priority)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("items")
            .deleteField("priority")
            .update()
        
        try await database.enum("priority").delete()
    }
}

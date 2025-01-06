import Fluent

struct SimplifyPriority: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let priority = try await database.enum("priority")
            .deleteCase("convenience")
            .update()
        
        try await database.schema("items")
            .deleteField("priority")
            .field("priority", priority, .required)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        let priority = try await database.enum("priority")
            .case("convenience")
            .update()
        
        try await database.schema("items")
            .deleteField("priority")
            .field("priority", priority)
            .update()
    }
}

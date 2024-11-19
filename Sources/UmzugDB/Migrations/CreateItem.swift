import Fluent

struct CreateItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("items")
            .id()
            .field("title", .string, .required)
            .unique(on: "title")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("items").delete()
    }
}

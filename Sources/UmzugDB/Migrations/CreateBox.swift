import Fluent

struct CreateBox: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("boxes")
            .id()
            .field("title", .string, .required)
            .unique(on: "title")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("boxes").delete()
    }
}

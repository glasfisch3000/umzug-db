import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .unique(on: "user")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
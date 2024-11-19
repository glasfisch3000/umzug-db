import Fluent

struct CreatePacking: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("packings")
            .id()
            .field("item", .uuid, .required, .references("items", "id"))
            .field("box", .uuid, .required, .references("boxes", "id"))
            .field("amount", .int, .required)
            .unique(on: "item", "box", name: "item+box")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("packings").delete()
    }
}

import Fluent

struct CreateLayout: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Layout.schema)
            .id()
            .field("layout", .array(of: .string), .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .unique(on: "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Layout.schema).delete()
    }
}

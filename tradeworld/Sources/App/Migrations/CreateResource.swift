import Fluent

struct RecreateResource: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Resource.schema).delete()
        try await database.schema(Resource.schema)
            .id()
            .field("wood", .int, .required)
            .field("stone", .int, .required)
            .field("gold", .int, .required)
            .field("iron", .int, .required)
            .field("food", .int, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}

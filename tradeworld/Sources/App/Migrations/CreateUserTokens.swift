import Fluent
struct CreateUserTokens: AsyncMigration {
    var name: String { "CreateUserTokens" }

    func prepare(on database: Database) async throws {
        try await database.schema("user_token")
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .required, .references("user", "id"))
            .unique(on: "value")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_token").delete()
    }
}
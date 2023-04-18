import Vapor
import Fluent

struct CreateTrophy: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Trophy.schema)
            .id()
            .field("trophy_id", .int, .required)
            .field("data", .dictionary, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Trophy.schema).delete()
    }
}
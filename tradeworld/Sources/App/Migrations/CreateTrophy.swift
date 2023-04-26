import Vapor
import Fluent
import FluentSQL

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

struct AddTimestampToTrophy: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Trophy.schema)
            .field("award_date", .datetime, .required, .sql(.default(SQLRaw("CURRENT_TIMESTAMP"))))
            .field("tier", .int, .required)
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Trophy.schema)
            .deleteField("award_date")
            .deleteField("tier")
            .update()
    }
}

import Vapor
import Fluent

struct CreateNewsPost: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(NewsPost.schema)
            .id()
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("timestamp", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(NewsPost.schema).delete()
    }
}
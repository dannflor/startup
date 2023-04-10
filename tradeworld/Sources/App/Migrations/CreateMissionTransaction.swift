import Vapor
import Fluent

struct CreateMissionTransaction: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(MissionTransaction.schema)
            .id()
            .field("contrib_id", .uuid, .required, .references("user", "id"))
            .field("created_at", .datetime, .required)
            .field("contrib_amount", .int, .required)
            .field("contrib_resource", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(MissionTransaction.schema).delete()
    }
}

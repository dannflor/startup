import Fluent
import FluentSQL

struct CreateTrade: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Trade.schema)
            .id()
            .field("seller", .string, .required)
            .field("message", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Trade.schema).delete()
    }
}

struct CreateOffer: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Offer.schema)
            .id()
            .field("name", .string, .required)
            .field("count", .int, .required)
            .field("trade_id", .uuid, .required, .references(Trade.schema, "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Offer.schema).delete()
    }
}

struct CreateAsk: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Ask.schema)
            .id()
            .field("name", .string, .required)
            .field("count", .int, .required)
            .field("trade_id", .uuid, .required, .references(Trade.schema, "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Ask.schema).delete()
    }
}

struct AddTimestampToTrade: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Trade.schema)
            .field("created_at", .datetime, .required, .sql(.default(SQLRaw("CURRENT_TIMESTAMP"))))
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Trade.schema)
            .deleteField("created_at")
            .update()
    }
}

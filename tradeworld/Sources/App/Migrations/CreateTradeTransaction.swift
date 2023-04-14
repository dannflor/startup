import Vapor
import Fluent
struct CreateTradeTransaction: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(TradeTransaction.schema)
            .id()
            .field("seller_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("buyer_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("created_at", .datetime, .required)
            .field("offer_amount", .int, .required)
            .field("offer_resource", .string, .required)
            .field("ask_amount", .int, .required)
            .field("ask_resource", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(TradeTransaction.schema).delete()
    }
}

import Vapor
import Fluent
import FluentSQL

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("username", .string, .required)
            .field("password", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}

struct AddScoreToUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .field("score", .int, .required, .sql(.default(0)))
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema).deleteField("score").update()
    }
}

struct CreateResource: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Resource.schema)
            .id()
            .field("name", .string, .required)
            .field("count", .int, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Resource.schema).delete()
    }
}

struct AddTechToUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .field("techs", .array(of: .int), .required, .sql(raw: "DEFAULT ARRAY[]::integer[]"))
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema)
            .deleteField("techs")
            .update()
    }
}

struct AddTimestampToUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .field("visit_time", .datetime, .required, .sql(.default(SQLRaw("CURRENT_TIMESTAMP"))))
            .update()
    }
    func revert(on database: Database) async throws {
        try await database.schema(User.schema)
            .deleteField("visit_time")
            .update()
    }
}

import Fluent

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
            .field("score", .string, .required)
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

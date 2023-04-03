import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    let file = FileMiddleware(publicDirectory: app.directory.publicDirectory)
    app.middleware.use(file)
    app.databases.use(try! .postgres(url: Environment.get("DATABASE_URL")!), as: .psql)
    
    app.sessions.use(.fluent(.psql))
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())
    
    app.migrations.add(CreateUser(), CreateResource(), AddScoreToUser(), SessionRecord.migration, CreateLayout(), RecreateResource(), AddTechToUser(), AddTimestampToUser(), CreateTrade(), CreateAsk(), CreateOffer())

    app.views.use(.leaf)

    // register routes
    try routes(app)
}

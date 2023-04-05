import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import NIOSSL

// configures your application
public func configure(_ app: Application) throws {
    let file = FileMiddleware(publicDirectory: app.directory.publicDirectory)
    app.middleware.use(file)
    app.databases.use(try! .postgres(url: Environment.get("DATABASE_URL")!), as: .psql)
    
    app.sessions.use(.fluent(.psql))
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())
    
    app.migrations.add(CreateUser(), CreateResource(), AddScoreToUser(), SessionRecord.migration, 
        CreateLayout(), RecreateResource(), AddTechToUser(), AddTimestampToUser(), CreateTrade(), 
        CreateAsk(), CreateOffer(), AddTimestampToTrade())

    app.views.use(.leaf)
    // app.http.server.configuration.tlsConfiguration = .makeServerConfiguration(
    //     certificateChain: try NIOSSLCertificate.fromPEMFile(app.directory.resourcesDirectory + "cert/signed_certificate.pem").map { .certificate($0) },
    //     privateKey: .file(app.directory.resourcesDirectory + "cert/private_key.pem")
    // )
    app.tradeConnectionManager.client = .init(app: app)

    // register routes
    try routes(app)
}

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
//    app.http.server.configuration.tlsConfiguration = .makeServerConfiguration(
//        certificateChain: try NIOSSLCertificate.fromPEMFile(app.directory.resourcesDirectory + "cert/signed_certificate.pem").map { .certificate($0) },
//        privateKey: .file(app.directory.resourcesDirectory + "cert/private_key.pem")
//    )
    app.tradeConnectionManager.client = .init(app: app)

    // register routes
    try routes(app)
}

public extension Application {
    var tradeConnectionManager: TradeWebsocket {
        .init(app: self)
    }
    struct TradeWebsocket {
        struct ClientKey: StorageKey {
            typealias Value = TradeConnectionManager
        }

        public var client: TradeConnectionManager {
            get {
                self.app.storage[ClientKey.self] ?? .init(app: self.app)
            }
            nonmutating set {
                self.app.storage.set(ClientKey.self, to: newValue)
            }
        }
        let app: Application
    }
}

public extension Request {
    var tradeConnectionManager: TradeWebsocket {
        .init(request: self)
    }

    struct TradeWebsocket {
        var client: TradeConnectionManager {
            request.application.tradeConnectionManager.client
        }
        let request: Request
    }

}

public final class TradeConnectionManager {
    let db: Database
    let eventLoop: EventLoop
    var connections: [UUID: WebSocket] = [:]

    init(app: Application) {
        self.eventLoop = app.eventLoopGroup.next()
        self.db = app.db
    }

    func connect(_ ws: WebSocket) {
        ws.onText { ws, text async in
            print(text)
        }
        
        ws.onBinary { [unowned self] ws, buffer in
            print(buffer)
            if let msg = buffer.decodeWebsocketMessage(Connect.self) {
                self.connections[msg.client] = ws
                print("Connected: \(msg.client)")
                do {
                    let trades = try await Trade.query(on: db).all()
                    var tradeResponses: [TradeResponse] = []
                    for trade in trades {
                        try await tradeResponses.append(TradeResponse(trade, db))
                    }
                    let tradeSocketResponse = TradeSocketResponse(type: .addTrades, trades: tradeResponses)
                    try await ws.send([UInt8](JSONEncoder().encode(tradeSocketResponse)))
                }
                catch {
                    print(error)
                }
            }
            else if let msg = buffer.decodeWebsocketMessage(TradeSocketRequest.self) {
                do {
                    switch msg.data.type {
                    case .addTrade:
                        let trade = Trade(seller: msg.data.trade.seller, message: msg.data.trade.message)
                        try await trade.create(on: db)
                        try await trade.$offer.create(Offer(name: msg.data.trade.offer.name, count: msg.data.trade.offer.count, tradeId: trade.requireID()), on: db)
                        try await trade.$ask.create(Ask(name: msg.data.trade.ask.name, count: msg.data.trade.ask.count, tradeId: trade.requireID()), on: db)
                        let tradeResponse = try await TradeResponse(trade, db)
                        let tradeSocketResponse = TradeSocketResponse(type: .addTrades, trades: [tradeResponse])
                        try await ws.send([UInt8](JSONEncoder().encode(tradeSocketResponse)))
                    case .acceptTrade:
                        guard let trade = try await Trade.find(msg.data.trade.id, on: db) else {
                            throw Abort(.badRequest)
                        }
                        if let offer = try await trade.$offer.get(on: db) {
                            try await offer.delete(on: db)
                        }
                        if let ask = try await trade.$ask.get(on: db) {
                            try await ask.delete(on: db)
                        }
                        try await trade.delete(on: db)
                        // let tradeSocketResponse = TradeSocketResponse(type: .acceptTrade, trades: [tradeSocketRequest.trade])
                        // try await ws.send(String(decoding: JSONEncoder().encode(tradeSocketResponse), as: UTF8.self))
                    }
                }
                catch {
                    print(error)
                }
                
            }

        }
    }

    struct Connect: Codable {
        let connect: Bool
    }
}

struct WebsocketMessage<T: Codable>: Codable {
    let client: UUID
    let data: T
}

extension ByteBuffer {
    func decodeWebsocketMessage<T: Codable>(_ type: T.Type) -> WebsocketMessage<T>? {
        try? JSONDecoder().decode(WebsocketMessage<T>.self, from: self)
    }
}

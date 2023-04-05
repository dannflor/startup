import Vapor
import Fluent

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
        ws.pingInterval = .seconds(10)
        ws.onText { ws, text async in
            print(text)
        }
        
        ws.onBinary { [unowned self] ws, buffer in
            // decode binary to string
//            let string = String(decoding: buffer, as: UTF8.self)
//            print(string)
            print("Receiving binary")
            if let msg = buffer.decodeWebsocketMessage(Connect.self) {
                self.connections[msg.client] = ws
                do {
                    let trades = try await Trade.query(on: db).all()
                    var tradeResponses: [TradeResponse] = []
                    for trade in trades {
                        try await tradeResponses.append(TradeResponse(trade, db))
                    }
                    let tradeSocketResponse = TradeSocketResponse(type: .addTrades, trades: tradeResponses)
                    // Send response to every client in the dictionary
                    for (_, ws) in self.connections {
                        try await ws.send([UInt8](JSONEncoder().encode(tradeSocketResponse)))
                    }
                }
                catch {
                    print(error)
                }
            }
            else if let msg = buffer.decodeWebsocketMessage(TradeSocketRequest.self) {
                do {
                    switch msg.data.type {
                    case .addTrade:
                        print("Adding trade")
                        let trade = Trade(seller: msg.data.trade.seller, message: msg.data.trade.message)
                        try await trade.create(on: db)
                        try await trade.$offer.create(Offer(name: msg.data.trade.offer.name, count: msg.data.trade.offer.count, tradeId: trade.requireID()), on: db)
                        try await trade.$ask.create(Ask(name: msg.data.trade.ask.name, count: msg.data.trade.ask.count, tradeId: trade.requireID()), on: db)
                        let tradeResponse = try await TradeResponse(trade, db)
                        let tradeSocketResponse = TradeSocketResponse(type: .addTrades, trades: [tradeResponse])
                        for (_, ws) in self.connections {
                            try await ws.send([UInt8](JSONEncoder().encode(tradeSocketResponse)))
                        }
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
                        let tradeResponse = try await TradeResponse(trade, db)
                        try await trade.delete(on: db)
                        let tradeSocketResponse = TradeSocketResponse(type: .removeTrades, trades: [tradeResponse])
                        for (_, ws) in self.connections {
                            try await ws.send([UInt8](JSONEncoder().encode(tradeSocketResponse)))
                        }
                    }
                }
                catch {
                    print(error)
                }
                
            }

        }

        ws.onClose.whenComplete { [unowned self] _ in
            for (key, value) in self.connections {
                if value === ws {
                    self.connections.removeValue(forKey: key)
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

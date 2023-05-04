import Vapor

final class HeaderMiddleware: AsyncMiddleware {
    private let publicDirectory: String

    init(publicDirectory: String) {
        self.publicDirectory = publicDirectory.addTrailingSlash()
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let path = request.url.path.removingPercentEncoding?.removeLeadingSlashes() else {
            throw Abort(.badRequest)
        }
        // protect against relative paths
        guard !path.contains("../") else {
            throw Abort(.forbidden)
        }
        print(path)
        guard FileManager.default.fileExists(atPath: publicDirectory + path) else {
            return try await next.respond(to: request)
        }
        let response = try await next.respond(to: request)
        response.headers.add(name: "Cross-Origin-Opener-Policy", value: "same-origin")
        response.headers.add(name: "Cross-Origin-Embedder-Policy", value: "require-corp")
        response.headers.add(name: "Cross-Origin-Resource-Policy", value: "cross-origin")
        return response
    }
}

fileprivate extension String {
    /// Determines if input path is absolute based on a leading slash
    func isAbsolute() -> Bool {
        return self.hasPrefix("/")
    }

    /// Makes a path relative by removing all leading slashes
    func removeLeadingSlashes() -> String {
        var newPath = self
        while newPath.hasPrefix("/") {
            newPath.removeFirst()
        }
        return newPath
    }

    /// Adds a trailing slash to the path if one is not already present
    func addTrailingSlash() -> String {
        var newPath = self
        if !newPath.hasSuffix("/") {
            newPath += "/"
        }
        return newPath
    }
}

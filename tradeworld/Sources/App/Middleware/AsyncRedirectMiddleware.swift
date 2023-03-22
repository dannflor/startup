import Vapor

extension Authenticatable {
    /// Basic middleware to redirect unauthenticated requests to the supplied path
    ///
    /// - parameters:
    ///    - path: The path to redirect to if the request is not authenticated
    public static func redirectMiddlewareAsync(path: String) -> AsyncMiddleware {
        self.redirectMiddlewareAsync(makePath: { _ in path })
    }
    
    /// Basic middleware to redirect unauthenticated requests to the supplied path
    ///
    /// - parameters:
    ///    - makePath: The closure that returns the redirect path based on the given `Request` object
    public static func redirectMiddlewareAsync(makePath: @escaping (Request) -> String) -> AsyncMiddleware {
        AsyncRedirectMiddleware<Self>(Self.self, makePath: makePath)
    }
}


private final class AsyncRedirectMiddleware<A>: AsyncMiddleware
    where A: Authenticatable
{
    let makePath: (Request) -> String
    
    init(_ authenticatableType: A.Type = A.self, makePath: @escaping (Request) -> String) {
        self.makePath = makePath
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        if request.auth.has(A.self) {
            return try await next.respond(to: request)
        }

        let redirect = request.redirect(to: self.makePath(request))
        return redirect
    }
}
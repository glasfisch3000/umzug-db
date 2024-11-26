import Vapor

struct ErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let error as APIError {
            return Response(status: .ok, body: Response.Body(data: try JSONEncoder().encode(["error": error])))
        }
    }
}

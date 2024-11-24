import Vapor
import Fluent

extension User: Authenticatable { }

struct UserBasicAuthenticator: AsyncBasicAuthenticator {
    func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        guard let user = try await User.query(on: request.db)
            .filter(\.$name == basic.username)
            .first() else {
            throw APIError.invalidAuthentication
        }
        
        guard user.password == User.hashPassword(basic.password, salt: user.salt) else {
            throw APIError.invalidAuthentication
        }
        
        request.auth.login(user)
    }
}

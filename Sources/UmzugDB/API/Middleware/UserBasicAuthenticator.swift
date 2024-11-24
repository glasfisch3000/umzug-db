import Vapor
import Fluent

extension User: Authenticatable { }

struct UserBasicAuthenticator: AsyncBasicAuthenticator {
    func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        guard let user = try await User.query(on: request.db)
            .filter(\.$name == basic.username)
            .first() else {
            return
        }
        
        guard user.password == User.hashPassword(basic.password, salt: user.salt) else {
            return
        }
        
        request.auth.login(user)
    }
}

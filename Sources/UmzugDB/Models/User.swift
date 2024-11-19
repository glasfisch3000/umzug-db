import Fluent
import Vapor
import Crypto

final class User: Model, Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "password")
    var password: Data
    
    @Field(key: "salt")
    var salt: UUID

    init() { }

    init(id: UUID? = nil, name: String, password: String) {
        self.id = id
        self.name = name
        self.salt = .generateRandom()
        self.password = Data(Self.hashPassword(password, salt: self.salt))
    }
    
    func toDTO() -> DTO {
        DTO(id: self.$id.value,
            name: self.name,
            password: self.password,
            salt: self.salt)
    }
    
    static func hashPassword(_ string: String, salt: UUID) -> SHA256.Digest {
        var hasher = SHA256()
        hasher.update(data: Data(string.utf8))
        hasher.update(data: Data(salt.uuidString.utf8))
        return hasher.finalize()
    }
}

extension User {
    struct DTO: Codable, Content {
        var id: UUID?
        var name: String
        var password: Data?
        var salt: UUID?
    }
}

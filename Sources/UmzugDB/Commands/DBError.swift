enum DBError: Error, Codable, CustomStringConvertible {
    case userNotFound(User.IDValue)
    
    var description: String {
        switch self {
        case .userNotFound(let id): "User not found for id \(id)"
        }
    }
}

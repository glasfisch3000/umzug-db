enum DBError: Error, Codable, CustomStringConvertible {
    case userNotFound(User.IDValue)
    case boxNotFound(Box.IDValue)
    case itemNotFound(Item.IDValue)
    
    var description: String {
        switch self {
        case .userNotFound(let id): "User not found for id \(id)"
        case .boxNotFound(let id): "Box not found for id \(id)"
        case .itemNotFound(let id): "Item not found for id \(id)"
        }
    }
}

import struct Foundation.UUID

enum DBError: Error, Codable, CustomStringConvertible {
    case modelNotFound(Self.ModelNotFound)
    case uniqueConstraintViolation(Self.UniqueConstraintViolation)
    
    var description: String {
        switch self {
        case .modelNotFound(let error): error.description
        case .uniqueConstraintViolation(let error): error.description
        }
    }
}

extension DBError {
    enum ModelNotFound: Codable, CustomStringConvertible {
        case users(User.IDValue)
        case boxes(Box.IDValue)
        case items(Item.IDValue)
        
        var description: String {
            switch self {
            case .users(let id): "User not found for id: \(id)"
            case .boxes(let id): "Box not found for id: \(id)"
            case .items(let id): "Item not found for id: \(id)"
            }
        }
    }
}

extension DBError {
    enum UniqueConstraintViolation: Codable, CustomStringConvertible {
        case users(name: String)
        case boxes(title: String)
        case items(title: String)
        
        var description: String {
            switch self {
            case .users(name: let name): "Violation of user's name uniqueness constraint"
            case .boxes(title: let title): "Violation of box's title uniqueness constraint"
            case .items(title: let title): "Violation of item's title uniqueness constraint"
            }
        }
    }
}

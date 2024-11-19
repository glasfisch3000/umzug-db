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
        case user(User.IDValue)
        case box(Box.IDValue)
        case box_title(String)
        case item(Item.IDValue)
        case item_title(String)
        case packing_parents(item: Item.IDValue, box: Box.IDValue)
        
        var description: String {
            switch self {
            case .user(let id): "User not found for id: \(id)"
            case .box(let id): "Box not found for id: \(id)"
            case .box_title(let title): "Box not found for title: \"\(title)\""
            case .item(let id): "Item not found for id: \(id)"
            case .item_title(let title): "Item not found for title: \"\(title)\""
            case .packing_parents(item: let item, box: let box): "Packing not found for itemID: \(item), boxID: \(box)"
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
            case .users(name: let name): "Violation of user's name uniqueness constraint: \"\(name)\""
            case .boxes(title: let title): "Violation of box's title uniqueness constraint: \"\(title)\""
            case .items(title: let title): "Violation of item's title uniqueness constraint: \"\(title)\""
            }
        }
    }
}

import struct Foundation.UUID

enum DBError: Error, Codable, CustomStringConvertible {
    case modelNotFound(Self.ModelNotFound)
    case constraintViolation(Self.ConstraintViolation)
    
    var description: String {
        switch self {
        case .modelNotFound(let error): error.description
        case .constraintViolation(let error): error.description
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
    enum ConstraintViolation: Codable, CustomStringConvertible {
        case user_unique(name: String)
        case box_unique(title: String)
        case item_unique(title: String)
        case packing_unique(item: Item.IDValue, box: Box.IDValue)
        case packing_nonzero(amount: Int)
        
        var description: String {
            switch self {
            case .user_unique(name: let name): "Violation of user's name uniqueness constraint: \"\(name)\""
            case .box_unique(title: let title): "Violation of box's title uniqueness constraint: \"\(title)\""
            case .item_unique(title: let title): "Violation of item's title uniqueness constraint: \"\(title)\""
            case .packing_unique(item: let item, box: let box): "Violation of packing's item+box uniqueness constraint: item \(item), box \(box)"
            case .packing_nonzero(amount: let amount): "Violation of packing's positive-nonzero amount constraint: \"\(amount)\""
            }
        }
    }
}

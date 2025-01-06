import Fluent
import Vapor
import Crypto

final class Item: Model, Sendable {
    static let schema = "items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Enum(key: "priority")
    var priority: Priority
    
    @Children(for: \Packing.$item)
    var packings: [Packing]
    
    init() { }

    init(id: UUID? = nil, title: String, priority: Priority) {
        self.id = id
        self.title = title
        self.priority = priority
    }
    
    func toDTO() -> DTO {
        DTO(id: self.$id.value,
            title: self.title,
            priority: self.priority,
            packings: self.$packings.value?.map { $0.toDTO() })
    }
}

extension Item {
    struct DTO: Codable, Content {
        var id: UUID?
        var title: String
        var priority: Priority
        var packings: [Packing.DTO]?
    }
}

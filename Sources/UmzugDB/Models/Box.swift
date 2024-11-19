import Fluent
import Vapor
import Crypto

final class Box: Model, Sendable {
    static let schema = "boxes"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    @Siblings(through: Packing.self, from: \.$box, to: \.$item)
    var items: [Item]

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
    
    func toDTO() -> DTO {
        DTO(id: self.$id.value,
            title: self.title,
            packings: self.$items.$pivots.value?.map { $0.toDTO() })
    }
}

extension Box {
    struct DTO: Codable, Content {
        var id: UUID?
        var title: String
        var packings: [Packing.DTO]?
    }
}

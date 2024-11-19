import Fluent
import Foundation
import Crypto

final class Item: Model, Sendable {
    static let schema = "items"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
    
    func toDTO() -> DTO {
        DTO(id: self.$id.value,
            title: self.title)
    }
}

extension Item {
    struct DTO: Codable {
        var id: UUID?
        var title: String
    }
}

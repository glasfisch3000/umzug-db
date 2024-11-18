import Fluent
import Foundation
import Crypto

final class Item: Model, Sendable {
    static let schema = "items"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    @Parent(key: "box")
    var box: Box

    init() { }

    init(id: UUID? = nil, title: String, boxID: Box.IDValue) {
        self.id = id
        self.title = title
        self.$box.id = boxID
    }
    
    func toDTO() -> DTO {
        DTO(id: self.$id.value,
            title: self.title,
            box: self.$box.value?.toDTO())
    }
}

extension Item {
    struct DTO: Codable {
        var id: UUID?
        var title: String
        var box: Box.DTO?
    }
}

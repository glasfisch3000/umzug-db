import Fluent
import Foundation
import Crypto

final class Box: Model, Sendable {
    static let schema = "boxes"
    
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

extension Box {
    struct DTO: Codable {
        var id: UUID?
        var title: String
    }
}

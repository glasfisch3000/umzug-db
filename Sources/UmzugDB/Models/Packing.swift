import Fluent
import Foundation
import Crypto

final class Packing: Model, Sendable {
    static let schema = "packings"
    
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "item")
    var item: Item
    
    @Parent(key: "box")
    var box: Box
    
    @Field(key: "amount")
    var amount: Int

    init() { }

    init(id: UUID? = nil, itemID: Item.IDValue, boxID: Box.IDValue, amount: Int) {
        self.id = id
        self.$item.id = itemID
        self.$box.id = boxID
        self.amount = amount
    }
    
    func toDTO() -> DTO {
        DTO(id: self.$id.value,
            item: self.$item.value?.toDTO(),
            box: self.$box.value?.toDTO(),
            amount: self.amount)
    }
}

extension Packing {
    struct DTO: Codable {
        var id: UUID?
        var item: Item.DTO?
        var box: Box.DTO?
        var amount: Int
    }
}

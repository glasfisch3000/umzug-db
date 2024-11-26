import Vapor
import Fluent
import Leaf

struct APIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let routes = routes.grouped(ErrorMiddleware())
        
        try routes.grouped("boxes").register(collection: BoxesAPIController())
        try routes.grouped("items").register(collection: ItemsAPIController())
        try routes.grouped("packings").register(collection: PackingsAPIController())
    }
}

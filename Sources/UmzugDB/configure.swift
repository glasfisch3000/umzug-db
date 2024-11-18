import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

public func configureDB(_ app: Application, _ config: AppConfig) async throws {
    app.databases.use(
        .postgres(configuration: .init(
            hostname: config.database.host,
            port: Int(config.database.port),
            username: config.database.user,
            password: config.database.password,
            database: config.database.database
        )), as: .psql
    )
    
    // TODO: migrations
}

func configureRoutes(_ app: Application) throws {
    app.views.use(.leaf)
    
    let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory, advancedETagComparison: true)
    app.middleware.use(fileMiddleware)
    
    // TODO: web content controllers
}

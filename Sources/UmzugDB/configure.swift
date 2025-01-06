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
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateBox())
    app.migrations.add(CreateItem())
    app.migrations.add(CreatePacking())
    app.migrations.add(CreatePriority())
    app.migrations.add(SimplifyPriority())
}

func configureRoutes(_ app: Application) throws {
    let protected = app
        .grouped("api")
        .grouped(ErrorMiddleware())
        .grouped(UserBasicAuthenticator())
        .grouped(User.guardMiddleware(throwing: APIError.invalidAuthentication))
    
    try protected.register(collection: APIController())
}

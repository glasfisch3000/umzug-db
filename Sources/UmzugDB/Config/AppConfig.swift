import Vapor

public struct AppConfig: Sendable, Codable {
    public struct PostgresDBLocation: Sendable, Codable {
        var host: String
        var port: UInt16
        var user: String
        var password: String
        var database: String
    }
    
    var environment: ParsableEnvironment = .development
    var database: PostgresDBLocation
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.environment = try container.decodeIfPresent(ParsableEnvironment.self, forKey: .environment) ?? .development
        self.database = try container.decode(PostgresDBLocation.self, forKey: .database)
    }
}

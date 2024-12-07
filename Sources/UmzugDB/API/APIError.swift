import Vapor

enum APIError: Error, Encodable {
    case invalidAuthentication
    case invalidQueryOptions
    case missingID
    case invalidUUID(String)
    case modelNotFound(UUID)
    case uniqueConstraintViolation(DBError.UniqueConstraintViolation)
    case other
    
    enum InvalidUUIDCodingKeys: String, CodingKey {
        case _0 = "uuid"
    }
    
    enum ModelNotFoundCodingKeys: String, CodingKey {
        case _0 = "modelID"
    }
    
    enum UniqueConstraintViolationCodingKeys: String, CodingKey {
        case _0 = "constraint"
    }
}

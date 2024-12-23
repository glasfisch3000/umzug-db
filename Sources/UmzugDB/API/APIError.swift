import Vapor

enum APIError: Error, Encodable {
    case invalidAuthentication
    case invalidQueryOptions
    case missingID
    case invalidUUID(String)
    case modelNotFound(UUID)
    case constraintViolation(DBError.ConstraintViolation)
    case other
    
    enum InvalidUUIDCodingKeys: String, CodingKey {
        case _0 = "uuid"
    }
    
    enum ModelNotFoundCodingKeys: String, CodingKey {
        case _0 = "modelID"
    }
    
    enum ConstraintViolationCodingKeys: String, CodingKey {
        case _0 = "constraint"
    }
}

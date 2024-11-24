import Vapor

enum APIError: Error {
    case invalidAuthentication
    case missingID
    case invalidUUID(String)
    case modelNotFound(UUID)
    case uniqueConstraintViolation(any Encodable & Sendable)
}

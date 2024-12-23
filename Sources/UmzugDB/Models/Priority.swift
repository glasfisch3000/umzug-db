import Vapor
import ArgumentParser

enum Priority: String, Codable, Content, ExpressibleByArgument {
    case immediate = "immediate"
    case standard = "standard"
    case longTerm = "long_term"
}

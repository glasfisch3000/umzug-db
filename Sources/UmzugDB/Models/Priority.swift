import Vapor
import ArgumentParser

enum Priority: String, Codable, Content, ExpressibleByArgument {
    case immediate = "immediate"
    case standard = "standard"
    case convenience = "convenience"
    case longTerm = "long_term"
}

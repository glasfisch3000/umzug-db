import ArgumentParser
import Foundation
import Yams

enum OutputFormat: String, Sendable, Hashable, Codable, ExpressibleByArgument {
    case json
    case yaml
}

struct StringEncodingError: Error, CustomStringConvertible {
    init() { }
    
    var description: String {
        "Custom string encoding failed."
    }
}

extension OutputFormat {
    func format<E: Encodable>(_ e: E) throws -> String {
        switch self {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(e)
            guard let string = String(data: data, encoding: .utf8) else {
                throw StringEncodingError()
            }
            
            return string
        case .yaml:
            let encoder = YAMLEncoder()
            encoder.options.indent = 2
            encoder.options.sortKeys = true
            encoder.options.width = -1
            encoder.options.sequenceStyle = .block
            
            return try encoder.encode(e)
        }
    }
}

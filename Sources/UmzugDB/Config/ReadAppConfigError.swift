import NIOFileSystem
import ArgumentParser
import Yams

public func readAppConfig(path: FilePath?) async throws -> AppConfig {
    let filePath = if let path = path {
        path
    } else {
        try await FileSystem.shared.currentWorkingDirectory.appending("umzugdb-config.yaml")
    }
    
    guard let size = try await FileSystem.shared.info(forFileAt: filePath)?.size else {
        throw ReadAppConfigError.fileDoesNotExist(filePath)
    }
    
    let maxSize: Int64 = 1 << 20 // 1 MiB
    if size > maxSize {
        throw ReadAppConfigError.fileTooLarge
    }
    
    return try await FileSystem.shared.withFileHandle(forReadingAt: filePath) { handle in
        var buffer = try await handle.readToEnd(maximumSizeAllowed: .bytes(maxSize))
        guard let data = buffer.readData(length: buffer.readableBytes, byteTransferStrategy: .noCopy) else {
            throw ReadAppConfigError.unableToReadFileContents
        }
        
        return try YAMLDecoder().decode(AppConfig.self, from: data)
    }
}

public enum ReadAppConfigError: Error, CustomStringConvertible {
    case fileDoesNotExist(FilePath)
    case fileTooLarge
    case unableToReadFileContents
    
    public var description: String {
        switch self {
        case .fileDoesNotExist(let filePath): "Unable to locate config file at \(filePath.string)"
        case .fileTooLarge: "Config file exceeds maximum size of 1MiB"
        case .unableToReadFileContents: "Unable to read config file contents"
        }
    }
}

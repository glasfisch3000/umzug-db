import NIOFileSystem
import ArgumentParser

extension FilePath: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}

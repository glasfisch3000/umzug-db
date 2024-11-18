import ArgumentParser
import Vapor

extension Data: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        if var buffer = try? ByteBuffer(plainHexEncodedBytes: argument),
            let data = buffer.readData(length: buffer.readableBytes) {
            self = data
        } else {
            return nil
        }
    }
}

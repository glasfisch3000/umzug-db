import ArgumentParser
import Vapor
import NIOFileSystem

struct Boxes: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "boxes",
        abstract: "Work with item boxes.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [BoxesList.self, BoxesGet.self, BoxesCreate.self, BoxesUpdate.self, BoxesDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    init() { }
}

import ArgumentParser

@main
struct UmzugDB: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "umzug-db",
//        abstract: <#T##String#>,
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [Serve.self, Routes.self, Migrate.self],
        groupedSubcommands: [
            CommandGroup(name: "Database", subcommands: [Users.self, Boxes.self, Items.self, Pack.self, Unpack.self, Cum.self])
        ],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    init() { }
}

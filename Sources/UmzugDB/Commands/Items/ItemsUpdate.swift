import ArgumentParser
import Vapor
import NIOFileSystem
import FluentPostgresDriver

struct ItemsUpdate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update an item's attributes.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    struct ItemOptionGroup: ParsableArguments {
        @ArgumentParser.Option(name: [.long, .customShort("T")])
        var title: String?
    }
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.Argument
    private var itemID: UUID
    
    @ArgumentParser.OptionGroup(title: "Update Options")
    private var itemOptions: ItemOptionGroup
    
    init() { }
    
    func run() async throws {
        let config = try await readAppConfig(path: configFile)
        
        let environment = self.environment ?? config.environment
        var env = environment.makeEnvironment()
        env.commandInput.arguments = []
        
        try LoggingSystem.bootstrap(from: &env)
        let app = try await Application.make(env)

        // This attempts to install NIO as the Swift Concurrency global executor.
        // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
        // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
        // If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
        // let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
        // app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])
        
        do {
            try await configureDB(app, config)
            
            guard let item = try await Item.find(itemID, on: app.db) else {
                throw DBError.modelNotFound(.item(itemID))
            }
            
            if let name = itemOptions.title {
                item.title = name
            }
            
            do {
                try await item.update(on: app.db)
            } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
                throw DBError.constraintViolation(.item_unique(title: item.title))
            }
            
            print(try outputFormat.format(item.toDTO()))
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}

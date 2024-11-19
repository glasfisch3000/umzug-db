import ArgumentParser
import Vapor
import Fluent
import NIOFileSystem

struct Unpack: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "unpack",
        abstract: "Unpack an item from a box.",
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
    
    struct BoxOptionGroup: ParsableArguments {
        @ArgumentParser.Argument
        var name: String
        
        @ArgumentParser.Option(name: [.long, .customShort("B")])
        var box: String
    }
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.Argument
    private var item: String
    
    @ArgumentParser.Argument
    private var amount: Int
    
    @ArgumentParser.Option(name: [.long, .customShort("B")])
    private var box: String
    
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
            
            let item = try await getItem(on: app.db)
            let box = try await getBox(on: app.db)
            
            if !item.$id.exists {
                try await item.create(on: app.db)
            }
            if !box.$id.exists {
                try await box.create(on: app.db)
            }
            
            let itemID = try item.requireID()
            let boxID = try box.requireID()
            
            guard let packing = try await Packing.query(on: app.db)
                .filter(\.$item.$id == itemID)
                .filter(\.$box.$id == boxID)
                .unique()
                .first() else {
                throw DBError.modelNotFound(.packing_parents(item: itemID, box: boxID))
            }
            
            packing.amount -= self.amount
            if packing.amount < 0 {
                print("Warning: remaining amount < 0, this might be an error in the future.")
            }
            
            if packing.amount > 0 {
                try await packing.save(on: app.db)
                print(try outputFormat.format(packing.toDTO()))
            } else {
                try await packing.delete(on: app.db)
                print("deleted packing:\n" + (try outputFormat.format(packing.toDTO())))
            }
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
    
    func getItem(on db: any Database) async throws -> Item {
        guard let id = UUID(self.item) else {
            guard let item = try await Item.query(on: db)
                .filter(\.$title == self.item)
                .unique()
                .first() else {
                throw DBError.modelNotFound(.item_title(self.item))
            }
            
            return item
        }
        
        guard let item = try await Item.find(id, on: db) else {
            throw DBError.modelNotFound(.item(id))
        }
        
        return item
    }
    
    func getBox(on db: any Database) async throws -> Box {
        guard let id = UUID(self.box) else {
            guard let box = try await Box.query(on: db)
                .filter(\.$title == self.box)
                .unique()
                .first() else {
                throw DBError.modelNotFound(.box_title(self.box))
            }
            
            return box
        }
        
        guard let box = try await Box.find(id, on: db) else {
            throw DBError.modelNotFound(.box(id))
        }
        
        return box
    }
}

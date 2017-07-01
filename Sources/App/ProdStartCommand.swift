import Vapor
import Console

struct ProdCommand: Command {
    public let id = "prod"
    public let help = ["This command starts the application in production."]
    public let console: ConsoleProtocol

    public init(console: ConsoleProtocol) {
        self.console = console
    }

    public func run(arguments: [String]) throws {
        try console.foregroundExecute(program:"concurrently", arguments:["\"cd client && npm run build\"", "\"vapor run serve --env=production\""])
    }
}

extension ProdCommand: ConfigInitializable {
    init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
}

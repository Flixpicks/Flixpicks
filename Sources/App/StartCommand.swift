import Vapor
import Console

struct StartCommand: Command {
    public let id = "start"
    public let help = ["This command starts the application."]
    public let console: ConsoleProtocol

    public init(console: ConsoleProtocol) {
        self.console = console
    }

    public func run(arguments: [String]) throws {
        try console.foregroundExecute(program:"concurrently", arguments:["\"vapor run\"", "\"cd client && npm start\""])
    }
}

extension StartCommand: ConfigInitializable {
    init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
}

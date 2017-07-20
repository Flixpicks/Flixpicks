import MySQLProvider
import AuthProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        setupCommands()
    }

    /// Configure providers
    private func setupProviders() throws {
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }

    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(Movie.self)
        preparations.append(Show.self)
        preparations.append(Season.self)
        preparations.append(Episode.self)
    }

    // Add all commands
    private func setupCommands() {
        addConfigurable(command: StartCommand.init, name: "start")
        addConfigurable(command: ProdCommand.init, name: "prod")
    }
}

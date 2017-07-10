import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("/") { req in
          return try self.view.make("index.html")
        }
        
        setupMediaRoutes();
    }

    private func setupMediaRoutes() {
      let movieController = MovieController()
      resource("movies", movieController)

      let showController = ShowController()
      resource("shows", showController)

      let seasonController = SeasonController()
      resource("seasons", seasonController)

      let episodeController = EpisodeController()
      resource("episodes", episodeController)
    }
}

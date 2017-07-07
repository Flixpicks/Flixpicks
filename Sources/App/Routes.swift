import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("/") { req in
          return try self.view.make("index.html")
        }

        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }

        let movieController = MovieController()
        resource("movies", movieController)

        let showController = ShowController()
        resource("shows", showController)

        let seasonController = SeasonController()
        resource("seasons", seasonController)

        let episodeController = EpisodeController()
        resource("episodeController", episodeController)
    }
}

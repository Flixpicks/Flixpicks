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

        post("addMovie") { req in
            let movie = try Movie(json: req.json())
            try movie.save()
            return movie
        }
    }
}

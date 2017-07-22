import Vapor
import Sessions
import AuthProvider

extension Droplet {
    
    private static var controllers: [String : Controller] {
        get {
            return [UserController.name : UserController(),
                    EpisodeController.name : EpisodeController(),
                    MovieController.name : MovieController(),
                    SeasonController.name : SeasonController(),
                    ShowController.name : ShowController()]
        }
    }
    
    func setupRoutes() throws {
        try setupUnauthenticatedRoutes()
        try setupAuthorizedRoutes()
    }
    
    //Setup all routes that don't need authentication
    private func setupUnauthenticatedRoutes() throws {
        
        //Serves up our Webapp
        get("/") { req in
            return try self.view.make("index.html")
        }
        
        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        // Register cannot be part of the UserController because
        post("register") { req in
            guard let json = req.json else {
                throw Abort(.badRequest)
            }

            let user = try User(json: json)

            // ensure no user with this email already exists
            guard try User.makeQuery().filter("email", user.email).first() == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists.")
            }

            // require a plaintext password is supplied
            guard let password = json["password"]?.string else {
                throw Abort(.badRequest)
            }

            user.password = try self.hash.make(password.makeBytes()).makeString()
            try user.save()
            return user
        }
        
        for case let controller as SemiAuthenticatable in Droplet.controllers.values {
            try controller.setupUnauthenticatedRoutes(builder: self)
        }
    }

    //Setup all routes that need authorization
    private func setupAuthorizedRoutes() throws {
        let memory = MemorySessions()
        let authed = grouped([
            SessionsMiddleware(memory),
            PersistMiddleware(User.self),
            PasswordAuthenticationMiddleware(User.self)
        ])
        
        for case let controller as SemiAuthenticatable in Droplet.controllers.values {
            try controller.setupAuthenticatedRoutes(authed: authed)
        }
    }
}

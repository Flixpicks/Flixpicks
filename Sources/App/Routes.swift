import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
        try setupUnauthenticatedRoutes()
        try setupPasswordProtectedRoutes()
        try setupTokenProtectedRoutes()
    }
    
    //Setup all routes that don't need authentication
    private func setupUnauthenticatedRoutes() throws {
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
        
        let uc = UserController()
        resource("users", uc)
        
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
    }
    
    //Setup all routes that need a password
    private func setupPasswordProtectedRoutes() throws {
        let password = grouped([
            PasswordAuthenticationMiddleware(User.self)
        ])
        
        password.post("login") { req in
            let user = try req.user()
            let token = try Token.generate(for: user)
            try token.save()
            return token
        }
    }
    
    //Setup Token authenticated routes
    private func setupTokenProtectedRoutes() throws {
        let token = grouped([
            TokenAuthenticationMiddleware(User.self)
        ])
        
        token.get("me") { req in
            let user = try req.user()
            return "Hello, \(user.name)"
        }
    }
}

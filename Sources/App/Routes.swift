import Vapor

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
    }
    
    //Setup all routes that need a password
    private func setupPasswordProtectedRoutes() throws {
        
    }
    
    //Setup Token authenticated routes
    private func setupTokenProtectedRoutes() throws {
        
    }
}

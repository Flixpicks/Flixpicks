//
//  ShowRoutes.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/10/17.
//
//

import Vapor
import Sessions

extension Droplet {
    
    //Setup all show routes that don't need authentication
    func setupUnauthenticatedShowRoutes() throws {
        let showController = ShowController()
        
        get("shows", handler: showController.index)
        
        get("shows", Show.parameter) { req in
            let show = try req.parameters.next(Show.self)
            
            return showController.show(request: req, show: show)
        }
    }
    
    //Setup all show routes that need authorization
    func setupAuthorizedShowRoutes(authed: RouteBuilder) throws {
        let showController = ShowController()
        
        authed.post("shows", handler: showController.store)
        
        authed.patch("shows", Show.parameter) { req in
            let show = try req.parameters.next(Show.self)
            
            return try showController.update(request: req, show: show)
        }
        
        authed.delete("shows", Show.parameter) { req in
            let show = try req.parameters.next(Show.self)
            
            return try showController.delete(request: req, show: show)
        }
    }
}

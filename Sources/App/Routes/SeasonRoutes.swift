//
//  SeasonRoutes.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/10/17.
//
//

import Vapor
import Sessions

extension Droplet {
    
    //Setup all season routes that don't need authentication
    func setupUnauthenticatedSeasonRoutes() throws {
        let seasonController = SeasonController()
        
        get("seasons", handler: seasonController.index)
        
        get("seasons", Season.parameter) { req in
            let season = try req.parameters.next(Season.self)
            
            return seasonController.show(request: req, season: season)
        }
    }
    
    //Setup all season routes that need authorization
    func setupAuthorizedSeasonRoutes(authed: RouteBuilder) throws {
        let seasonController = SeasonController()
        
        authed.post("seasons", handler: seasonController.store)
        
        authed.patch("seasons", Season.parameter) { req in
            let season = try req.parameters.next(Season.self)
            
            return try seasonController.update(request: req, season: season)
        }
        
        authed.delete("seasons", Season.parameter) { req in
            let season = try req.parameters.next(Season.self)
            
            return try seasonController.delete(request: req, season: season)
        }
    }
}

//
//  SeasonController.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/6/17.
//
//

import Vapor
import HTTP

final class SeasonController {
    static let name = "SeasonController"
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Season.all().makeJSON()
    }

    func store(request: Request) throws -> ResponseRepresentable {
        let season = try Season(json: request.json!)
        try season.save()
        return season
    }

    func show(request: Request, season: Season) -> ResponseRepresentable {
        return season
    }

    func update(request: Request, season: Season) throws -> ResponseRepresentable {
        if let show_id = request.data["show_id"]?.int {
            season.show_id = show_id
        }

        if let season_num = request.data["season_num"]?.int {
            season.season_num = season_num
        }

        if let description = request.data["description"]?.string {
            season.description = description
        }

        if let release_date = request.data["release_date"]?.date {
            season.release_date = release_date
        }
        try season.save()
        return Response(status: .ok)
    }

    func delete(request: Request, season: Season) throws -> ResponseRepresentable {
        try season.delete()
        return Response(status: .ok)
    }
}

extension SeasonController: SemiAuthenticatable {
    func setupUnauthenticatedRoutes(builder: RouteBuilder) throws {
        let seasonController = SeasonController()
        
        builder.get("seasons", handler: seasonController.index)
        
        builder.get("seasons", Season.parameter) { req in
            let season = try req.parameters.next(Season.self)
            
            return seasonController.show(request: req, season: season)
        }
    }
    
    func setupAuthenticatedRoutes(authed: RouteBuilder) throws {
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

//
//  ShowController.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/6/17.
//
//

import Vapor
import HTTP

final class ShowController: Controller {
    static let name = "ShowController"
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Show.all().makeJSON()
    }

    func store(request: Request) throws -> ResponseRepresentable {
      let show = try Show(json: request.json!)
      try show.save()
      return show
    }

    func show(request: Request, show: Show) -> ResponseRepresentable {
        return show
    }

    func update(request: Request, show: Show) throws -> ResponseRepresentable {
        if let title = request.data["title"]?.string {
          show.title = title
        }

        if let description = request.data["description"]?.string {
          show.description = description
        }

        if let release_date = request.data["release_date"]?.date {
          show.release_date = release_date
        }

        if let age_rating = request.data["age_rating"]?.int {
          show.age_rating = age_rating
        }

        if let genre = request.data["genre"]?.int {
          show.genre = genre
        }
        try show.save()
        return Response(status: .ok)
    }

    func delete(request: Request, show: Show) throws -> ResponseRepresentable {
        try show.delete()
        return Response(status: .ok)
    }
}

extension ShowController: SemiAuthenticatable {
    func setupUnauthenticatedRoutes(builder: RouteBuilder) throws {
        let showController = ShowController()
        
        builder.get("shows", handler: showController.index)
        
        builder.get("shows", Show.parameter) { req in
            let show = try req.parameters.next(Show.self)
            
            return showController.show(request: req, show: show)
        }
    }
    
    func setupAuthenticatedRoutes(authed: RouteBuilder) throws {
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

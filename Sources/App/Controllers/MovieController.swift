//
//  MovieController.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/5/17.
//
//

import Vapor
import HTTP

final class MovieController {
    static let name = "MovieController"
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Movie.all().makeJSON()
    }

    func store(request: Request) throws -> ResponseRepresentable {
      let movie = try Movie(json: request.json!)
      try movie.save()
      return movie
    }

    func show(request: Request, movie: Movie) -> ResponseRepresentable {
        return movie
    }

    func update(request: Request, movie: Movie) throws -> ResponseRepresentable {
        if let title = request.data["title"]?.string {
          movie.title = title
        }

        if let description = request.data["description"]?.string {
          movie.description = description
        }

        if let release_date = request.data["release_date"]?.date {
          movie.release_date = release_date
        }

        if let age_rating = request.data["age_rating"]?.int {
          movie.age_rating = age_rating
        }

        if let genre = request.data["genre"]?.int {
          movie.genre = genre
        }
        try movie.save()
        return movie
    }

    func delete(request: Request, movie: Movie) throws -> ResponseRepresentable {
        try movie.delete()
        return Response(status: .ok)
    }
}

extension MovieController: SemiAuthenticatable {
    func setupUnauthenticatedRoutes(builder: RouteBuilder) throws {
        let movieController = MovieController()
        
        builder.get("movies", handler:movieController.index)
        
        builder.get("movies", Movie.parameter) { req in
            let movie = try req.parameters.next(Movie.self)
            
            return movieController.show(request: req, movie: movie)
        }
    }
    
    func setupAuthenticatedRoutes(authed: RouteBuilder) throws {
        let movieController = MovieController()
        
        authed.post("movies", handler: movieController.store)
        
        authed.patch("movies", Movie.parameter) { req in
            let movie = try req.parameters.next(Movie.self)
            
            return try movieController.update(request: req, movie: movie)
        }
        
        authed.delete("movies", Movie.parameter) { req in
            let movie = try req.parameters.next(Movie.self)
            
            return try movieController.delete(request: req, movie: movie)
        }
    }
}

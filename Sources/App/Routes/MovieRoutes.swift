//
//  MovieRoutes.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/10/17.
//
//

import Vapor
import Sessions

extension Droplet {

    //Setup all movie routes that don't need authentication
    func setupUnauthenticatedMovieRoutes() throws {
        let movieController = MovieController()

        get("movies", handler:movieController.index)

        get("movies", Movie.parameter) { req in
            let movie = try req.parameters.next(Movie.self)

            return movieController.show(request: req, movie: movie)
        }
    }

    //Setup all movie routes that need authorization
    func setupAuthorizedMovieRoutes(authed: RouteBuilder) throws {
        let movieController = MovieController()

        authed.post("movies") { req in
            return try movieController.store(drop: self, request: req)
        }

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

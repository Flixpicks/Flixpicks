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
    func index(request: Request) throws -> ResponseRepresentable {
        return try Movie.all().makeJSON()
    }

    func show(request: Request, movie: Movie) throws -> ResponseRepresentable {
        return movie
    }

    func update(request: Request, movie: Movie) throws -> ResponseRepresentable {
        let new = try request.jsonMovie()
        movie.title = new.title
        movie.description = new.description
        movie.releaseDate = new.releaseDate
        movie.ageRating = new.ageRating
        try movie.save()
        return Response(status: .ok)
    }

    func delete(request: Request, movie: Movie) throws -> ResponseRepresentable {
        try movie.delete()
        return Response(status: .ok)
    }

    func clear(requset: Request) throws -> ResponseRepresentable {
        try Movie.makeQuery().delete()
        return Response(status: .ok)
    }
}

extension MovieController: ResourceRepresentable {
    func makeResource() -> Resource<Movie> {
        return Resource(index: index,
                        show: show,
                        update: update,
                        destroy: delete,
                        clear: clear)
    }
}

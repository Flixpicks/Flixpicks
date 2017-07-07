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

        if let releaseDate = request.data["releaseDate"]?.date {
          movie.releaseDate = releaseDate
        }

        if let ageRating = request.data["title"]?.int {
          movie.ageRating = ageRating
        }
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
                        store: store,
                        show: show,
                        update: update,
                        destroy: delete,
                        clear: clear)
    }
}

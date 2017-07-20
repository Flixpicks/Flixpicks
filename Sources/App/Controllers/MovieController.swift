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

    func store(drop: Droplet, request: Request) throws -> ResponseRepresentable {
      print(request)
      let body = try Body.data( Node(node: [
                            "file": request.data["poster"],
                            "upload_preset": "upjvzh8n"
                            ]).formURLEncoded())
      let poster_response = try drop.client.post("https://api.cloudinary.com/v1_1/flixpicks/image/upload",
                                                 query: [:],
                                                 ["Content-Type": "application/x-www-form-urlencoded"],
                                                 body)
      print(poster_response)
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
        return Response(status: .ok)
    }

    func delete(request: Request, movie: Movie) throws -> ResponseRepresentable {
        try movie.delete()
        return Response(status: .ok)
    }
}

// extension MovieController: ResourceRepresentable {
//     func makeResource() -> Resource<Movie> {
//         return Resource(index: index,
//                         store: store,
//                         show: show,
//                         update: update,
//                         destroy: delete)
//     }
// }

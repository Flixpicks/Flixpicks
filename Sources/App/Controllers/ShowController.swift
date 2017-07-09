//
//  ShowController.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/6/17.
//
//
import Vapor
import HTTP

final class ShowController {
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

    func clear(requset: Request) throws -> ResponseRepresentable {
        try Show.makeQuery().delete()
        return Response(status: .ok)
    }
}

extension ShowController: ResourceRepresentable {
    func makeResource() -> Resource<Show> {
        return Resource(index: index,
                        store: store,
                        show: show,
                        update: update,
                        destroy: delete,
                        clear: clear)
    }
}

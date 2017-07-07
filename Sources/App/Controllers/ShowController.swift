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

        if let releaseDate = request.data["releaseDate"]?.date {
          show.releaseDate = releaseDate
        }

        if let ageRating = request.data["ageRating"]?.int {
          show.ageRating = ageRating
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

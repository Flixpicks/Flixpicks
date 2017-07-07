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
        if let showID = request.data["showID"]?.int {
            season.showID = showID
        }

        if let seasonNum = request.data["seasonNum"]?.int {
            season.seasonNum = seasonNum
        }

        if let description = request.data["description"]?.string {
            season.description = description
        }

        if let releaseDate = request.data["releaseDate"]?.date {
            season.releaseDate = releaseDate
        }
        try season.save()
        return Response(status: .ok)
    }

    func delete(request: Request, season: Season) throws -> ResponseRepresentable {
        try season.delete()
        return Response(status: .ok)
    }

    func clear(requset: Request) throws -> ResponseRepresentable {
        try Season.makeQuery().delete()
        return Response(status: .ok)
    }
}

extension SeasonController: ResourceRepresentable {
    func makeResource() -> Resource<Season> {
        return Resource(index: index,
                        store: store,
                        show: show,
                        update: update,
                        destroy: delete,
                        clear: clear)
    }
}

//
//  EpisodeController.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/5/17.
//
//
import Vapor
import HTTP

final class EpisodeController {
    func index(request: Request) throws -> ResponseRepresentable {
        return try Episode.all().makeJSON()
    }

    func store(request: Request) throws -> ResponseRepresentable {
      let episode = try Episode(json: request.json!)
      try episode.save()
      return episode
    }

    func show(request: Request, episode: Episode) -> ResponseRepresentable {
        return episode
    }

    func update(request: Request, episode: Episode) throws -> ResponseRepresentable {
        if let showID = request.data["showID"]?.int {
          episode.showID = showID
        }

        if let seasonID = request.data["seasonID"]?.int {
          episode.seasonID = seasonID
        }

        if let episodeNum = request.data["episodeNum"]?.int {
          episode.episodeNum = episodeNum
        }

        if let title = request.data["title"]?.string {
          episode.title = title
        }

        if let description = request.data["description"]?.string {
          episode.description = description
        }

        if let releaseDate = request.data["releaseDate"]?.date {
          episode.releaseDate = releaseDate
        }
        try episode.save()
        return Response(status: .ok)
    }

    func delete(request: Request, episode: Episode) throws -> ResponseRepresentable {
        try episode.delete()
        return Response(status: .ok)
    }

    func clear(requset: Request) throws -> ResponseRepresentable {
        try Episode.makeQuery().delete()
        return Response(status: .ok)
    }
}

extension EpisodeController: ResourceRepresentable {
    func makeResource() -> Resource<Episode> {
        return Resource(index: index,
                        store: store,
                        show: show,
                        update: update,
                        destroy: delete,
                        clear: clear)
    }
}

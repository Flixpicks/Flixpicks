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
        if let season_id = request.data["season_id"]?.int {
          episode.season_id = season_id
        }

        if let episode_num = request.data["episode_num"]?.int {
          episode.episode_num = episode_num
        }

        if let title = request.data["title"]?.string {
          episode.title = title
        }

        if let description = request.data["description"]?.string {
          episode.description = description
        }

        if let release_date = request.data["release_date"]?.date {
          episode.release_date = release_date
        }
        try episode.save()
        return Response(status: .ok)
    }

    func delete(request: Request, episode: Episode) throws -> ResponseRepresentable {
        try episode.delete()
        return Response(status: .ok)
    }
}

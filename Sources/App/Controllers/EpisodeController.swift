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
    static let name = "EpisodeController"
    
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

extension EpisodeController: SemiAuthenticatable {
    func setupUnauthenticatedRoutes(builder: RouteBuilder) throws {
        let episodeController = EpisodeController()
        
        builder.get("episodes", handler: episodeController.index)
        
        builder.get("episodes", Episode.parameter) { req in
            let episode = try req.parameters.next(Episode.self)
            
            return episodeController.show(request: req, episode: episode)
        }
    }
    
    func setupAuthenticatedRoutes(authed: RouteBuilder) throws {
        let episodeController = EpisodeController()
        
        authed.post("episodes", handler: episodeController.store)
        
        authed.patch("episodes", Episode.parameter) { req in
            let episode = try req.parameters.next(Episode.self)
            
            return try episodeController.update(request: req, episode: episode)
        }
        
        authed.delete("episodes", Episode.parameter) { req in
            let episode = try req.parameters.next(Episode.self)
            
            return try episodeController.delete(request: req, episode: episode)
        }
    }
}

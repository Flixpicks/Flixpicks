//
//  EpisodeRoutes.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/10/17.
//
//

import Vapor
import Sessions

extension Droplet {

    //Setup all episode routes that don't need authentication
    func setupUnauthenticatedEpisodeRoutes() throws {
        let episodeController = EpisodeController()

        get("episodes", handler: episodeController.index)

        get("episodes", Episode.parameter) { req in
            let episode = try req.parameters.next(Episode.self)

            return episodeController.show(request: req, episode: episode)
        }
    }
    
    //Setup all episode routes that need authorization
    func setupAuthorizedEpisodeRoutes(authed: RouteBuilder) throws {
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

//
//  TVTestCase.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/23/17.
//
//

import XCTest
import Testing
import HTTP
import Sockets
import Sessions
import Cookies
import AuthProvider
@testable import Vapor
@testable import App

class TVTestCase: AuthenticationTestCase {
    
    var showId: Int?
    var seasonId: Int?
    var episodeId: Int?
    
    let initialShowTitle = "Show Title 1"
    let initialShowDescription = "Show Description 1"
    let initialShowReleaseDate = "2017-04-12T00:00:00.000Z"
    let initialShowAgeRating = 5
    let initialShowGenre = 1
    
    let initialSeasonNum = 1
    let initialSeasonDescription = "Sesason Description 1"
    let initialSeasonReleaseDate = "2016-10-21T00:00:00.000Z"
    
    let initialEpisodeNum = 1
    let initialEpisodeTitle = "Episode Title 1"
    let initialEpisodeDescription = "Episode Description 1"
    let initialEpisodeReleaseDate = "2010-09-28T00:00:00.000Z"
    
    override func setUp() {
        super.setUp()
        self.showId = nil
        self.seasonId = nil
        self.episodeId = nil
    }
    
    override func tearDown() {
        //delete newly created movie if it exists
        if let episodeId = self.episodeId {
            do {
                let _ = try drop.delete("/episodes/\(episodeId)")
                self.episodeId = nil
            } catch {
                print("error deleting episode \(error)")
            }
        }
        
        if let seasonId = self.seasonId {
            do {
                let _ = try drop.delete("/seasons/\(seasonId)")
                self.seasonId = nil
            } catch {
                print("error deleting season \(error)")
            }
        }
        
        if let showId = self.showId {
            do {
                let _ = try drop.delete("/shows/\(showId)")
                self.showId = nil
            } catch {
                print("error deleting show \(error)")
            }
        }
        
        super.tearDown()
    }
    
    func createAll() throws {
        let episodeResponse = try createEpisode()
        self.episodeId = episodeResponse.data["id"]?.int
    }
    
    func createShow() throws -> Response {
        let showRequest = Request(method: .post, uri: "/shows")
        showRequest.json = try showJSON()
        showRequest.cookies.insert(sessionCookie!)
        
        return try drop.respond(to: showRequest, through: middleWare)
    }
    
    func createSeason() throws -> Response {
        let showResponse = try createShow()
        self.showId = showResponse.data["id"]?.int
        
        let seasonRequest = Request(method: .post, uri: "/seasons")
        seasonRequest.json = try seasonJSON()
        seasonRequest.cookies.insert(sessionCookie!)
        
        return try drop.respond(to: seasonRequest, through: middleWare)
    }
    
    func createEpisode() throws -> Response {
        let seasonResponse = try createSeason()
        self.seasonId = seasonResponse.data["id"]?.int
        
        let episodeRequest = Request(method: .post, uri: "/episodes")
        episodeRequest.json = try episodeJSON()
        episodeRequest.cookies.insert(sessionCookie!)
        
        return try drop.respond(to: episodeRequest, through: middleWare)
    }
    
    func episodeJSON() throws -> JSON {
        var episodeJSON = JSON()
        if let episodeId = self.episodeId {
            try episodeJSON.set("id", episodeId)
        }
        try episodeJSON.set("season_id", self.seasonId)
        try episodeJSON.set("episode_num", self.initialEpisodeNum)
        try episodeJSON.set("title", self.initialEpisodeTitle)
        try episodeJSON.set("description", self.initialEpisodeDescription)
        try episodeJSON.set("release_date", self.initialEpisodeReleaseDate)
        return episodeJSON
    }
    
    func seasonJSON() throws -> JSON {
        var seasonJSON = JSON()
        if let seasonId = self.seasonId {
            try seasonJSON.set("id", seasonId)
        }
        try seasonJSON.set("show_id", self.showId)
        try seasonJSON.set("season_num", self.initialSeasonNum)
        try seasonJSON.set("description", self.initialSeasonDescription)
        try seasonJSON.set("release_date", self.initialSeasonReleaseDate)
        
        return seasonJSON
    }
    
    func showJSON() throws -> JSON {
        var showJSON = JSON()
        try showJSON.set("title", self.initialShowTitle)
        try showJSON.set("description", self.initialShowDescription)
        try showJSON.set("release_date", self.initialShowReleaseDate)
        try showJSON.set("age_rating", self.initialShowAgeRating)
        try showJSON.set("genre", self.initialShowGenre)
        
        return showJSON
    }
}

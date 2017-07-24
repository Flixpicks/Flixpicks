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
    let initialShowReleaseDate = "2014-10-14 00:00:00"
    let initialShowAgeRating = 5
    let initialShowGenre = 1
    
    let initialSeasonNum = 1
    let initialSeasonDescription = "Sesason Description 1"
    let initialSeasonReleaseDate = "2014-10-21 00:00:00"
    
    let initialEpisodeNum = 1
    let initialEpisodeTitle = "Episode Title 1"
    let initialEpisodeDescription = "Episode Description 1"
    let initialEpisodeReleaseDate = "2014-10-28 00:00:00"
    
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
        var showData = JSON()
        try showData.set("title", self.initialShowTitle)
        try showData.set("description", self.initialShowDescription)
        try showData.set("release_date", self.initialShowReleaseDate)
        try showData.set("age_rating", self.initialShowAgeRating)
        try showData.set("genre", self.initialShowGenre)
        
        let showRequest = Request(method: .post, uri: "/shows")
        showRequest.json = showData
        showRequest.cookies.insert(sessionCookie!)
        
        return try drop.respond(to: showRequest, through: middleWare)
    }
    
    func createSeason() throws -> Response {
        let showResponse = try createShow()
        self.showId = showResponse.data["id"]?.int
        
        var seasonData = JSON()
        try seasonData.set("show_id", self.showId)
        try seasonData.set("season_num", self.initialSeasonNum)
        try seasonData.set("description", self.initialSeasonDescription)
        try seasonData.set("release_date", self.initialSeasonReleaseDate)
        
        let seasonRequest = Request(method: .post, uri: "/seasons")
        seasonRequest.json = seasonData
        seasonRequest.cookies.insert(sessionCookie!)
        
        return try drop.respond(to: seasonRequest, through: middleWare)
    }
    
    func createEpisode() throws -> Response {
        let seasonResponse = try createSeason()
        self.seasonId = seasonResponse.data["id"]?.int
        
        var episodeData = JSON()
        try episodeData.set("season_id", self.seasonId)
        try episodeData.set("episode_num", self.initialEpisodeNum)
        try episodeData.set("title", self.initialEpisodeTitle)
        try episodeData.set("description", self.initialEpisodeDescription)
        try episodeData.set("release_date", self.initialEpisodeReleaseDate)
        
        let episodeRequest = Request(method: .post, uri: "/episodes")
        episodeRequest.json = episodeData
        episodeRequest.cookies.insert(sessionCookie!)
        
        return try drop.respond(to: episodeRequest, through: middleWare)
    }
}

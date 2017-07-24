//
//  EpisodeControllerTests.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/9/17.
//
//
import XCTest
import Testing
import HTTP
import Sockets
@testable import Vapor
@testable import App

class EpisodeControllerTests: TVTestCase {

    let secondEpisodeNum = 22
    let secondTitle = "Tistle 2"
    let secondDescription = "Description 2"
    let secondReleaseDate = "2014-10-21 00:00:00"

    func testCreate() {
        do {
            let episodeResponse = try createEpisode()
            
            episodeId = episodeResponse.data["id"]?.int
            XCTAssertNotNil(episodeId)
            
            //TODO: Add test for release date
            try episodeResponse
                .assertStatus(is: .ok)
                .assertJSON("id",          equals: self.episodeId)
                .assertJSON("season_id",   equals: self.seasonId!)
                .assertJSON("episode_num", equals: self.initialEpisodeNum)
                .assertJSON("title",       equals: self.initialEpisodeTitle)
                .assertJSON("description", equals: self.initialEpisodeDescription)
        } catch {
            XCTFail("testCreate failed with error: \(error)")
        }
    }
    
    func testGetOne()  {
        do {
            try createAll()
            
            if let episodeId = self.episodeId {
                //TODO: Add test for release date
                try drop
                    .testResponse(to: .get,
                                  at: "/episodes/\(episodeId)")
                    .assertStatus(is: .ok)
                    .assertJSON("id",          equals: self.episodeId)
                    .assertJSON("season_id",   equals: self.seasonId!)
                    .assertJSON("episode_num", equals: self.initialEpisodeNum)
                    .assertJSON("title",       equals: self.initialEpisodeTitle)
                    .assertJSON("description", equals: self.initialEpisodeDescription)
            }
        } catch {
            XCTFail("testGetOne failed with error: \(error)")
        }
    }
    
    func testGetAll() throws {
        do {
            try createAll()
            
            try drop
                .testResponse(to: .get, at: "/episodes")
                .assertStatus(is: .ok)
        } catch {
            XCTFail("testGetAll failed with error: \(error)")
        }
    }
    
    func testPatch() throws {
        do {
            try createAll()
            
            // Change it
            var episodeData = JSON()
            try episodeData.set("episode_num",  self.secondEpisodeNum)
            try episodeData.set("title",        self.secondTitle)
            try episodeData.set("description",  self.secondDescription)
            try episodeData.set("release_date", self.secondReleaseDate)
            
            if let episodeId = self.episodeId {
                let episodeRequest = Request(method: .patch, uri: "/episodes/\(episodeId)")
                episodeRequest.json = episodeData
                episodeRequest.cookies.insert(sessionCookie!)
                
                //TODO: Add test for release date
                try drop
                    .respond(to: episodeRequest, through: middleWare)
                    .assertStatus(is: .ok)
                    .assertJSON("id",          equals: self.episodeId)
                    .assertJSON("season_id",   equals: self.seasonId!)
                    .assertJSON("episode_num", equals: self.secondEpisodeNum)
                    .assertJSON("title",       equals: self.secondTitle)
                    .assertJSON("description", equals: self.secondDescription)
                
            }
        } catch {
            XCTFail("testPatch failed with error: \(error)")
        }
    }
    
    func testDelete() throws {
        do {
            let episodeResponse = try createEpisode()
            let regId = episodeResponse.data["id"]?.int
            
            let episodeRequest = Request(method: .delete, uri: "/episodes/\(regId!)")
            episodeRequest.cookies.insert(sessionCookie!)
            
            //Delete
            try drop
                .respond(to: episodeRequest, through: middleWare)
                .assertStatus(is: .ok)
        } catch {
            XCTFail("testDelete failed with error: \(error)")
        }
    }
}

// MARK: Manifest

extension EpisodeControllerTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testCreate", testCreate),
        ("testGetOne", testGetOne),
        ("testGetAll", testGetAll),
        ("testPatch",  testPatch),
        ("testDelete", testDelete)
    ]
}


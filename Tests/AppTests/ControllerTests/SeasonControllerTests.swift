//
//  SeasonControllerTests.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/22/17.
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

class SeasonControllerTests: TVTestCase {

    let secondSeasonNum = 2
    let secondDescription = "Description 2"
    let secondReleaseDate = "2014-11-21 00:00:00"
    
    func testCreate() {
        do {
            let seasonResponse = try createSeason()
            
            seasonId = seasonResponse.data["id"]?.int
            XCTAssertNotNil(seasonId)
            
            //TODO: Add test for release date
            try seasonResponse
                .assertStatus(is: .ok)
                .assertJSON("id",          equals: self.seasonId)
                .assertJSON("show_id",     equals: self.showId!)
                .assertJSON("season_num",  equals: self.initialSeasonNum)
                .assertJSON("description", equals: self.initialSeasonDescription)
        } catch {
            XCTFail("testCreate failed with error: \(error)")
        }
    }
    
    func testGetOne()  {
        do {
            try createAll()
            
            if let seasonId = self.seasonId {
                //TODO: Add test for release date
                try drop
                    .testResponse(to: .get,
                                  at: "/seasons/\(seasonId)")
                    .assertStatus(is: .ok)
                    .assertJSON("id",          equals: self.seasonId)
                    .assertJSON("show_id",     equals: self.showId!)
                    .assertJSON("season_num",  equals: self.initialSeasonNum)
                    .assertJSON("description", equals: self.initialSeasonDescription)
            }
        } catch {
            XCTFail("testGetOne failed with error: \(error)")
        }
    }
    
    func testGetAll() throws {
        do {
            try createAll()
            
            try drop
                .testResponse(to: .get, at: "/seasons")
                .assertStatus(is: .ok)
        } catch {
            XCTFail("testGetAll failed with error: \(error)")
        }
    }
    
    func testPatch() throws {
        do {
            try createAll()
            
            // Change it
            var seasonData = JSON()
            try seasonData.set("season_num",   self.secondSeasonNum)
            try seasonData.set("description",  self.secondDescription)
            try seasonData.set("release_date", self.secondReleaseDate)
            
            if let seasonId = self.seasonId {
                let seasonRequest = Request(method: .patch, uri: "/seasons/\(seasonId)")
                seasonRequest.json = seasonData
                seasonRequest.cookies.insert(sessionCookie!)
                
                //TODO: Add test for release date
                try drop
                    .respond(to: seasonRequest, through: middleWare)
                    .assertStatus(is: .ok)
                    .assertJSON("id",          equals: self.seasonId)
                    .assertJSON("show_id",     equals: self.showId!)
                    .assertJSON("season_num",  equals: self.secondSeasonNum)
                    .assertJSON("description", equals: self.secondDescription)
                
            }
        } catch {
            XCTFail("testPatch failed with error: \(error)")
        }
    }
    
    func testDelete() throws {
        do {
            let seasonResponse = try createSeason()
            let regId = seasonResponse.data["id"]?.int
            
            let seasonRequest = Request(method: .delete, uri: "/seasons/\(regId!)")
            seasonRequest.cookies.insert(sessionCookie!)
            
            //Delete
            try drop
                .respond(to: seasonRequest, through: middleWare)
                .assertStatus(is: .ok)
        } catch {
            XCTFail("testDelete failed with error: \(error)")
        }
    }
}

// MARK: Manifest

extension SeasonControllerTests {
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

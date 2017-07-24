//
//  ShowControllerTests.swift
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

class ShowControllerTests: TVTestCase {
    
    let secondTitle = "Title 2"
    let secondDescription = "Description 2"
    let secondReleaseDate = "2014-10-21 00:00:00"
    let secondAgeRating = 4
    let secondGenre = 2

    func testCreate() {
        do {
            let showResponse = try createShow()
            
            showId = showResponse.data["id"]?.int
            XCTAssertNotNil(showId)
            
            //TODO: Add test for release date
            try showResponse
                .assertStatus(is: .ok)
                .assertJSON("id",          equals: self.showId)
                .assertJSON("title",       equals: self.initialShowTitle)
                .assertJSON("description", equals: self.initialShowDescription)
                .assertJSON("age_rating",  equals: self.initialShowAgeRating)
                .assertJSON("genre",       equals: self.initialShowGenre)
        } catch {
            XCTFail("testCreate failed with error: \(error)")
        }
    }
    
    func testGetOne()  {
        do {
            try createAll()
            
            if let showId = self.showId {
                //TODO: Add test for release date
                try drop
                    .testResponse(to: .get,
                                  at: "/shows/\(showId)")
                    .assertStatus(is: .ok)
                    .assertJSON("id",          equals: self.showId)
                    .assertJSON("title",       equals: self.initialShowTitle)
                    .assertJSON("description", equals: self.initialShowDescription)
                    .assertJSON("age_rating",  equals: self.initialShowAgeRating)
                    .assertJSON("genre",       equals: self.initialShowGenre)
            }
        } catch {
            XCTFail("testGetOne failed with error: \(error)")
        }
    }
    
    func testGetAll() throws {
        do {
            try createAll()
            
            try drop
                .testResponse(to: .get, at: "/shows")
                .assertStatus(is: .ok)
        } catch {
            XCTFail("testGetAll failed with error: \(error)")
        }
    }
    
    func testPatch() throws {
        do {
            try createAll()
            
            // Change it
            var showData = JSON()
            try showData.set("title",        self.secondTitle)
            try showData.set("description",  self.secondDescription)
            try showData.set("release_date", self.secondReleaseDate)
            try showData.set("age_rating",   self.secondAgeRating)
            try showData.set("genre",        self.secondGenre)
            
            if let showId = self.showId {
                let showRequest = Request(method: .patch, uri: "/shows/\(showId)")
                showRequest.json = showData
                showRequest.cookies.insert(sessionCookie!)
                
                //TODO: Add test for release date
                try drop
                    .respond(to: showRequest, through: middleWare)
                    .assertStatus(is: .ok)
                    .assertJSON("id",          equals: self.showId)
                    .assertJSON("title",       equals: self.secondTitle)
                    .assertJSON("description", equals: self.secondDescription)
                    .assertJSON("age_rating",  equals: self.secondAgeRating)
                    .assertJSON("genre",       equals: self.secondGenre)
                
            }
        } catch {
            XCTFail("testPatch failed with error: \(error)")
        }
    }
    
    func testDelete() throws {
        do {
            let showResponse = try createShow()
            let regId = showResponse.data["id"]?.int
            
            let showRequest = Request(method: .delete, uri: "/shows/\(regId!)")
            showRequest.cookies.insert(sessionCookie!)
            
            //Delete
            try drop
                .respond(to: showRequest, through: middleWare)
                .assertStatus(is: .ok)
        } catch {
            XCTFail("testDelete failed with error: \(error)")
        }
    }
}

// MARK: Manifest

extension ShowControllerTests {
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

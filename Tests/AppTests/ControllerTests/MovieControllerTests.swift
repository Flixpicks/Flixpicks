//
//  MovieControllerTests.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/13/17.
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

class MovieControllerTests: AuthenticationTestCase {
    
    var movieId: Int?

    let initialTitle = "Title 1"
    let initialDescription = "Description 1"
    let initialReleaseDate = "2014-10-14 00:00:00"
    let initialAgeRating = 5
    let initialGenre = 1

    let secondTitle = "Title 2"
    let secondDescription = "Description 2"
    let secondReleaseDate = "2014-10-21 00:00:00"
    let secondAgeRating = 4
    let secondGenre = 2
    
    override func setUp() {
        super.setUp()
        self.movieId = nil
    }

    override func tearDown() {
        //delete newly created movie if it exists
        if let movieId = self.movieId {
            do {
                let _ = try drop.delete("/movies/\(movieId)")
                self.movieId = nil
            } catch {
                print("error deleting movie \(error)")
            }
        }

        super.tearDown()
    }
    
    func create() throws -> Response {
        var movieData = JSON()
        try movieData.set("title",        self.initialTitle)
        try movieData.set("description",  self.initialDescription)
        try movieData.set("release_date", self.initialReleaseDate)
        try movieData.set("age_rating",   self.initialAgeRating)
        try movieData.set("genre",        self.initialGenre)
        
        let movieRequest = Request(method: .post, uri: "/movies")
        movieRequest.json = movieData
        movieRequest.cookies.insert(sessionCookie!)
        
        return try drop.respond(to: movieRequest, through: middleWare)
    }

    func testCreate() {
        do {
            let movieResponse = try create()
        
            movieId = movieResponse.data["id"]?.int
            XCTAssertNotNil(movieId)
            
            //TODO: Add test for release date
            try movieResponse
                .assertStatus(is: .ok)
                .assertJSON("id",          equals: self.movieId)
                .assertJSON("title",       equals: self.initialTitle)
                .assertJSON("description", equals: self.initialDescription)
                .assertJSON("age_rating",  equals: self.initialAgeRating)
                .assertJSON("genre",       equals: self.initialGenre)
        } catch {
            XCTFail("testCreate failed with error: \(error)")
        }
    }
    
    func testGetOne() throws {
        do {
            let movieResponse = try create()
            
            self.movieId = movieResponse.data["id"]?.int
            if let movieId = self.movieId {
                //TODO: Add test for release date
                try drop
                    .testResponse(to: .get,
                                  at: "/movies/\(movieId)")
                    .assertStatus(is: .ok)
                    .assertJSON("id",          equals: self.movieId)
                    .assertJSON("title",       equals: self.initialTitle)
                    .assertJSON("description", equals: self.initialDescription)
                    .assertJSON("age_rating",  equals: self.initialAgeRating)
                    .assertJSON("genre",       equals: self.initialGenre)
            }
        } catch {
            XCTFail("testGetOne failed with error: \(error)")
        }
    }
    
    func testGetAll() {
        do {
            let movieResponse = try create()
            
            self.movieId = movieResponse.data["id"]?.int
            try drop
                .testResponse(to: .get, at: "/movies")
                .assertStatus(is: .ok)
        } catch {
            XCTFail("testGetAll failed with error: \(error)")
        }
    }
    
    func testPatch() {
        do {
            let movieResponse = try create()
            self.movieId = movieResponse.data["id"]?.int
            
            // Change it
            var movieData = JSON()
            try movieData.set("title",        self.secondTitle)
            try movieData.set("description",  self.secondDescription)
            try movieData.set("release_date", self.secondReleaseDate)
            try movieData.set("age_rating",   self.secondAgeRating)
            try movieData.set("genre",        self.secondGenre)
            
            if let movieId = self.movieId {
                let movieRequest = Request(method: .patch, uri: "/movies/\(movieId)")
                movieRequest.json = movieData
                movieRequest.cookies.insert(sessionCookie!)
                
                //TODO: Add test for release date
                try drop
                    .respond(to: movieRequest, through: middleWare)
                    .assertStatus(is: .ok)
                    .assertJSON("id",          equals: self.movieId)
                    .assertJSON("title",       equals: self.secondTitle)
                    .assertJSON("description", equals: self.secondDescription)
                    .assertJSON("age_rating",  equals: self.secondAgeRating)
                    .assertJSON("genre",       equals: self.secondGenre)
                
            }
        } catch {
            XCTFail("testPatch failed with error: \(error)")
        }
    }
    
    func testDelete() {
        do {
            let movieResponse = try create()
            let regId = movieResponse.data["id"]?.int
            
            let movieRequest = Request(method: .delete, uri: "/movies/\(regId!)")
            movieRequest.cookies.insert(sessionCookie!)
            
            //Delete
            try drop
                .respond(to: movieRequest, through: middleWare)
                .assertStatus(is: .ok)
        } catch {
            XCTFail("testDelete failed with error: \(error)")
        }
    }
}

// MARK: Manifest

extension MovieControllerTests {
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

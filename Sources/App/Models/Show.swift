//
//  Show.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/5/17.
//
//

import Vapor
import FluentProvider
import HTTP

final class Show: Model {
    let storage = Storage()

    /// The content of the Show
    var title: String
    var description: String
    var release_date: Date
    var age_rating: Int
    var genre: Int
    var seasons: Children<Show, Season> {
        return children()
    }

    /// Creates a new Show
    init(title: String, description: String, release_date: Date, age_rating: Int, genre: Int) {
        self.title = title
        self.description = description
        self.release_date = release_date
        self.age_rating = age_rating
        self.genre = genre
    }

    // MARK: Fluent Serialization

    /// Initializes the Show from the
    /// database row
    init(row: Row) throws {
        title = try row.get("title")
        description = try row.get("description")
        release_date = try row.get("release_date")
        age_rating = try row.get("age_rating")
        genre = try row.get("genre")
    }

    // Serializes the Show to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("description", description)
        try row.set("release_date", release_date)
        try row.set("age_rating", age_rating)
        try row.set("genre", genre)
        return row
    }
}

// MARK: Preparation
extension Show: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Shows
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("title")
            builder.string("description", length: 1000)
            builder.date("release_date")
            builder.int("age_rating")
            builder.int("genre")
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSONConvertible
extension Show: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            title: json.get("title"),
            description: json.get("description"),
            release_date: json.get("release_date"),
            age_rating: json.get("age_rating"),
            genre: json.get("genre")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("title", title)
        try json.set("description", description)
        try json.set("release_date", release_date)
        try json.set("age_rating", age_rating)
        try json.set("genre", genre)
        try json.set("seasons", makeSeasonsJSON(seasons: seasons.all()))
        return json
    }

    func makeSeasonsJSON(seasons: [Season]) throws -> [JSON] {
      var seasonsJSON = [JSON]()
      for season in seasons {
          seasonsJSON.append(try season.makeJSON())
      }
      return seasonsJSON
    }
}

// MARK: HTTP
extension Show: ResponseRepresentable { }

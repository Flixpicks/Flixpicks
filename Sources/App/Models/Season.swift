//
//  Season.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/5/17.
//
//

import Vapor
import FluentProvider
import HTTP

final class Season: Model {
    let storage = Storage()

    /// The content of the Season
    var show_id: Int
    var season_num: Int
    var description: String
    var release_date: Date
    var episodes: Children<Season, Episode> {
        return children()
    }

    /// Creates a new Season
    init(show_id: Int, season_num: Int, description: String, release_date: Date) {
        self.show_id = show_id
        self.season_num = season_num
        self.description = description
        self.release_date = release_date
    }

    // MARK: Fluent Serialization

    /// Initializes the Season from the
    /// database row
    init(row: Row) throws {
        show_id = try row.get("show_id")
        season_num = try row.get("season_num")
        description = try row.get("description")
        release_date = try row.get("release_date")
    }

    // Serializes the Season to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("show_id", show_id)
        try row.set("season_num", season_num)
        try row.set("description", description)
        try row.set("release_date", release_date)
        return row
    }
}

// MARK: Preparation
extension Season: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Seasons
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int("season_num")
            builder.string("description", length: 1000)
            builder.date("release_date")
            builder.parent(Show.self, optional: false)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSONConvertible
extension Season: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            show_id: json.get("show_id"),
            season_num: json.get("season_num"),
            description: json.get("description"),
            release_date: json.get("release_date")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("show_id", show_id)
        try json.set("season_num", season_num)
        try json.set("description", description)
        try json.set("release_date", release_date)
        try json.set("episodes", makeEpisodesJSON(episodes: episodes.all()))
        return json
    }

    func makeEpisodesJSON(episodes: [Episode]) throws -> [JSON] {
      var episodesJSON = [JSON]()
      for episode in episodes {
          episodesJSON.append(try episode.makeJSON())
      }
      return episodesJSON
    }
}

// MARK: HTTP
extension Season: ResponseRepresentable { }

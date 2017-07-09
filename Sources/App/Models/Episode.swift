//
//  Episode.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/5/17.
//
//

import Vapor
import FluentProvider
import HTTP

final class Episode: Model {
    let storage = Storage()

    /// The content of the Episode
    var season_id: Int
    var episode_num: Int
    var title: String
    var description: String
    var release_date: Date

    /// Creates a new Episode
    init(season_id: Int, episode_num: Int, title: String, description: String, release_date: Date) {
        self.season_id = season_id
        self.episode_num = episode_num
        self.title = title
        self.description = description
        self.release_date = release_date
    }

    // MARK: Fluent Serialization

    /// Initializes the Episode from the
    /// database row
    init(row: Row) throws {
        season_id = try row.get("season_id")
        episode_num = try row.get("episode_num")
        title = try row.get("title")
        description = try row.get("description")
        release_date = try row.get("release_date")
    }

    // Serializes the Episode to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("season_id", season_id)
        try row.set("episode_num", episode_num)
        try row.set("title", title)
        try row.set("description", description)
        try row.set("release_date", release_date)
        return row
    }
}

// MARK: Preparation
extension Episode: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Episodes
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int("episode_num")
            builder.string("title")
            builder.string("description", length: 1000)
            builder.date("release_date")
            builder.parent(Season.self, optional: false)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSONConvertible
extension Episode: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            season_id: json.get("season_id"),
            episode_num: json.get("episode_num"),
            title: json.get("title"),
            description: json.get("description"),
            release_date: json.get("release_date")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("season_id", season_id)
        try json.set("episode_num", episode_num)
        try json.set("title", title)
        try json.set("description", description)
        try json.set("release_date", release_date)
        return json
    }
}

// MARK: HTTP
extension Episode: ResponseRepresentable { }

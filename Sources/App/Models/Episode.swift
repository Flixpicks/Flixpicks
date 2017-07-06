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
    var showID: Int
    var seasonID: Int
    var episodeNum: Int
    var title: String
    var description: String
    var releaseDate: Date

    /// Creates a new Episode
    init(showID: Int, seasonID: Int, episodeNum: Int, title: String, description: String, releaseDate: Date) {
        self.showID = showID
        self.seasonID = seasonID
        self.episodeNum = episodeNum
        self.title = title
        self.description = description
        self.releaseDate = releaseDate
    }

    // MARK: Fluent Serialization

    /// Initializes the Episode from the
    /// database row
    init(row: Row) throws {
        showID = try row.get("showID")
        seasonID = try row.get("seasonID")
        episodeNum = try row.get("episodeNum")
        title = try row.get("title")
        description = try row.get("description")
        releaseDate = try row.get("releaseDate")
    }

    // Serializes the Episode to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("showID", showID)
        try row.set("seasonID", seasonID)
        try row.set("episodeNum", episodeNum)
        try row.set("title", title)
        try row.set("description", description)
        try row.set("releaseDate", releaseDate)
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
            builder.int("showID")
            builder.int("seasonID")
            builder.int("episodeNum")
            builder.string("title")
            builder.string("description")
            builder.date("releaseDate")
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
            showID: json.get("showID"),
            seasonID: json.get("showID"),
            episodeNum: json.get("episodeNum")
            title: json.get("title"),
            description: json.get("description"),
            releaseDate: json.get("releaseDate")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("showID", showID)
        try json.set("episodeNum", episodeNum)
        try json.set("title")
        try json.set("description")
        try json.set("releaseDate")
        return json
    }
}

// MARK: HTTP
extension Episode: ResponseRepresentable { }

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

    /// The content of the Movie
    var showID: Int
    var seasonNum: Int
    var title: String
    var description: String
    var releaseDate: Date

    /// Creates a new Movie
    init(showID: Int, seasonNum: Int, title: String, description: String, releaseDate: Date) {
        self.showID = showID
        self.seasonNum = seasonNum
        self.title = title
        self.description = description
        self.releaseDate = releaseDate
    }

    // MARK: Fluent Serialization

    /// Initializes the Season from the
    /// database row
    init(row: Row) throws {
        showID = try row.get("showID")
        seasonNum = try row.get("seasonNum")
        title = try row.get("title")
        description = try row.get("description")
        releaseDate = try row.get("releaseDate")
    }

    // Serializes the Season to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("showID", showID)
        try row.set("seasonNum", seasonNum)
        try row.set("title", title)
        try row.set("description", description)
        try row.set("releaseDate", releaseDate)
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
            builder.int("showID")
            builder.int("seasonNum")
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
extension Season: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            showID: json.get("showID"),
            seasonNum: json.get("seasonNum"),
            title: json.get("title"),
            description: json.get("description"),
            releaseDate: json.get("releaseDate")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("showID", showID)
        try json.set("seasonNum", seasonNum)
        try json.set("title", title)
        try json.set("description", description)
        try json.set("releaseDate", releaseDate)
        return json
    }
}

// MARK: HTTP
extension Season: ResponseRepresentable { }

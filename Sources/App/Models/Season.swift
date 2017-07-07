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
    var showID: Int
    var seasonNum: Int
    var description: String
    var releaseDate: Date

    /// Creates a new Season
    init(showID: Int, seasonNum: Int, description: String, releaseDate: Date) {
        self.showID = showID
        self.seasonNum = seasonNum
        self.description = description
        self.releaseDate = releaseDate
    }

    // MARK: Fluent Serialization

    /// Initializes the Season from the
    /// database row
    init(row: Row) throws {
        showID = try row.get("showID")
        seasonNum = try row.get("seasonNum")
        description = try row.get("description")
        releaseDate = try row.get("releaseDate")
    }

    // Serializes the Season to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("showID", showID)
        try row.set("seasonNum", seasonNum)
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
            description: json.get("description"),
            releaseDate: json.get("releaseDate")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("showID", showID)
        try json.set("seasonNum", seasonNum)
        try json.set("description", description)
        try json.set("releaseDate", releaseDate)
        return json
    }
}

// MARK: HTTP
extension Season: ResponseRepresentable { }

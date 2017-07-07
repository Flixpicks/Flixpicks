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
    var releaseDate: Date
    var ageRating: Int

    /// Creates a new Show
    init(title: String, description: String, releaseDate: Date, ageRating: Int) {
        self.title = title
        self.description = description
        self.releaseDate = releaseDate
        self.ageRating = ageRating
    }

    // MARK: Fluent Serialization

    /// Initializes the Show from the
    /// database row
    init(row: Row) throws {
        title = try row.get("title")
        description = try row.get("description")
        releaseDate = try row.get("releaseDate")
        ageRating = try row.get("ageRating")
    }

    // Serializes the Show to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("description", description)
        try row.set("releaseDate", releaseDate)
        try row.set("ageRating", ageRating)
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
            builder.string("description")
            builder.date("releaseDate")
            builder.int("ageRating")
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
            releaseDate: json.get("releaseDate"),
            ageRating: json.get("ageRating")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("title", title)
        try json.set("description", description)
        try json.set("releaseDate", releaseDate)
        try json.set("ageRating", ageRating)
        return json
    }
}

// MARK: HTTP
extension Show: ResponseRepresentable { }

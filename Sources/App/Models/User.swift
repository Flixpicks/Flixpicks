//
//  User.swift
//  flixpicks
//
//  Created by Camden Voigt on 7/1/17.
//
//

import Foundation
import FluentProvider
import AuthProvider

final class User: Model {
    /// General implementation should just be `let storage = Storage()`
    let storage = Storage()

    var name: String
    var email: String
    var password: String?
    
    
    init(name: String, email: String, password: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    init(row: Row) throws {
        self.name = try row.get("name")
        self.email = try row.get("email")
        self.password = try row.get("password")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("email", email)
        try row.set("password", password)
        return row
    }
}

// MARK: Preparation
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("email")
            builder.string("password")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSONConvertible
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            email: json.get("email")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("email", email)
        return json
    }
}

// MARK: HTTP
extension User: ResponseRepresentable {}

// MARK: PasswordAuthenticatable
extension User: PasswordAuthenticatable {
    var hashedPassword: String? {
        return password
    }
    
    public static var passwordVerifier: PasswordVerifier? {
        get { return _userPasswordVerifier }
        set { _userPasswordVerifier = newValue }
    }
}

// store private variable since storage in extensions
// is not yet allowed in Swift
private var _userPasswordVerifier: PasswordVerifier? = nil

// MARK: Persist Session
extension User: SessionPersistable {}

// MARK: Request
extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
    
    func jsonUser() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

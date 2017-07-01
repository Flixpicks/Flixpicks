//
//  Token.swift
//  flixpicks
//
//  Created by Camden Voigt on 7/1/17.
//
//

import Foundation
import FluentProvider
import Crypto

final class Token: Model {
    let storage = Storage()
    
    var token: String
    var userId: Identifier
    
    init(token: String, user: User) throws {
        self.token = token
        self.userId = try user.assertExists();
    }
    
    init(row: Row) throws {
        self.token = try row.get("token")
        self.userId = try row.get(User.foreignIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set(User.foreignIdKey, userId)
        return row
    }
}

// MARK: Convenience
extension Token {
    /// Generates a new token for the supplied User.
    static func generate(for user: User) throws -> Token {
        // generate 128 random bits using OpenSSL
        let random = try Crypto.Random.bytes(count: 16)
        
        // create and return the new token
        return try Token(token: random.base64Encoded.makeString(), user: user)
    }
}

// MARK: Relations
extension Token {
    /// Fluent relation for accessing the user
    var user: Parent<Token, User> {
        return parent(id: userId)
    }
}

// MARK: Preparation
extension Token: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(Token.self) { builder in
            builder.id()
            builder.string("token")
            builder.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(Token.self)
    }
}

// MARK: JSON
extension Token: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("token", token)
        return json
    }
}

// MARK: HTTP
/// Allows the Token to be returned directly in route closures.
extension Token: ResponseRepresentable { }

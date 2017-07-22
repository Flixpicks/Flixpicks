//
//  UserControllerTests.swift
//  flixpicks
//
//  Created by Camden Voigt on 7/19/17.
//
//

import XCTest
import Testing
import HTTP
import Sockets
@testable import Vapor
@testable import App

class UserControllerTests: TestCase {
    let drop = try! Droplet.testable()
    let hostname = "localhost"
    var registerId: Int?
    
    let registrationName = "Tester"
    let registrationEmail = "tester@test.com"
    let registrationPassword = "test"

    let id = 14
    let username = "Testy"
    let email = "Testy@test.com"
    let password = "test"
    
    let updatedName = "Bob"
    let updatedEmail = "bob@test.com"

    override func setUp() {
        super.setUp()
        self.registerId = nil
    }
    
    override func tearDown() {
        //delete newly registered user if it exists
        if let registerId = self.registerId {
            do {
                let _ = try drop.delete("/users/\(registerId)")
                self.registerId = nil
            } catch {
                print("error deleting registration user \(error)")
            }
        }
        
        super.tearDown()
    }
    
    func testRegister() throws {
        var json = JSON()
        try json.set("name", self.registrationName)
        try json.set("email", self.registrationEmail)
        try json.set("password", self.registrationPassword)
        
        try drop
            .testResponse(to: .post,
                          at: "register",
                          hostname: self.hostname,
                          headers: ["Content-Type":"application/json"],
                          body: json)
            .assertStatus(is: .ok, "Response did not have ok status")
            .assertJSON("id", passes: { (json: JSON) -> Bool in
                guard let id = json.int else {
                    return false
                }
                
                self.registerId = id
                return true
            })
            .assertJSON("name", equals: self.registrationName)
            .assertJSON("email", equals: self.registrationEmail)
    }
    
    func testLogin() throws {
        let utf8str = "\(email):\(password)".data(using: .utf8)
        let base64str = utf8str?.base64EncodedString()
        
        let headers = [HeaderKey("Authorization") : "Basic \(base64str?.string ?? "Bad base64Encoding")"]
        
        try drop
            .testResponse(to: .post,
                          at: "login",
                          hostname: self.hostname,
                          headers: headers,
                          body: nil)
            .assertStatus(is: .ok)
            .assertJSON("id", equals: id)
            .assertJSON("name", equals: username)
            .assertJSON("email", equals: email)
    }
    
    func testGetOne() throws {
        try drop
            .testResponse(to: .get,
                          at: "users/\(self.id)")
            .assertStatus(is: .ok)
            .assertJSON("id", equals: self.id)
            .assertJSON("name", equals: self.username)
            .assertJSON("email", equals: self.email)
    }
    
    func testGetAll() throws {
        try drop
            .testResponse(to: .get, at: "users")
            .assertStatus(is: .ok)
    }
    
    func testPatch() throws {
        // Change it
        var json = JSON()
        try json.set("name", self.updatedName)
        try json.set("email", self.updatedEmail)
        
        try drop
            .testResponse(to: .patch,
                          at: "users/\(self.id)",
                          hostname: self.hostname,
                          headers: ["Content-Type":"application/json"],
                          body: json)
            .assertStatus(is: .ok)
        
        //change it back
        json = JSON()
        try json.set("name", self.username)
        try json.set("email", self.email)
        
        try drop
            .testResponse(to: .patch,
                          at: "users/\(self.id)",
                hostname: self.hostname,
                headers: ["Content-Type":"application/json"],
                body: json)
            .assertStatus(is: .ok)
    }
    
    func testDelete() throws {
        //Register
        var json = JSON()
        try json.set("name", self.registrationName)
        try json.set("email", self.registrationEmail)
        try json.set("password", self.registrationPassword)
        
        var regId = 0
        
        try drop
            .testResponse(to: .post,
                          at: "register",
                          hostname: self.hostname,
                          headers: ["Content-Type":"application/json"],
                          body: json)
            .assertStatus(is: .ok, "Response did not have ok status")
            .assertJSON("id", passes: { (json: JSON) -> Bool in
                guard let id = json.int else {
                    return false
                }
                
                regId = id
                return true
            })
            .assertJSON("name", equals: self.registrationName)
            .assertJSON("email", equals: self.registrationEmail)
        
        //Delete
        try drop
            .testResponse(to: .delete, at: "users/\(regId)")
            .assertStatus(is: .ok)
    }
}

// MARK: Manifest
extension UserControllerTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
            ("testRegisterUser", testRegister),
            ("testLoginUser", testLogin),
            ("testGetOneUser", testGetOne),
            ("testGetAllUsers", testGetAll),
            ("testPatchUser", testPatch),
            ("testDeleteUser", testDelete)
        ]
}

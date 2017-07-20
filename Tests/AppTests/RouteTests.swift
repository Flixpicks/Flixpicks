import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

/// This file shows an example of testing
/// routes through the Droplet.

class RouteTests: TestCase {
    let drop = try! Droplet.testable()
    let hostname = "localhost"
    
    var registerId: Int?
    
    override func setUp() {
        super.setUp()
        self.registerId = nil
    }
    
    override func tearDown() {
        //delete newly registered user if it exists
        if let registerId = self.registerId {
            do {
                let _ = try drop.delete("/users/\(registerId)")
            } catch {
                print("error deleting registration user \(error)")
            }
        }
            
        super.tearDown()
    }

    func testHello() throws {
        try drop
            .testResponse(to: .get, at: "hello")
            .assertStatus(is: .ok)
            .assertJSON("hello", equals: "world")
    }

    func testInfo() throws {
        try drop
            .testResponse(to: .get, at: "info")
            .assertStatus(is: .ok)
            .assertBody(contains: "0.0.0.0")
    }
    
    func testRegister() throws {
        let name = "Tester"
        let email = "Tester@test.com"
        let password = "test"
        
        var json = JSON()
        try json.set("name", name)
        try json.set("email", email)
        try json.set("password", password)
        
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
            .assertJSON("name", equals: name)
            .assertJSON("email", equals: email)
    }
    
    func testLogin() throws {
        let id = 14
        let name = "Testy"
        let email = "Testy@test.com"
        let password = "test"
        
        let utf8str = "\(email):\(password)".data(using: .utf8)
        let base64str = utf8str?.base64EncodedString()
        
        let headers = [HeaderKey("Authorization") : "Basic \(base64str?.string ?? "Bad base64Encoding")"]
        
        try drop
            .testResponse(to: .post,
                          at: "login",
                          hostname: self.hostname,
                          headers: headers,
                          body: nil)
            .assertJSON("id", equals: id)
            .assertJSON("name", equals: name)
            .assertJSON("email", equals: email)
    }
}

// MARK: Manifest

extension RouteTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testHello", testHello),
        ("testInfo", testInfo),
    ]
}

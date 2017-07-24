//
//  AuthenticationTestProtocol.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/22/17.
//
//

import XCTest
import Testing
import HTTP
import Sockets
import Sessions
import Cookies
import AuthProvider
@testable import Vapor
@testable import App

class AuthenticationTestCase: TestCase {
    let drop = try! Droplet.testable()
    let hostname = "localhost"
    var middleWare: [Middleware] = []
    var sessionCookie: Cookie? = nil

    override func setUp() {
        super.setUp()
        do {
            try login()
        } catch {
            XCTFail("Login failed")
        }
    }

    private func login() throws {
        let memory = MemorySessions()
        middleWare = [
            SessionsMiddleware(memory),
            PersistMiddleware(User.self),
            PasswordAuthenticationMiddleware(User.self)
        ]

        let email = "Testy@test.com"
        let password = "test"

        let utf8str = "\(email):\(password)".data(using: .utf8)
        let base64str = utf8str?.base64EncodedString()
        let headers = [HeaderKey("Authorization") : "Basic \(base64str?.string ?? "Bad base64Encoding")"]

        let loginResponse = try drop.post("login",
                                          headers,
                                          nil,
                                          through:middleWare)

        let rawCookie = loginResponse.headers[HeaderKey.setCookie]
        sessionCookie = try Cookie(bytes: rawCookie?.bytes ?? [])
    }
}

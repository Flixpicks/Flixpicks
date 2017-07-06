//
//  RequestExtension.swift
//  flixpicks
//
//  Created by Logan Heitz on 7/5/17.
//
//

import Vapor
import HTTP


// MARK: Request
extension Request {
    func json() throws -> JSON {
        guard let bytes = body.bytes else { throw Abort.badRequest }
        return try JSON(bytes: bytes)
    }
}

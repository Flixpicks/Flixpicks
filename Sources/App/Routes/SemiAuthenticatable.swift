//
//  SemiAuthenticatable.swift
//  flixpicks
//
//  Created by Camden Voigt on 7/22/17.
//
//

import Vapor

protocol SemiAuthenticatable: Controller {
    func setupUnauthenticatedRoutes(builder: RouteBuilder) throws
    func setupAuthenticatedRoutes(authed: RouteBuilder) throws
}

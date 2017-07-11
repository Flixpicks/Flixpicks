//
//  UserController.swift
//  flixpicks
//
//  Created by Camden Voigt on 7/1/17.
//
//

import Vapor
import HTTP

final class UserController {
    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    func show(request: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    func update(request: Request, user: User) throws -> ResponseRepresentable {
        //TODO: figure out how to change password
        let new = try request.jsonUser()
        user.name = new.name
        user.email = new.email
        try user.save()
        return Response(status: .ok)
    }
    
    func delete(request: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .ok)
    }
}

extension UserController: ResourceRepresentable {
    func makeResource() -> Resource<User> {
        return Resource(index: index,
                        show: show,
                        update: update,
                        destroy: delete,
                        clear: clear)
    }
}

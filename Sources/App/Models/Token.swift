//
//  Token.swift
//  TILAppPackageDescription
//
//  Created by Imhoisili Otokhagua on 15/03/2018.
//

import Foundation

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

import Vapor
import FluentMySQL

extension Token: MySQLUUIDModel {}
extension Token: Content{}
extension Token: Migration{}

extension Token {
    var user: Parent<Token, User> {
        return parent(\.userID)
    }
}

import Crypto

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = OSRandom().data(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

import Authentication

extension Token: Authentication.Token {
    typealias UserType = User
    static let userIDKey: UserIDKey = \Token.userID
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}

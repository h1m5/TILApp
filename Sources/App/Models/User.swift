import Foundation

final class User: Codable {
    var id: UUID?
    var name: String = ""
    var username: String = ""
    var password: String = ""
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(name: String, username: String) {
            self.name = name
            self.username = username
        }
    }
}

import Vapor
import FluentMySQL

extension User: MySQLUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.creatorID)
    }
}

import Authentication

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User.Public: MySQLUUIDModel {
    static let entity = User.entity
}

extension User.Public: Content{}
extension User.Public: Parameter{}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}

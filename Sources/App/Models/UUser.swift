
import Foundation
import Vapor
import FluentMySQL

final class UUser: Codable {
    var id: UUID?
    var deviceToken: String = ""
    var udid: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id, udid
        case deviceToken = "device_token"
    }
}

extension UUser: MySQLUUIDModel {}
extension UUser: Content {}
extension UUser: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return UUser.Database.create(UUser.self, on: connection) { builder in
            try builder.field(for: \.id)
            try builder.field(for: \.deviceToken)
            try builder.field(for: \.udid)
        }
    }
}
extension UUser: Parameter {}

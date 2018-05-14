
import Vapor

struct UUserController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "uusers")
        usersRoute.get(use: getAllHandler)
        usersRoute.get(UUser.parameter, use: getUserHandler)
        usersRoute.post(use: createUserHandler)
        usersRoute.put(UUser.parameter, use: editUserHandler)
    }
    
    func createUserHandler(_ req: Request) throws -> Future<UUser> {
        return try req.content.decode(UUser.self).flatMap(to: UUser.self) { user in
            UUser.query(on: req).filter(\.udid, in: [user.udid]).all().flatMap(to: UUser.self) { all in
                if all.isEmpty {
                    return user.save(on: req)
                } else {
                    all[0].deviceToken = user.deviceToken
                    return all[0].save(on: req)
                }
            }
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[UUser]> {
        return UUser.query(on: req).all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<UUser> {
        return try req.parameter(UUser.self)
    }
    
    func editUserHandler(_ req: Request) throws -> Future<UUser> {
        return try flatMap(to: UUser.self, req.parameter(UUser.self), req.content.decode(UUser.self)) { (user, updatedUser) in
            user.deviceToken = updatedUser.deviceToken
            return user.save(on: req)
        }
    }
}

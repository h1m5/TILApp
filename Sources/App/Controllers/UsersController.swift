
import Vapor
import Authentication

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.Public.parameter, use: getUserHandler)
        usersRoute.post(use: createUserHandler)
        usersRoute.delete(User.parameter, use: deleteUserHandler)
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
        usersRoute.put(User.Public.parameter, use: editUserHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptVerifier())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
    }
    
    func createUserHandler(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap(to: User.self) { user in
            let hasher = try req.make(BCryptHasher.self)
            user.password = try hasher.make(user.password)
            return user.save(on: req)
        }
    }

    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.Public.query(on: req).all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameter(User.Public.self)
    }
    
    func deleteUserHandler(_ req: Request) throws ->Future<HTTPStatus> {
        return try req.parameter(User.self).flatMap(to: HTTPStatus.self) { (user) in
            return user.delete(on: req).transform(to: .noContent)
        }
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameter(User.self).flatMap(to: [Acronym].self) { user in
            return try user.acronyms.query(on: req).all()
        }
    }
    
    func editUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try flatMap(to: User.Public.self, req.parameter(User.Public.self), req.content.decode(User.Public.self)) { user, updatedUser in
            user.name = updatedUser.name
            user.username = updatedUser.username
            return user.save(on: req)
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
}

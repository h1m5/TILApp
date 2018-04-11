import Vapor
import Leaf
import Authentication

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        authSessionRoutes.get(use: indexHandler)
        authSessionRoutes.get("users", use: allUsersHandler)
        authSessionRoutes.get("categories", use: allCategoriesHandler)
        authSessionRoutes.get("acronyms", Acronym.parameter, use: acronymHandler)
        authSessionRoutes.get("user", User.parameter, use: userHandler)
        authSessionRoutes.get("category", Category.parameter, use: categoryHandler)
        authSessionRoutes.get("login", use: loginHandler)
        authSessionRoutes.post("login", use: loginPostHandler)
        authSessionRoutes.get("signup", use: signupHandler)
        authSessionRoutes.post("signup", use: signupPostHandler)
        
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        protectedRoutes.get("create-acronym", use: createAcronymHandler)
        protectedRoutes.post("create-acronym", use: createAcronymPostHandler)
        protectedRoutes.get("acronyms", Acronym.parameter, "edit", use: editAcronymHandler)
        protectedRoutes.post("acronyms", Acronym.parameter, "edit", use: editAcronymPostHandler)
        protectedRoutes.post("acronyms", Acronym.parameter, "delete", use: delteAcronymHandler)
        
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            let context = IndexContent(title: "Homepage", acronyms: acronyms.isEmpty ? nil : acronyms)
            return try req.leaf().render("index", context)
        }
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameter(Acronym.self).flatMap(to: View.self) { acronym in
            return acronym.creator.get(on: req).flatMap(to: View.self) { creator in
                return try acronym.categories.query(on: req).all().flatMap(to: View.self) { categories in
                    let context = AcronymContext(title: acronym.long, acronym: acronym, creator: creator, categories: categories.isEmpty ? nil : categories)
                    return try req.leaf().render("acronym", context)
                }
            }
        }
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameter(User.self).flatMap(to: View.self) { user in
            return try user.acronyms.query(on: req).all().flatMap(to: View.self) { acronyms in
                let context = UserContext(title: user.name, user: user, acronyms: acronyms.isEmpty ? nil : acronyms)
                return try req.leaf().render("user", context)
            }
        }
    }
    
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            let context = UsersContext(title: "All Users", users: users)
            return try req.leaf().render("users", context)
        }
    }
    
    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        return Category.query(on: req).all().flatMap(to: View.self) { categories in
            let context = CategoriesContext(title: "All Categories", categories: categories)
            return try req.leaf().render("categories", context)
        }
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameter(Category.self).flatMap(to: View.self) { category in
            return try category.acronyms.query(on: req).all().flatMap(to: View.self) { acronyms in
                let context = CategoryContext(title: category.name, acronyms: acronyms.isEmpty ? nil : acronyms)
                return try req.leaf().render("category", context)
            }
        }
    }
    
    func createAcronymHandler(_ req: Request) throws -> Future<View> {
        let context = CreateAcronymContext(title: "Create An Acronym")
        return try req.leaf().render("createAcronym", context)
    }
    
    func createAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(AcronymPostData.self).flatMap(to: Response.self) { data in
            let user = try req.requireAuthenticated(User.self)
            let acronym = try Acronym(short: data.acronymShort, long: data.acronymLong, creatorID: user.requireID())
            return acronym.save(on: req).map(to: Response.self) { acronym in
                guard let id = acronym.id else {
                    return req.redirect(to: "/")
                }
                return req.redirect(to: "/acronyms/\(id)")
            }
        }
    }
    
    func editAcronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameter(Acronym.self).flatMap(to: View.self) { acronym in
            let context = EditAcronymContext(title: "Edit Acronym", acronym: acronym)
            return try req.leaf().render("createAcronym", context)
        }
    }
    
    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self, req.parameter(Acronym.self), req.content.decode(AcronymPostData.self)) { acronym, data in
            acronym.short = data.acronymShort
            acronym.long = data.acronymLong
            acronym.creatorID = try req.requireAuthenticated(User.self).requireID()
            
            return acronym.save(on: req).map(to: Response.self) { acronym in
                guard let id = acronym.id else {
                    return req.redirect(to: "/")
                }
                return req.redirect(to: "/acronyms/\(id)")
            }
        }
    }
    
    func delteAcronymHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameter(Acronym.self).flatMap(to: Response.self) { acronym in
            return acronym.delete(on: req).transform(to: req.redirect(to: "/"))
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context = LoginContext(title: "Log Innn")
        return try req.leaf().render("login", context)
    }
    
    func loginPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(LoginPostData.self).flatMap(to: Response.self) { data in
            let verifier = try req.make(BCryptVerifier.self)
            return User.authenticate(username: data.username, password: data.password, using: verifier, on: req).map(to: Response.self) { user in
                guard let user = user else {
                    return req.redirect(to: "/login")
                }
                try req.authenticateSession(user)
                return req.redirect(to: "/")
            }
        }
    }
    
    func signupHandler(_ req: Request) throws -> Future<View> {
        let context = SignupContext(title: "Sign Up")
        return try req.leaf().render("signup", context)
    }
    
    func signupPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(SignupPostData.self).flatMap(to: Response.self) { data in
            guard data.password != "", data.password == data.password2 else {
                return Future<Response>.init(req.redirect(to: "/signup"))
            }
            let hasher = try req.make(BCryptHasher.self)
            let hashedPassword = try hasher.make(data.password)
            let user = User(name: data.name, username: data.username, password: hashedPassword)
            return user.save(on: req).map(to: Response.self, { user in
                try req.authenticateSession(user)
                return req.redirect(to: "/")
            })
        }
    }
}

extension Request {
    func leaf() throws -> LeafRenderer {
        return try self.make(LeafRenderer.self)
    }
}

struct SignupPostData: Content {
    let name: String
    let username: String
    let password: String
    let password2: String
}

struct SignupContext: Encodable {
    let title: String
}

struct LoginContext: Encodable {
    let title: String
}

struct LoginPostData: Content {
    let username: String
    let password: String
}

struct CategoryContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct CategoriesContext: Encodable {
    let title: String
    let categories: [Category]
}

struct UsersContext: Encodable {
    let title: String
    let users: [User]
}

struct IndexContent: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let creator: User
    let categories: [Category]?
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]?
}

struct CreateAcronymContext: Encodable {
    let title: String
}

import Foundation

struct AcronymPostData: Content {
    static let defaultMediaType = MediaType.urlEncodedForm
    let acronymLong: String
    let acronymShort: String
}

struct EditAcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let editing = true
}

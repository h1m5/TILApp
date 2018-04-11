import FluentMySQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
//    let corsConfig = CORSMiddleware.Configuration(allowedOrigin: .originBased, allowedMethods: [.get, .post, .put, .delete, .options], allowedHeaders: ["Accept", "Authoriaztion", "Origin"])
//    middlewares.use(CORSMiddleware(configuration: corsConfig))
    
    services.register(middlewares)
    
    try services.register(AuthenticationProvider())
    
    // Configure a SQLite database
    var databases = DatabaseConfig()
    let database = MySQLDatabase(hostname: "localhost", user: "h1m5", password: "password", database: "vapor")
//    let database = MySQLDatabase(hostname: "localhost", user: "hims", password: "password", database: "hfeed")
    databases.add(database: database, as: .mysql)
    services.register(databases)
    
    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Acronym.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Category.self, database: .mysql)
    migrations.add(model: AcronymCategoryPivot.self, database: .mysql)
    migrations.add(model: Token.self, database: .mysql)
    services.register(migrations)
    
    User.Public.defaultDatabase = .mysql
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Configure the rest of your application here
}

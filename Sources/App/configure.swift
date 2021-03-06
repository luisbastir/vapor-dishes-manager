import FluentSQLite
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  /// Register providers first
  try services.register(FluentSQLiteProvider())

  // Config Leaf Renderer
  try services.register(LeafProvider())
  config.prefer(LeafRenderer.self, for: ViewRenderer.self)

  /// Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)

  /// Register middleware
  var middlewares = MiddlewareConfig() // Create _empty_ middleware config
  // Serves files from `Public/` directory
  middlewares.use(FileMiddleware.self)
  // Catches errors and converts to HTTP response
  middlewares.use(ErrorMiddleware.self)
  services.register(middlewares)

  // Configure a SQLite database
  let sqlite = try SQLiteDatabase(storage: .file(path: "database.sqlite"))

  /// Register the configured SQLite database to the database config.
  var databases = DatabasesConfig()
  databases.add(database: sqlite, as: .sqlite)
  services.register(databases)

  /// Configure migrations
  var migrations = MigrationConfig()
  migrations.add(model: Dish.self, database: .sqlite)
  migrations.add(model: Review.self, database: .sqlite)
  // migrations.add(migration: MigrationExample.self, database: .sqlite)
  services.register(migrations)

  // Configure port
  let serverConfiure = NIOServerConfig.default(hostname: "0.0.0.0", port: 3000)
  services.register(serverConfiure)

}

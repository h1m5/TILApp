
import Foundation
import Vapor

struct NewsController: RouteCollection {
    func boot(router: Router) throws {
        let newsRouter = router.grouped("api", "news")
        newsRouter.get(use: getNewsHandler)
    }

    func getNewsHandler(_ req: Request) throws -> Future<[NewsArticle]> {
        return NewsAPI.shared.fetchNews()
    }
}

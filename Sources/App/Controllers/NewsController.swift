
import Vapor

struct NewsController: RouteCollection {
    func boot(router: Router) throws {
        let newsRouter = router.grouped("api", "news")
//        newsRouter.get(use: getNewsHandler)
    }

//    func getNewsHandler(_ req: Request) throws -> Future<[NewsArticle]> {
//
//        let client = try req.make(Client.self)
//        return client.get(NewsAPI.url).flatMap(to: [NewsArticle].self) { response in
//            do {
//                guard let resp = response.result,
//                    let data = resp.http.body.data else { return req.}
//
//            } catch {
//                print(error)
//            }
//        }
//
//    }
}

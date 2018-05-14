import Foundation
import Vapor
import PerfectHTTPServer

final class NewsAPI {
    static let shared = NewsAPI()
    private init(){}
    
    let baseURL = "https://newsapi.org/v2/top-headlines?sources=four-four-two"
    let apiKey = "c75c72d07f9d4aba92b803d09ee723e0"
    var app: Application!
    
    var url: String {
        get {
            return baseURL + "&apiKey=\(apiKey)"
        }
    }
    
    func start(_ app: Application) {
        self.app = app
    }
    
    func fetchNews() -> Future<[NewsArticle]> {
        do {
            let client = try app.make(Client.self)
            return client.get(url).flatMap(to: [NewsArticle].self) { (response) in
                return try response.content.decode([NewsArticle].self).flatMap(to: [NewsArticle].self) { articles in
                    print(articles.count)
                    return Future<[NewsArticle]>(articles)
                }
            }
        } catch {
            print(error)
            return Future<[NewsArticle]>([])
        }
    }

    
        
//        let data = Data.init(bytes: bytes)
//    }
}


import Vapor
//import PerfectHTTP

final class NewsAPI {
    static let baseURL = "https://newsapi.org/v2/top-headlines?sources=four-four-two"
    static let apiKey = "c75c72d07f9d4aba92b803d09ee723e0"
    
    static var url: String {
        get {
            return baseURL + "&apiKey=\(apiKey)"
        }
    }
}

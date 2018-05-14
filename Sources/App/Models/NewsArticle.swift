
import Vapor
import FluentMySQL

final class NewsArticle: Codable {
    
    var id: Int?
    var author: String = ""
    var title: String = ""
    var description: String = ""
    var url: String = ""
    var urlToImage: String = ""
    var publishedAt: String = ""
    
    init(author: String, title: String, description: String, url: String, urlToImage: String, publishedAt: String) {
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
    }
    
    func asDictionary() -> [String : Any] {
        return [
            "id" : self.id ?? -1,
            "author" : self.author,
            "title" : self.title,
            "description" : self.description,
            "url" : self.url,
            "urlToImage" : self.urlToImage,
            "publishedAt" : self.publishedAt,
        ]
    }
    
}


extension NewsArticle: MySQLModel {}
extension NewsArticle: Content {}
extension NewsArticle: Migration {}
extension NewsArticle: Parameter {}

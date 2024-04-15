//
//  DataModels.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftData
import SwiftUI

@Model
class User {
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

@Model
class Country: Codable {
    enum CodingKeys: CodingKey {
        case country, code
    }
    
    var country: String
    var code: String
    
    init(country: String, code: String) {
        self.country = country
        self.code = code
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        country = try container.decode(String.self, forKey: .country)
        code = try container.decode(String.self, forKey: .code)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(country, forKey: .country)
        try container.encode(code, forKey: .code)
    }
}

struct BookApiResponse:Codable{
    var docs:[Books]
}

@Model
class Books: Codable {
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case ratingsAverage = "ratings_average"
        case ratingsCount = "ratings_count"
        case authorName = "author_name"
        case coverImage = "cover_i"
    }
    
    var title:String
    var ratingsAverage:Double
    var ratingsCount:Int
    var authorName:[String]
    var coverImage:Int
    
    init (title:String,ratingsAverage:Double,ratingsCount:Int,authorName:[String],coverImage:Int){
        self.title = title
        self.ratingsCount = ratingsCount
        self.ratingsAverage = ratingsAverage
        self.coverImage = coverImage
        self.authorName = authorName
        
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        ratingsAverage = try container.decodeIfPresent(Double.self, forKey: .ratingsAverage) ?? 0.0
        ratingsCount = try container.decodeIfPresent(Int.self, forKey: .ratingsCount) ?? 0
        authorName = try container.decodeIfPresent([String].self, forKey: .authorName) ?? []
        coverImage = try container.decodeIfPresent(Int.self, forKey: .coverImage) ?? 0
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(ratingsAverage, forKey: .ratingsAverage)
        try container.encode(ratingsCount, forKey: .ratingsCount)
        try container.encode(authorName, forKey: .authorName)
        try container.encode(coverImage, forKey: .coverImage)
    }
}

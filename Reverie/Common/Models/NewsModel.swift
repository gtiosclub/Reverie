//
//  NewsModel.swift
//  Reverie
//
//  Created by Admin on 9/18/25.
//
import Foundation

class NewsModel  {
    var title: String
    var author: String
    var content: String
    var url: String
    var tags: [String]
    var date: Date





    init(title: String, author: String, content: String, url: String , tags: [String], date: Date) {
        
        self.title = title
        self.author = author
        self.content = content
        self.url = url
        self.tags =  tags
        self.date = date
    }


}


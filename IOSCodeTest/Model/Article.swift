//
//  Article.swift
//  IOSCodeTest
//
//  Created by iMyanmarHouse on 11/2/23.
//

import Foundation

struct Article: Decodable{
    let id: Int
    let article_category_id: Int
    let title: String
    let content: String

   enum CodingKeys: String, CodingKey {
       case id, article_category_id, title, content
   }
}

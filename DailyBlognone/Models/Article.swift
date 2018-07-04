//
//  Article.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import AEXML

struct Article {
    let title: String
    let link: URL
    let description: String
    let pubDate: Date
    let creator: String
}

extension Article {
    init?(xml: AEXMLElement) {
        self.title = xml["title"].string
        guard let url = URL(string: xml["link"].string) else { return nil }
        self.link = url
        self.description = xml["description"].string
        guard let date = xml["pubDate"].string.toDateFromAPI() else { return nil }
        self.pubDate = date
        self.creator = xml["dc:creator"].string
    }
}

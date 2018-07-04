//
//  Date.swift
//  DailyBlognone
//
//  Created by Wirawit Rueopas on 4/7/18.
//

import Foundation

private extension Date {
    static let standardLocalDateFormat = "E, d MMM yyyy, HH:mm"
    static let dateFromAPIStringFormatter = createDateFromAPIStringFormatter()
    static let localDateFormatter = createLocalDateFormatter(format: standardLocalDateFormat)

    static func createDateFromAPIStringFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        f.timeZone = TimeZone(abbreviation: "UTC")
        return f
    }

    static func createLocalDateFormatter(format: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone = TimeZone.current
        f.locale = Locale.current
        return f
    }
}

extension Date {
    func toLocal() -> String {
        return Date.localDateFormatter.string(from: self)
    }
}

extension String {
    func toDateFromAPI() -> Date? {
        return Date.dateFromAPIStringFormatter.date(from: self)
    }
}

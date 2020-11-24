//
//  ConvertExtensions.swift
//  MapPoints
//
//  Created by Artem Syritsa on 07.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import Foundation

extension Int {
    
    /// Convert time span to date
    func convertToDate() -> Date {
        let myTimeInterval = TimeInterval(self)
        let time: Date = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
        return time
    }
    
}

extension Date {
    
    func convertToUTCString(_ format: String = "yyyy/MM/dd") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC") // TimeZone.current
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    func convertToString(_ format: String = "yyyy/MM/dd") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    func convertToTimeSpan() -> Int {
        Int(self.timeIntervalSince1970)
    }
    
}

extension Data {
    
    func convertToClass<T>(_ classType: T.Type) -> T? where T: Codable {
        return try? JSONDecoder().decode(T.self, from: self)
    }
    
    func convertToClass<T>(_ classType: [T.Type]) -> [T]? where T: Codable {
            return try? JSONDecoder().decode([T].self, from: self)
    }
    
    func convertFromSnakeCaseToClass<T>(_ classType: [T.Type]) -> [T]? where T: Codable {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        /*decoder.keyDecodingStrategy = .custom { keys -> CodingKey in
         let key = keys.last!.stringValue.split(separator: "_").joined()
         return Currency.CodingKeys.init(stringValue: String(key))!
         }*/
        
        return try? decoder.decode([T].self, from: self)
    }
    
}

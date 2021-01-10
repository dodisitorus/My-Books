//
//  ConvertData.swift
//  MyBooks
//
//  Created by Dodi Sitorus on 09/01/21.
//

import Foundation

class ConvertData: NSObject {
    
    static func jsonFormat_V2(from: Data, completion: ([[String: Any]]?) -> ()) {
        do {
            let jsonObject =  try JSONSerialization.jsonObject(with: from, options: .allowFragments)
            
            if let jsonArray = jsonObject as? [[String: Any]] {
                completion(jsonArray)
            } else if let jsonArray = jsonObject as? [String: Any] {
                completion([jsonArray])
            } else {
                completion([])
            }
        } catch let err {
            print(err)
        }
    }
}

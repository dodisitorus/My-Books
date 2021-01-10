//
//  ErrorService.swift
//  MyBooks
//
//  Created by Dodi Sitorus on 09/01/21.
//

import Foundation

class ErrorService: NSObject {
    
    var localizedDescription: String
    var errorCode: Int
    
    init(message: String, code: Int) {
        self.localizedDescription = message
        self.errorCode = code
    }
}

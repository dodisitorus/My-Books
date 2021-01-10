//
//  Service.swift
//  MyBooks
//
//  Created by Dodi Sitorus on 09/01/21.
//

import Foundation
import Alamofire

class Service: NSObject {
    
    static var mainUrl: String = "http://apitesting.incenplus.com/"
    
    // return URL from string url
    static func ApiURL(string: String) -> URL {
        let baseUrl = Service.mainUrl
        
        return URL(string: baseUrl + string)!
    }
    
    // fetch data using Alamofire
    static func Alamofire_JSON(vc: UIViewController, urlString: String, method: String, token: String = "", body: [String: Any] = [:], completionHandler: @escaping ([[String: Any]]?, ErrorService?) -> ()) {
        
        let url = Service.ApiURL(string: urlString)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if token != "" {
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        
        if body.count != 0 {
            do {
                request.httpBody =  try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            } catch let err {
                print(err)
            }
        }
        
        AF.request(request).validate().responseJSON { (response) in
            
            if response.error?.responseCode == 403 {
                
                let err: ErrorService = ErrorService(message: "", code: 403)
                
                completionHandler(nil, err)
            }
            
            if let data = response.data {
                
                ConvertData.jsonFormat_V2(from: data) { (json) in
                    
                    if response.error != nil {
                        
                        if let JSON: [String: Any] = json?[0] {
                            
                            let errorJSON: [String: Any] = JSON["error"] as? [String: Any] ?? [:]
                            
                            let err: ErrorService = ErrorService(message: errorJSON["message"] as? String ?? "", code: errorJSON["status_code"] as? Int ?? 0)
                            
                            completionHandler(nil, err)
                        }
                        
                    } else if let jsonArray = response.value as? [[String: Any]] {
                        completionHandler(jsonArray, nil)
                    } else if let jsonArray = response.value as? [String: Any] {
                        completionHandler([jsonArray], nil)
                    } else {
                        completionHandler([], nil)
                    }
                }
            }
        }
    }
    
    static func Alamofire_MultipartFormData(vc: UIViewController, urlString: String, token: String = "", parameters: [String: String], completionHandler: @escaping ([[String: Any]]?, Error?) -> ()) {
        
        let url = Service.ApiURL(string: urlString)
        
        let headers: HTTPHeaders = [
            "Content-type"  : "multipart/form-data",
            "Authorization" : "Bearer " + token
        ]
        
        AF.upload(multipartFormData: { (formData) in
            
            if parameters.count != 0 {
                for (key, value) in parameters {
                    formData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }
            
        }, to: url, method: .post, headers: headers)
        .responseJSON { (response) in
            if let error = response.error {
                completionHandler(nil, error)
            } else if let jsonArray = response.value as? [[String: Any]] {
                completionHandler(jsonArray, nil)
            } else if let jsonArray = response.value as? [String: Any] {
                completionHandler([jsonArray], nil)
            }
        }
    }
}

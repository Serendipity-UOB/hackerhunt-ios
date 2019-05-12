//
//  ServerUtils.swift
//  hackerhunt
//
//  Created by Louis Heath on 22/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation

class ServerUtils {
    
    static var testing : Bool = false
    
    static func post(to url: String, with json: [String: Any]) -> URLRequest {
        var newUrl: String
        if (testing == true) {
            newUrl = url + "Test"
        } else {
            newUrl = url
        }
        
        let urlObj = URL(string: "http://serendipity-game-controller.herokuapp.com"+newUrl)
        let httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 2.0
        return request
    }
    
    static func get(from url: String) -> URLRequest {
        var newUrl: String
        if (testing == true) {
            newUrl = url + "Test"
        } else {
            newUrl = url
        }
        
        let urlObj = URL(string: "http://serendipity-game-controller.herokuapp.com"+newUrl)
        
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "GET"
        request.timeoutInterval = 2.0
        
        return request
    }
    
}

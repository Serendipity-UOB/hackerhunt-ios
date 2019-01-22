//
//  ServerUtils.swift
//  hackerhunt
//
//  Created by Louis Heath on 22/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation

class ServerUtils {
    
    static func post(to url: String, with json: [String: Any]) -> URLRequest {
        
        let urlObj = URL(string: "http://serendipity-game-controller.herokuapp.com"+url)
        let httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    static func get(from url: String) -> URLRequest {
        
        let urlObj = URL(string: "http://serendipity-game-controller.herokuapp.com"+url)
        
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "GET"
        
        return request
    }
    
}

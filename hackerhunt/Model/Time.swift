//
//  Time.swift
//  hackerhunt
//
//  Created by Thomas Walker on 25/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation

func prettyTimeFrom(seconds: Int) -> String {
    let secs = seconds % 60
    let mins = (seconds / 60) % 60
    
    return NSString(format: "%0.2d:%0.2d",mins,secs) as String
}

func now() -> Double {
    let date = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)
    let currentTotal = Double(seconds + 60 * (minutes + 60 * hour))
    
    return currentTotal
}

func stringToDouble(time: String) -> Double {
    //"21:07:42.494"
    let timeArr = time.components(separatedBy: ":")
    let hour = Int(timeArr[0])
    let minute = Int(timeArr[1])
    let second = Int(Float(timeArr[2])!)
    let total = Double(second + 60 * (minute! + 60 * hour!))
    
    return total
}

func calculateTimeRemaining(startTime: String) -> Int {
    let currentTotal = now()
    let startTotal = stringToDouble(time: startTime)
    let diff : Int = Int(startTotal - currentTotal)
    
    return diff
}

func calculateEndTime(startTime: String) -> Int {
    let startTotal = stringToDouble(time: startTime)
    let minutes = 0.25
    
    return Int(startTotal + minutes * 60.0)
}

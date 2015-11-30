//
//  JSONParser.swift
//  Taxis
//
//  Created by Helton Rosa on 28/11/15.
//  Copyright © 2015 Helton Rosa. All rights reserved.
//

import Foundation

class JSONParser {
    static let LatitudeKey = "latitude"
    static let LongitudeKey = "longitude"
    static let DriverIdKey = "driverId"
    static let AvailabilityKey = "driverAvailable"
    
    
    static func parse(json: NSData?) -> [Taxi]?{
        var taxiArray = [Taxi]()
        do{
            if let json = try NSJSONSerialization.JSONObjectWithData(json!, options: NSJSONReadingOptions.MutableContainers) as? NSArray {
                let count = json.count
                for i in 0..<count {
                    if let taxiJSON = json.objectAtIndex(i) as? NSDictionary{
                        let taxi = Taxi(latitude: taxiJSON.objectForKey(LatitudeKey) as? Double ?? 0.0,
                        longitude: taxiJSON.objectForKey(LongitudeKey) as? Double ?? 0.0,
                            driverId: taxiJSON.objectForKey(DriverIdKey) as? Int ?? 0,
                            availability: taxiJSON.objectForKey(AvailabilityKey) as? Bool ?? false)
                        taxiArray.append(taxi)
                    }
                }
            }
        } catch{
            print("Parse JSON Failed")
        }
        return taxiArray
    }
}

//
//  TaxisModel.swift
//  Taxis
//
//  Created by Helton Rosa on 28/11/15.
//  Copyright © 2015 Helton Rosa. All rights reserved.
//

import Foundation
import MapKit

class Taxi: NSObject{
    
    var latitude: Double
    var longitude: Double
    var driverId: Int
    var availability: Bool
    
    init(latitude: Double,
        longitude:Double,
        driverId:Int,
        availability:Bool){
            self.latitude = latitude
            self.longitude = longitude
            self.driverId = driverId
            self.availability = availability
            
    }
}

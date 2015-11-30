//
//  MKTaxi.swift
//  Taxis
//
//  Created by Helton Rosa on 29/11/15.
//  Copyright © 2015 Helton Rosa. All rights reserved.
//

import MapKit

extension Taxi: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        get{
            return NSLocalizedString("Taxi", comment: "Callout pin text")  + ": " + String(driverId)
        }
    }
    var subtitle: String?{
        get
        {
            var str:String?
            if(availability){
                str = NSLocalizedString("Available", comment: "Message shown when the selected taxi is Available")
            } else {
                str = NSLocalizedString("Buzy", comment: "Message shown when the selected taxi is NOT Available")
            }
            return str
        }
    }
    
}

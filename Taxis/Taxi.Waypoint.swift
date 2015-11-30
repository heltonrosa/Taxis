//
//  Taxi.Waypoint.swift
//  Taxis
//
//  Created by Helton Rosa on 28/11/15.
//  Copyright © 2015 Helton Rosa. All rights reserved.
//

import MapKit

extension Taxi: MKAnnotation{
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
    }
    
    var title: String? { return String(driverId!) ?? ""}
    
    var subtitle: String? { return nil}
}
//
//  AppDelegate.swift
//  Taxis
//
//  Created by Helton Rosa on 28/11/15.
//  Copyright © 2015 Helton Rosa. All rights reserved.
//

import UIKit
import CoreLocation

struct GPXURL {
    static let Notification = "GPSURL  Radio Station"
    static let Key = "GPXURL URL Key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        // Override point for customization after application launch.
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: GPXURL.Notification, object: self, userInfo: [GPXURL.Key:url])
        center.postNotification(notification)
        return true
    }
    
}

    
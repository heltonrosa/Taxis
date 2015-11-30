//
//  TaxisModel.swift
//  Taxis
//
//  Created by Helton Rosa on 29/11/15.
//  Copyright © 2015 Helton Rosa. All rights reserved.
//

import Foundation

class TaxisModel {
    
    var jsonData: String?
    
    func getApproppriateURL(southLatitude: Double, westLongitude: Double, northLatitude:Double, eastLongitude: Double) -> NSURL?{
        let strUrl = "https://api.99taxis.com/lastLocations?"
        var str = strUrl + "sw=" + String(southLatitude) + "," + String(westLongitude)
        str += "&ne=" + String(northLatitude) + "," + String(eastLongitude)
        print(str)
        return NSURL(string: str)
    }
    
    func updateTaxis(sender: TaxisHandlerProtocol, southLatitude: Double, westLongitude: Double, northLatitude:Double, eastLongitude: Double){
        
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in
            var availableTaxis:[Taxi]!
            if let taxisData = NSData(contentsOfURL:self.getApproppriateURL(southLatitude,
                westLongitude: westLongitude, northLatitude: northLatitude, eastLongitude: eastLongitude)!){
                if let taxis = JSONParser.parse(taxisData){
                    availableTaxis = [Taxi]()
                    for taxi in taxis{
                        if taxi.availability == true {
                            availableTaxis.append(taxi)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        sender.handleTaxisResponse(availableTaxis)
                    }
                }
            }
        }
    }
}

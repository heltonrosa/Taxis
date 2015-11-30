//
//  ViewController.swift
//  Taxis
//
//  Created by Helton Rosa on 28/11/15.
//  Copyright © 2015 Helton Rosa. All rights reserved.
//

import UIKit
import MapKit


protocol TaxisHandlerProtocol{
    func handleTaxisResponse(_: [Taxi]?)
}

struct Messages{
    struct CommunicationFailed{
        static let Title = NSLocalizedString("Not connected", comment: "This occurs when user tries to fetch soma data from internet but he is not connected")
        static let Message = NSLocalizedString("It was not possible to retrieve any infomation from our servers. Please check your connections", comment: "Full message explanation")
    }
    
    struct NoTaxisAvailable{
        static let Title = NSLocalizedString("No taxi is available", comment: "This message is displayed when the system can't find any taxi on surroundings")
        static let Message = NSLocalizedString("The app could not find any taxi in our surroundings", comment: "Full message explanation")
    }
    static let DismissButton = "Ok"
}

class TaxisViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, TaxisHandlerProtocol{
    
    let defaultPinID = "com.evolvements.taxi.pin"
    let taxiPin = "taxi-yellow-xxl"
    let userPinID = "com.evolvements.user.pin"
    let userPin = "user_pin"
    let refreshingRateInMilliseconds = 5000
    let userLocationSpanDistance = 2000.0
    
    var model = TaxisModel()
    var timer: NSTimer?
    var userAskedForUpdate: Bool = false
    var isUpdatingLocation = false
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet{
            mapView.mapType = .Standard
            mapView.delegate = self
        }
    }
    
    @IBAction func changeMapType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0: mapView.mapType = MKMapType.Standard
        case 1: mapView.mapType = MKMapType.Satellite
        case 2: mapView.mapType = MKMapType.Hybrid
        default: break
        }
    }
    
    @IBAction func updateButtonPressed(sender: UIBarButtonItem) {
        stopRefreshingMap()
        userAskedForUpdate = true
        updateTaxis()
        startRefreshingMapwithMillisecondsIntervall(refreshingRateInMilliseconds)
    }
    
    func stopRefreshingMap(){
        timer?.invalidate()
    }
    
    func startRefreshingMapwithMillisecondsIntervall(intervall:Int) {
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(intervall/1000), target: self, selector: "updateTaxis", userInfo: nil, repeats: true)
    }
    
    @IBAction func sowUserLocationButtonPressed(sender: UIBarButtonItem) {
        showUserLocation()
    }
    
    func showUserLocation(){
        startUpdatingLocation()
        if let userLocation = mapView?.userLocation{
            if(userLocation.location != nil){
                let region = MKCoordinateRegionMakeWithDistance(
                    (userLocation.location?.coordinate)!, userLocationSpanDistance, userLocationSpanDistance)
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    // ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupMapView()
    }
    
    func setupNavigationBar(){
        self.title = NSLocalizedString("Taxis", comment: "App name title")
    }
    
    func setupMapView(){
        mapView.rotateEnabled = false
        mapView.pitchEnabled = false
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Nothig to release
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startRefreshingMapwithMillisecondsIntervall(refreshingRateInMilliseconds)
        startCoreLocationManager()
    }
    
    func startCoreLocationManager(){
        if (CLLocationManager.locationServicesEnabled())
        {
            let locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestAlwaysAuthorization()
            startUpdatingLocation()
        }
    }
    
    func startUpdatingLocation(){
        let locationManager = CLLocationManager()
        locationManager.startUpdatingLocation()
        isUpdatingLocation = true
    }
    
    func stopUpdatingLocation(){
        let locationManager = CLLocationManager()
        locationManager.stopUpdatingLocation()
        isUpdatingLocation = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshingMap()
        stopCoreLocationManager()
    }
    
    func stopCoreLocationManager(){
        stopUpdatingLocation()
    }
    
    // TaxisHandlerProtocol
    func handleTaxisResponse(taxisArray: [Taxi]?){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        clearWaypoints()
        if(taxisArray == nil){
            showButtonItemAlert(Messages.CommunicationFailed.Title, message: Messages.CommunicationFailed.Message)
        } else if taxisArray!.isEmpty && userAskedForUpdate{
            showButtonItemAlert(Messages.NoTaxisAvailable.Title, message: Messages.NoTaxisAvailable.Message)
        } else {
            self.handleWaypoints(taxisArray!)
        }
        if userAskedForUpdate{
            userAskedForUpdate = false
        }
    }
    
    private func clearWaypoints(){
        if mapView?.annotations != nil { mapView.removeAnnotations(mapView.annotations as [MKAnnotation]) }
    }
    
    func showButtonItemAlert(title: String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: Messages.DismissButton, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func handleWaypoints(taxis: [Taxi]){
        mapView.addAnnotations(taxis)
    }
        
    // MKMapViewDelegate
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        showUserLocation()
        if userLocation.location?.horizontalAccuracy <= 50.0{
            stopUpdatingLocation()
        }
    }
        
    func mapView( mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        updateTaxis()
    }
    
    func updateTaxis(){
        // Get corners of the map
        let nePoint = CGPointMake(self.mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
        let swPoint = CGPointMake((self.mapView.bounds.origin.x), (mapView.bounds.origin.y + mapView.bounds.size.height));
        
        // From corners of the map, get geolocation info
        let neCoord = mapView.convertPoint(nePoint, toCoordinateFromView: mapView)
        let swCoord = mapView.convertPoint(swPoint, toCoordinateFromView: mapView)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        model.updateTaxis(self, southLatitude: Double(swCoord.latitude), westLongitude: swCoord.longitude, northLatitude: neCoord.latitude , eastLongitude:neCoord.longitude )
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView:MKAnnotationView? = nil
        
        if annotation.isKindOfClass(MKUserLocation){
            pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(userPinID)
            if pinView == nil {
                pinView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: userPinID)
                pinView!.canShowCallout = true;
                pinView!.image = UIImage(named: userPin)
            }
            pinView!.annotation = annotation
        } else {
            pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(defaultPinID)
            if pinView == nil {
                pinView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: defaultPinID)
                pinView!.canShowCallout = true;
                pinView!.image = UIImage(named: taxiPin)
            }
            pinView!.annotation = annotation
        
        }
        return pinView;
    }
}


//
//  RiderVC.swift
//  Uber For Rider
//
//  Created by Emmanuel Erilibe on 1/26/17.
//  Copyright © 2017 Emmanuel Erilibe. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberControler {

    @IBOutlet weak var myMap: MKMapView!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    private var timer = Timer()
    
    private var canCallUber = true
    private var riderCanceledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.observeMessagesForRider()
        UberHandler.Instance.delegate = self
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            myMap.setRegion(region, animated: true)
            
            myMap.removeAnnotations(myMap.annotations)
            
            if driverLocation != nil {
                if !canCallUber {
                    let driverAnnotation  = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Driver Location"
                    myMap.addAnnotation(driverAnnotation)
                }
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Driver's Location"
            myMap.addAnnotation(annotation)
        }
    }
    
    func updateRidersLocation() {
        UberHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }

    func canCallUber(delegateCalled: Bool) {
        if delegateCalled {
            callUberBtnPressedAgain.setTitle("Cancel Uber", for: UIControlState.normal)
            canCallUber = false
        } else {
            callUberBtnPressedAgain.setTitle("Call Uber", for: UIControlState.normal)
            canCallUber = true
        }
    }
    
    @IBOutlet weak var callUberBtnPressedAgain: UIButton!
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        if !riderCanceledRequest {
            if requestAccepted {
                alertTheUser(title: "Uber Accepted", message: "\(driverName) accepted your request")
            } else {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                alertTheUser(title: "Uber Canceled", message: "\(driverName) canceld Uber request.")
            }
        }
        riderCanceledRequest = false
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    @IBAction func callUberBtnPressed(_ sender: Any) {
        if userLocation != nil {
            if canCallUber {
                UberHandler.Instance.requestUber(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(RiderVC.updateRidersLocation), userInfo: nil, repeats: true)
                
            } else {
                riderCanceledRequest = true
                UberHandler.Instance.cancelUber()
                // cancel Uber
                timer.invalidate()
            }
        }
    }

    @IBAction func logOutBtnPressed(_ sender: Any) {
        
        if AuthProvider.Instance.logOut() {
            if !canCallUber {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        } else {
            alertTheUser(title: "Could Not Logout", message: "We could not log out at the monment, please try again later")
        }
    }
    
    private func alertTheUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}

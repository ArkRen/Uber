//
//  RiderViewController.swift
//  Uber
//
//  Created by RenFangzhou on 8/28/17.
//  Copyright © 2017 RenFangzhou. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    
    var userLocation = CLLocationCoordinate2D()
    
    var driverLocation = CLLocationCoordinate2D()
    
    var uberHasBeenCalled = false
    
    var driverOnTheWay = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
        if let email = Auth.auth().currentUser?.email {
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                    
                    self.uberHasBeenCalled = true
                    
                    self.callUberButton.setTitle("Cancel Uber", for: .normal)
                    Database.database().reference().child("RideRequests").removeAllObservers()
                    
                    if let rideRequestDictionary = snapshot.value as? [String:Any] {
                        if let driverlat = rideRequestDictionary["driverlat"] as? Double {
                            if let driverlon = rideRequestDictionary["driverlon"] as? Double {
                                self.driverLocation = CLLocationCoordinate2D(latitude: driverlat, longitude: driverlon)
                                self.driverOnTheWay = true
                                self.displayDriverAndRider()
                                
                                if let email = Auth.auth().currentUser?.email {
                                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                        if let rideRequestDictionary = snapshot.value as? [String:Any] {
                                            if let driverlat = rideRequestDictionary["driverlat"] as? Double {
                                                if let driverlon = rideRequestDictionary["driverlon"] as? Double {
                                                    self.driverLocation = CLLocationCoordinate2D(latitude: driverlat, longitude: driverlon)
                                                    self.driverOnTheWay = true
                                                    self.displayDriverAndRider()
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }

                })
            }
    }
    
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)   //这个地方为什么能用driverLocation啊？？？？
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        
        callUberButton.setTitle("Your driver is \(roundedDistance)km away", for: .normal)
        
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        
        map.setRegion(region, animated: true)
        
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "Your location"
        map.addAnnotation(riderAnno)
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Your driver"
        map.addAnnotation(driverAnno)
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {      //give the user location
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            userLocation = center
            
            
            if driverOnTheWay {  //这个是我自己改的，老师写的是uberHasBeenCalled
                displayDriverAndRider()
                
            } else {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: center, span: span)
                map.setRegion(region, animated: true)
                
                map.removeAnnotations(map.annotations)
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = center
                annotation.title = "Your location"
                map.addAnnotation(annotation)
                
            }

        }
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var map: MKMapView!
    
    
    
    @IBOutlet var callUberButton: UIButton!
    @IBAction func callUberTapped(_ sender: Any) {
        if !driverOnTheWay {
        
            if let email = Auth.auth().currentUser?.email {
                
                if uberHasBeenCalled {
                    uberHasBeenCalled = false
                    callUberButton.setTitle("Call an Uber", for: .normal)
                    
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                        snapshot.ref.removeValue()
                        
                        Database.database().reference().child("RideRequests").removeAllObservers()
                    })
                    
                } else {
                    let rideRequestDictionary : [String : Any] = ["email":email,"lat":userLocation.latitude,"lon":userLocation.longitude]
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                    
                    uberHasBeenCalled = true
                    callUberButton.setTitle("Cancel Uber", for: .normal)
                }

            }
        
        }
    }

}

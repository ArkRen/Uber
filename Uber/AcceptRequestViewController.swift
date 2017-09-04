//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by RenFangzhou on 8/30/17.
//  Copyright © 2017 RenFangzhou. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase


class AcceptRequestViewController: UIViewController {

    @IBOutlet var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    @IBAction func acceptTapped(_ sender: Any) {
        
        //update the ride request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded, with: { (snapshot) in
            snapshot.ref.updateChildValues(["driverlat": self.driverLocation.latitude, "driverlon": self.driverLocation.longitude])
            
            Database.database().reference().child("RideRequests").removeAllObservers()

        
        //Give directions
            
        let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
            
            CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
                if let placemarks = placemarks{
                    if placemarks.count > 0 {
                        let PlaceMark = MKPlacemark(placemark: placemarks[0])
                        let mapItem = MKMapItem(placemark: PlaceMark)
                        mapItem.name = self.requestEmail
                        
                        let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        
                        
                        mapItem.openInMaps(launchOptions: options)
                    }
                }
                
            }
        
        
    })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        
        let yourAnnotationAtIndex = 0   //这两行是胡乱加的哈
        map.selectAnnotation(map.annotations[yourAnnotationAtIndex], animated: true)
        // Do any additional setup after loading the view.
    }
}

//
//  AcceptRequestViewController.swift
//  uber-practice
//
//  Created by Randy on 18/8/17.
//  Copyright © 2017 randy. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    var requestLocation = CLLocationCoordinate2D()
    var requestMail = ""
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        map.removeAnnotations(map.annotations)
        
        let annotation = MKPointAnnotation()
        print("!!!!! Accept location = (\(requestLocation.latitude),\(requestLocation.longitude))")
        annotation.coordinate = requestLocation
        annotation.title = requestMail
        map.addAnnotation(annotation)
        //map.removeAnnotations(map.annotations)
        
        
        /*
         if let coord = manager.location?.coordinate {
         let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
         userLocation = center
         let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
         map.setRegion(region, animated: true)
         map.removeAnnotations(map.annotations)
         
         let annotation = MKPointAnnotation()
         annotation.coordinate = center
         annotation.title = "Your location"
         map.addAnnotation(annotation)
         }
         */
    }

    @IBAction func acceptTapped(_ sender: Any) {
        // Update the ride Request to Firebase database
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestMail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude,"driverLon":self.driverLocation.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        // Give directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placeMarks, error) in
            if let placeMarks = placeMarks {
                if placeMarks.count > 0{
                    let placeMark = MKPlacemark(placemark:placeMarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requestMail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

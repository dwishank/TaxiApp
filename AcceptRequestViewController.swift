//
//  AcceptRequestViewController.swift
//  UberFinal
//
//  Created by Dwishank Patil on 31/07/18.
//  Copyright © 2018 Dwishank Patil. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth


class AcceptRequestViewController: UIViewController {

    var requestLocation = CLLocationCoordinate2D()
    var requestEmail =  ""
    
var driverLocation = CLLocationCoordinate2D()
    
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        
        //Task 1 Update the rider request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat": self.driverLocation.latitude,"driverLon":self.driverLocation.longitude])
            
            Database.database().reference().child("RideRequests").removeAllObservers()
            
            
        }
        
        
        
        //Task 2 Give Directions
        
        
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemark = placemarks
            {
         if placemark.count > 0
         {
            let mkPlacemark = MKPlacemark(placemark : placemark[0])
            let mapItem = MKMapItem(placemark: mkPlacemark)
            
            mapItem.name = self.requestEmail
            let option = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: option)
            
                }
        }
        
        
        }
    }
    
   

}

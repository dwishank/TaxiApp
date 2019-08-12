//
//  RiderViewController.swift
//  
//
//  Created by Dwishank Patil on 25/07/18.
//

import UIKit
import MapKit
import  FirebaseDatabase
import FirebaseAuth  //used to get access to the uber cab bookers email
import  GoogleMobileAds

class RiderViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var banner: GADBannerView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    
    var userLocation = CLLocationCoordinate2D() // used to save the coordinates of the location on the map
    var uberhasbeencalled = false
    var driverontheway = false
    var driverLocation = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        banner.rootViewController = self
        banner.load(GADRequest())
       
        
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email
        {
            
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                
                self.uberhasbeencalled = true
                self.callUberButton.setTitle("Cancel Uber", for: .normal)
                
                
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideRequestsDictionary = snapshot.value as? [String : AnyObject]
                {
                    if let driverlat = rideRequestsDictionary["driverLat"] as? Double
                    {
                        if let driverlon = rideRequestsDictionary["driverLon"] as? Double
                        {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverlat, longitude: driverlon)
                            self.driverontheway = true
                            self.displayDriverandRider()
                            
                            if let email = Auth.auth().currentUser?.email
                            {
                                
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                                    if let rideRequestsDictionary = snapshot.value as? [String : AnyObject]
                                    {
                                        if let driverlat = rideRequestsDictionary["driverLat"] as? Double
                                        {
                                            if let driverlon = rideRequestsDictionary["driverLon"] as? Double
                                            {
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverlat, longitude: driverlon)
                                                self.driverontheway = true
                                                self.displayDriverandRider()
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            
                        }
                        
                        }
                        
                    }
                    
                }
            }
            
            
            
            
            
            
            
            
            
        }
        
        
        
        
        
    }
    func displayDriverandRider()
    {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance =  driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        callUberButton.setTitle("YOUR DRIVER IS \(roundedDistance) away", for: .normal)
        self.map.removeAnnotations(map.annotations)
        //adding both rider and driver on the map
        let latDelta = abs( driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs( driverLocation.longitude - userLocation.longitude)
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "Your Location"
        map.addAnnotation(riderAnno)
        
        
        let driderAnno = MKPointAnnotation()
        driderAnno.coordinate = driverLocation
     driderAnno.title = "Driver Location"
        map.addAnnotation(driderAnno)
        
        
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let  coord = manager.location?.coordinate
        {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
           
            
            if uberhasbeencalled
            {
                displayDriverandRider()
               
                }
            else
            {
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                userLocation = center
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your Location"
                map.addAnnotation(annotation)
                
            }
            
        }
        
    }
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CallUberTapped(_ sender: Any) {
        //creating dictionary
        if !driverontheway
        {
        
        if let email = Auth.auth().currentUser?.email
        {
            
            if uberhasbeencalled{
                
                uberhasbeencalled = false
                callUberButton.setTitle("Call an Uber", for: .normal)
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                    snapshot.ref.removeValue() // problem with this is all the requests get deleted
                    //     so we need to stop the snapshot after one click
                    Database.database().reference().child("RideRequests").removeAllObservers()
                    
                    
                }
                
            }
            else
            {
                
                let requestDictionary : [String : Any] = ["email" : email ,"lat":userLocation.latitude,"lon":userLocation.longitude]
                Database.database().reference().child("RideRequests").childByAutoId().setValue(requestDictionary) // will hold all the ride requests
                uberhasbeencalled = true
                callUberButton.setTitle("Cancel Uber", for: .normal)
            }
            }
        }
    }
    
}

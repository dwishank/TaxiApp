//
//  DrivarTableViewController.swift
//  
//
//  Created by Dwishank Patil on 31/07/18.
//

import UIKit
import FirebaseDatabase
import  FirebaseAuth
import MapKit
class DrivarTableViewController: UITableViewController,CLLocationManagerDelegate {

    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            
            //Each of the snapshots are going to be each of the array index
            
            if let rideRequestsDictionary = snapshot.value as? [String : AnyObject]
            {
                if let driverlat = rideRequestsDictionary["driverLat"] as? Double
                {
                   
                }
                else
                {
                    self.rideRequests.append(snapshot)
                    self.tableView.reloadData()
                    
                }
            }
            
        }
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let coord = manager.location?.coordinate
    {
    driverLocation = coord
    }
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequests.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        let snapshot = rideRequests[indexPath.row]
        
       if let rideRequestsDictionary = snapshot.value as? [String : AnyObject]
       {
       if let email = rideRequestsDictionary["email"] as? String{
        //Snapshot would give you the value of dictionary like rider email,latitude, longitu
            if let lat = rideRequestsDictionary["lat"] as? Double
            {
                if let lon = rideRequestsDictionary["lon"] as? Double
                {
                    let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                    let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                   let distance =  driverCLLocation.distance(from: riderCLLocation) / 1000
                    let roundedDistance = round(distance * 100) / 100
                       cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                }
            }
     
        }
    }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequests[indexPath.row]
        
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVc = segue.destination as? AcceptRequestViewController
   {
    if let snapshot = sender as? DataSnapshot{
        if let rideRequestsDictionary = snapshot.value as? [String : AnyObject]
        {
            if let email = rideRequestsDictionary["email"] as? String{
                //Snapshot would give you the value of dictionary like rider email,latitude, longitu
                if let lat = rideRequestsDictionary["lat"] as? Double
                {
                    if let lon = rideRequestsDictionary["lon"] as? Double
                    {
                        
                        acceptVc.requestEmail = email
                        var location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                       acceptVc.requestLocation = location
                       acceptVc.driverLocation = driverLocation
                    }
                }
            }
        }
    }
   }
    
    
}
}

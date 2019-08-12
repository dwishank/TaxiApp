//
//  ViewController.swift
//  UberFinal
//
//  Created by Dwishank Patil on 25/07/18.
//  Copyright © 2018 Dwishank Patil. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleMobileAds
class ViewController: UIViewController {
    
    @IBOutlet weak var emailtextfield: UITextField!
    var interstitial: GADInterstitial!
    @IBOutlet weak var passwordtextfield: UITextField!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    var signupmode = true
    override func viewDidLoad() {
       
        super.viewDidLoad()
    interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
    let request = GADRequest()
    interstitial.load(request)
    }
    
    func displayAlert(title : String ,message : String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController,animated: true ,completion: nil)
    }
    
    
    @IBAction func topTapped(_ sender: Any) {
        if emailtextfield.text == " " || passwordtextfield.text == ""
        {
            
            displayAlert(title:"Missing Information" , message: "Please enter email and password")
        }
            
        else
        {
            if let email = emailtextfield.text
            {
                if let password = passwordtextfield.text
                {
                    if signupmode
                    {
                        //SignUp
                        
                        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                            if error != nil
                            {
                                self.displayAlert(title: "Error",message : error!.localizedDescription)
                            }
                            else
                            {
                                print("Sign Up Success")
                                
                                
                                if self.riderDriverSwitch.isOn
                                {
                                    print("Driver")
                                    //Driver
                                
                                    let req =   Auth.auth().currentUser?.createProfileChangeRequest()
                                    
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                    
                                
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                }
                                else
                                {
                                    //Rider
                                print("Rider")
                                    let req =   Auth.auth().currentUser?.createProfileChangeRequest()
                                    
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                    
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                            }
                        }
                    }
                    else
                    {
                        //Login
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil
                            {
                                self.displayAlert(title: "Error",message : error!.localizedDescription)
                            }
                                
                            else
                            {
                            //    print("Login Success")
                                if user?.user.displayName == "Driver"
                                {
                                    
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                    
                                    
                                }
                                else
                                {
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                                
                                
                            }
                            
                            
                        })
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
            }
        }
        
        
        
    }
    
    @IBAction func bottomTapped(_ sender: Any) {
        
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    
        
        
        
        if signupmode
        {
            topButton.setTitle("LogIn", for: .normal)
            bottomButton.setTitle("Switch to SignUp ", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signupmode = false
            
        }
            
        else
        {
            topButton.setTitle("SignUp", for: .normal)
            bottomButton.setTitle("Switch to LogIn", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signupmode = true
            
            
            
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


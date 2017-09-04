//
//  ViewController.swift
//  Uber
//
//  Created by RenFangzhou on 8/28/17.
//  Copyright © 2017 RenFangzhou. All rights reserved.
//

import UIKit
import FirebaseAuth
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var RiderDriverSwitch: UISwitch!
    
    @IBOutlet var RiderLabel: UILabel!
    
    @IBOutlet var DriverLabel: UILabel!
    @IBOutlet var topButton: UIButton!
    
    @IBOutlet var bottomButton: UIButton!
    
    var signUpMode = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func topTapped(_ sender: Any) {
        if emailText.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "You must provide both email and password")
        } else {
            
            if let email = emailText.text {
                if let password = passwordTextField.text {
            
                    if signUpMode {
                    //Sign Up
                
                
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                
                                if self.RiderDriverSwitch.isOn {
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                    //DRIVER
                                } else {
                                    //RIDER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                    
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                                //print("Sign up success")
                                
                            }
                        })
                
                    } else {
                        //Log In
                        
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                
                                if user?.displayName == "Driver" {
                                    //print("driver")
                                    //Driver
                                    
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                } else {
                                    //Rider
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                                //print("Login success")
                                
                            }
                        })

                
                    }
                }
            }
        }
    }
    
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func bottomTapped(_ sender: Any) {
        if signUpMode {
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            RiderLabel.isHidden = true
            DriverLabel.isHidden = true
            RiderDriverSwitch.isHidden = true
            signUpMode = false
            
        } else {
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            RiderLabel.isHidden = false
            DriverLabel.isHidden = false
            RiderDriverSwitch.isHidden = false
            signUpMode = true
            
        }
    }
    //    override func didReceiveMemoryWarning() {
    //        super.didReceiveMemoryWarning()
    //        // Dispose of any resources that can be recreated.
    //    }
    
    
}


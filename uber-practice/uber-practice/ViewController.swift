//
//  ViewController.swift
//  uber-practice
//
//  Created by Randy on 6/8/17.
//  Copyright © 2017 randy. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var roleSwitch: UISwitch!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var isPwStoredSwitch: UISwitch!
    
    var defaultEmail = ""
    var defaultPassword = ""
    var isStoreEmailPassword = false
    var isDriver = false
    
    var signUpMode = true
    
    @IBAction func upBtnTapped(_ sender: Any) {
        if emailTextfield.text == "" || passwordTextfield.text == "" {
            displayAlert(title: "Missing information", message: "Please input valid email/password information")
        } else {
            if let email = emailTextfield.text, let password = passwordTextfield.text {
                if signUpMode {
                    // Do Sign up here
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Sign up Error!!", message: error!.localizedDescription)
                        } else {
                            print("Sign up sucessfully !!!")
                            
                            if self.roleSwitch.isOn {
                                // Driver sign up
                                self.isDriver = true
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Driver"
                                req?.commitChanges(completion: nil)
                                
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                self.displayAlert(title: "[Rider] Sign up sucessfully", message: "")
                            } else {
                                // Rider sign up
                                self.isDriver = false
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Rider"
                                req?.commitChanges(completion: nil)
                                
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                self.displayAlert(title: "[Rider] Sign up sucessfully", message: "")
                            }
                            
                            if self.isPwStoredSwitch.isOn {
                                self.storeEmailPassword(Email: email, Password: password, isDriver: self.isDriver)
                            } else { // NOT Store email & password
                                UserDefaults.standard.set(nil,forKey: "email")
                                UserDefaults.standard.set(nil,forKey: "password")
                                UserDefaults.standard.set(nil,forKey: "isStoreEmailPassword")
                            }
                            
                            //UserDefaults.standard.set(email,forKey: "email")
                        }
                    }
                } else {
                    // Do Login here
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Login Error!!", message: error!.localizedDescription)
                        } else {
                            print("Login sucessfully !!!")
                            
                            if self.isPwStoredSwitch.isOn {
                                if self.roleSwitch.isOn {
                                    // Driver sign up
                                    self.isDriver = true
                                } else {
                                    // Rider sign up
                                    self.isDriver = false
                                }
                                self.storeEmailPassword(Email: email, Password: password, isDriver: self.isDriver)
                            } else { // NOT Store email & password
                                UserDefaults.standard.set(nil,forKey: "email")
                                UserDefaults.standard.set(nil,forKey: "password")
                                UserDefaults.standard.set(nil,forKey: "isStoreEmailPassword")
                            }
                            
                            
                            if self.roleSwitch.isOn {
                                // Driver
                                UserDefaults.standard.set(email,forKey: "email")
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            } else {
                                // Rider
                                UserDefaults.standard.set(email,forKey: "email")
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func displayAlert(title:String, message:String) {
        let alertControl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertControl, animated: true, completion: nil)
    }
    
    @IBAction func downBtnTapped(_ sender: Any) {
        if signUpMode {
            upButton.setTitle("Login", for: .normal)
            downButton.setTitle("Switch to sign up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            roleSwitch.isHidden = true
            signUpMode = false
        } else {
            upButton.setTitle("Sign up", for: .normal)
            downButton.setTitle("Switch to Login", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            roleSwitch.isHidden = false
            signUpMode = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isStoreEmailPassword = (UserDefaults.standard.object(forKey: "isStoreEmailPassword") != nil)
        isDriver = (UserDefaults.standard.object(forKey: "isDriver") != nil)
        
        if isDriver == true { // Driver Switch on
            roleSwitch.setOn(true, animated: true)
        } else { // Rider Switch off
            roleSwitch.setOn(false, animated: true)
        }
        
        if isStoreEmailPassword == true { // Switch on
            isPwStoredSwitch.setOn(true, animated: true)
            if let defaultEmail = UserDefaults.standard.object(forKey: "email"){
                print("Default Email: \(defaultEmail)")
                if defaultEmail as! Substring != "" {
                    switchMode(isSignUpMode: true)
                    emailTextfield.text = defaultEmail as? String
                }
            }
            if let defaultPassword = UserDefaults.standard.object(forKey: "password"){
                print("Default Password: \(defaultPassword)")
                if defaultPassword as! Substring != "" {
                    passwordTextfield.text = defaultPassword as? String
                }
            }
        } else { //Switch off
            isPwStoredSwitch.setOn(false, animated: true)
        }
    }
    
    func storeEmailPassword(Email: String, Password: String, isDriver: Bool) {
        if !Email.isEmpty && !Password.isEmpty {
            UserDefaults.standard.set(Email,forKey: "email")
            UserDefaults.standard.set(Password,forKey: "password")
            UserDefaults.standard.set(true,forKey: "isStoreEmailPassword")
            UserDefaults.standard.set(isDriver,forKey: "isDriver")
        }
    }
    
    func retriveEmailPassword() {
        
    }
    
    func switchMode(isSignUpMode: Bool) {
        self.signUpMode = isSignUpMode
        print("!!! self.signUpMode = \(self.signUpMode)")
        if signUpMode {
            upButton.setTitle("Login", for: .normal)
            downButton.setTitle("Switch to sign up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            roleSwitch.isHidden = true
            signUpMode = false
        } else {
            upButton.setTitle("Sign up", for: .normal)
            downButton.setTitle("Switch to Login", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            roleSwitch.isHidden = false
            signUpMode = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}


//
//  ViewController.swift
//  Uber For Rider
//
//  Created by Emmanuel Erilibe on 1/25/17.
//  Copyright © 2017 Emmanuel Erilibe. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {

    private let RIDER_SEGUE = "RiderVC"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    @IBAction func logInBtn(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem With Authentication", message: message!)
                } else {
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            })
            
        } else {
            alertTheUser(title: "😡Email & Password Are Required", message: "Please enter email and password in the text fields")
        }
    }

    @IBAction func signUpBtn(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem Creating Account", message: message!)
                } else {
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            })
        } else {
            self.alertTheUser(title: "Email And Password are Required", message: "Please enter correct email and password in the text fields")
        }
    }
    
    private func alertTheUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}


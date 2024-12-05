//
//  LoginViewController.swift
//  To Do List
//
//  Created by Marcelo Inocente on 27/11/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
                if let e = error {
                    print(e)
                } else {
                    self.performSegue(withIdentifier: K.Segue.loginSegue, sender: self)
                }
            }
        }
    }
}

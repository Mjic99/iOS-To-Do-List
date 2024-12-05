//
//  MainScreenViewController.swift
//  To Do List
//
//  Created by Marcelo Inocente on 3/12/24.
//

import UIKit
import FirebaseAuth

class MainScreenViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: K.Segue.alreadyLoggedInSegue, sender: nil)
        }
    }
}

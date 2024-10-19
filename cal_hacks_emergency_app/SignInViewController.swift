//
//  SignInViewController.swift
//  cal_hacks_emergency_app
//
//  Created by Siddharth Prothia on 10/19/24.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTf: UITextField!
    
    @IBOutlet weak var passwordTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTf.delegate = self
        passwordTf.delegate = self
    }
    
    @IBAction func signIn(_ sender: Any) {
        
        guard let email = emailTf.text, !email.isEmpty,
                      let password = passwordTf.text, !password.isEmpty else {
                    print("Email and Password fields cannot be empty")
                    return
                }
                
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
            }
            
            print("User signed in successfully")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
        }
        
    }
    
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        
        return true
    }
   
    

}

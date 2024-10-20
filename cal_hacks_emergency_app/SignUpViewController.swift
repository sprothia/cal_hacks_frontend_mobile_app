//
//  SignUpViewController.swift
//  cal_hacks_emergency_app
//
//  Created by Siddharth Prothia on 10/19/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var age: UITextField!
    
    @IBOutlet weak var city: UITextField!
    
    @IBOutlet weak var emergencyNumber: UITextField!
    
    @IBOutlet weak var additionalNotes: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstName.delegate = self
        lastName.delegate = self
        age.delegate = self
        city.delegate = self
        emergencyNumber.delegate = self
        firstName.delegate = self
        firstName.delegate = self
        
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        signUpUser(email: email.text!, password: password.text! , firstName: firstName.text!, lastName: lastName.text!, age: age.text!, city: city.text!, emergencyNumber: emergencyNumber.text!, additionalNotes: additionalNotes.text!)
        

        print("Trying to sign up user!")
    }
    
    @IBAction func testButton(_ sender: Any) {
        print("sent test payload")
        
        var dataDict : [String : Any] = ["id" : 100, "name" : "nipun", "is_student" : true]
        var rawData : Data = Data()
        
        do{
            try rawData.pack(dataDict)
        }
        catch{
            print("ERROR PACKING DATA: \(error)");
        }
        
        CommunicationClass.obj.sendData(rawData)
    }
    
    func signUpUser(email: String, password: String, firstName: String, lastName: String, age: String, city: String, emergencyNumber: String, additionalNotes: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            
            guard let userId = authResult?.user.uid else { return }
            
            let userData: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "age": age,
                "address": city,
                "emergencyNumber": emergencyNumber,
                "additionalNotes": additionalNotes,
            ]
            
            let db = Firestore.firestore()
            
           
            db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    print("Error storing user data: \(error.localizedDescription)")
                } else {
                    print("User data successfully saved!")
                }
            }
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        age.resignFirstResponder()
        city.resignFirstResponder()
        emergencyNumber.resignFirstResponder()
        additionalNotes.resignFirstResponder()
        
        return true
    }
   

    
}

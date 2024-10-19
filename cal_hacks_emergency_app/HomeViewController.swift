//
//  HomeViewController.swift
//  cal_hacks_emergency_app
//
//  Created by Siddharth Prothia on 10/19/24.
//

import UIKit
import CoreLocation
import FirebaseAuth

class HomeViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var coordinatesLbl: UILabel!
    
    @IBOutlet weak var helpBtn: UIButton!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        helpBtn.setTitle("", for: .normal)
                
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        helpBtn.backgroundColor = .clear
        
        helpBtn.layer.shadowColor = UIColor.black.cgColor
        helpBtn.layer.shadowOpacity = 0.5
        helpBtn.layer.shadowOffset = CGSize(width: 5, height: 5)
        helpBtn.layer.shadowRadius = 10
                
        
    }
    
    @IBAction func helpButton(_ sender: Any) {
        
    }
    
    @IBAction func signOut(_ sender: Any) {

        do {
            try Auth.auth().signOut()
            print("User logged out successfully")
            navigateToLoginScreen()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
        }
        
    }
    
    func navigateToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "signupViewController") as! SignUpViewController
        self.view.window?.rootViewController = loginViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        print("Failed to reverse geocode: \(error.localizedDescription)")
                        return
                    }
                    
                    if let placemark = placemarks?.first {
                        let address = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
                        
                        DispatchQueue.main.async {
                            self.coordinatesLbl.text = "Lat: \(latitude), Long: \(longitude)"
                        }
                    }
                }
                locationManager.stopUpdatingLocation()
            }
        }
        
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            coordinatesLbl.text = "Location access denied"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        coordinatesLbl.text = "Unable to fetch location"
    }
    


}

//
//  ViewController.swift
//  cal_hacks_emergency_app
//
//  Created by Siddharth Prothia on 10/18/24.
//

import UIKit
import AVFoundation
import AVFAudio
import CoreLocation
import Speech

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var recordVoice: UIButton!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    var photoIndex = 0
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var isRecording = false
    var audioFileName: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordVoice.setTitle("", for: .normal)
        configureAudioSession()
        recordVoice.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        
    }
    
//     IBAction Functions *****************************************************
//
    @IBAction func uploadVideoButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = false
            present(imagePickerController, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    
    @IBAction func getHelp(_ sender: Any) {
        
        print("processing data")
        
        let base64String1 = convertImageToBase64(imageView: imageOne)
//        let base64String2 = convertImageToBase64(imageView: imageTwo)
//        let base64String3 = convertImageToBase64(imageView: imageThree)
        
        
        var roundedLat = 0.0, roundedLong = 0.0
        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locationManager.location
            roundedLat = Double(round(1000 * (currentLocation?.coordinate.latitude.magnitude ?? 0)) / 1000)
            roundedLong = Double(round(1000 * (currentLocation?.coordinate.longitude.magnitude ?? 0)) / 1000)
        }
        
        print(roundedLat, ":", roundedLong)
        
        if let url = audioFileName {
            transcribeAudio(url: url) { transcription in
                
                let image1base64 = base64String1 ?? "No image data";
                
                let imagesData: [String: Any] = [
                    //"image1": base64String1 ?? "No image data",
                    //"image2": base64String2 ?? "No image data",
                    //"image3": base64String3 ?? "No image data",
                    "voiceText": transcription,
                    "lat": String(roundedLat),
                    "lon": String(roundedLong)
                ]

                // SEND INFORMATION TO SATELLITE
                
                /*var rawData : Data = Data()
                for (key, data) in imagesData{
                    rawData = Data() // reset data buffer
                    
                    let currentData : [String : Any] = [key : data];
                    print("sending \(key) = \(data)")
                    do {
                        try rawData.pack(currentData);
                    }
                    catch{
                        print("Error packing \(error)")
                    }
                    
                    
                    CommunicationClass.obj.sendData(rawData);
                    
                    usleep(100000) // sleep 0.1
                }*/

                self.showAlertDone(message: "Help is on the way.")
            }
        }
                
    }
    
    func showAlertDone(message: String) {
        let alertController = UIAlertController(title: "Information Sent and Recieved", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            displayError(message: "Failed to configure audio session")
        }
    }

    @IBAction func recordVoiceButton(_ sender: Any) {

        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }

    }
    
    func convertImageToBase64(imageView: UIImageView) -> String? {
        if let image = imageView.image {
            if let imageData = image.jpegData(compressionQuality: 0.2) {
                let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
                return base64String
            }
        }
        return "No image found"
    }

//    @IBAction func playVoiceButton(_ sender: Any) {
//        if let fileURL = audioFileName {
//            playAudio(fileURL: fileURL)
//        }
//    }


    @IBAction func clearImages(_ sender: Any) {
        imageOne.image = nil
        imageTwo.image = nil
        imageThree.image = nil
        photoIndex = 0
    }

    /* Audio Functions ***************************************************** */

    func startRecording() {

        let fileName = getDocumentsDirectory().appendingPathComponent("recordedAudio.m4a")
        audioFileName = fileName

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            isRecording = true
//            playVoice.isHidden = true

        } catch {
            displayError(message: "Recording failed")
        }
    }

    func stopRecording() {
        showAlert(message: "Recording has been saved!")
        audioRecorder?.stop()
        isRecording = false
        recordVoice.setTitle("Record", for: .normal)
    }
    
    func transcribeAudio(url: URL, completion: @escaping (String) -> Void) {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            completion("Speech recognizer not available")
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        recognizer.recognitionTask(with: request) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion("Error translating")
            } else if let result = result {
                if result.isFinal {
                    let transcription = result.bestTranscription.formattedString
                    print("Transcription: \(transcription)")
                    completion(transcription)
                }
            } else {
                completion("No voice provided")
            }
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        
        sender.setImage(nil, for: .normal)  // Remove the image
        sender.setTitle("Stop Recording", for: .normal)  // Set text
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 18)  // Optional: Set font size
    }

    

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func displayError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    /* Image Picker Functions ***************************************************** */

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[.originalImage] as? UIImage {

                switch photoIndex {
                    case 0:
                        imageOne.image = image
                    case 1:
                        imageTwo.image = image
                    case 2:
                        imageThree.image = image
                    default:
                        print("Cannot upload more images")
                }

                if photoIndex < 3 {
                    photoIndex += 1
                }


            }
            dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)

    }



}


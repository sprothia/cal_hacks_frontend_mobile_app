//
//  ViewController.swift
//  cal_hacks_emergency_app
//
//  Created by Siddharth Prothia on 10/18/24.
//

import UIKit
import AVFoundation
import AVFAudio

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var recordVoice: UIButton!

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


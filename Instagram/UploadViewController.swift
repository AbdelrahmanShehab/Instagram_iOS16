//
//  UploadViewController.swift
//  Instagram
//
//  Created by Abdelrahman Shehab on 10/05/2023.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var uploadButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func chooseImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }

    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    @IBAction func uploadButtoncClicked(_ sender: Any) {
            let storage = Storage.storage()
            let storageReferance = storage.reference()
            let mediafolder = storageReferance.child("Media")
    
            if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
                let uuid = UUID().uuidString
                
                let imageReferance = mediafolder.child("\(uuid).jpg")
                imageReferance.putData(data, metadata: nil) { metaData, error in
    
                    if error != nil {
                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                    } else {
                        imageReferance.downloadURL { url, error in
    
                            if error == nil {
                                let imageURL = url?.absoluteString
                                
                                // DATABSE
                                let firestoreDatabase = Firestore.firestore()
                                var firestoreReferance: DocumentReference? = nil
                                
                                let firestorePost = [
                                    "imageURL": imageURL!,
                                    "postedBy": Auth.auth().currentUser!.email!,
                                    "postComment": self.commentTextField.text!,
                                    "date": FieldValue.serverTimestamp(),
                                    "likes": 0
                                    ] as [String: Any]
                                
                                firestoreReferance = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
                                    if error != nil {
                                        self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                                    } else {
                                        self.imageView.image = UIImage(named: "select.png")
                                        self.commentTextField.text = ""
                                        self.tabBarController?.selectedIndex = 0
                                    }
                                })
                            }
                        }
                    }
                }
            }
    }
    

}

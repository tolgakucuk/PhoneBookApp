//
//  AddContactVC.swift
//  PhoneBookApp
//
//  Created by Tolga on 6.06.2021.
//

import UIKit
import Firebase

class AddContactVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var sirNameText: UITextField!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var notesText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.makeRounded()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func addPhotoClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = (info[.originalImage] as! UIImage)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveClicked(_ sender: Any) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = image.image?.jpegData(compressionQuality: 0.5){
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (data, error) in
                if(error != nil){
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else{
                    imageReference.downloadURL { (url, error) in
                        if(error != nil){
                            self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                        }else{
                            let imageUrl = url?.absoluteString
                            //FireStore işlemleri
                            let fireStoreDatabase = Firestore.firestore()
                            var fireStoreReference : DocumentReference? = nil
                            
                            let fireStoreContacts = ["imageUrl" : imageUrl!, "contactBy" : Auth.auth().currentUser!.email!, "contactName" : self.nameText.text!, "contactSirname" : self.sirNameText.text!, "contactPhone" : self.phoneNumberText.text!, "contactNote" : self.notesText.text!] as [String : Any]
                            
                            fireStoreReference = fireStoreDatabase.collection("Contacts").addDocument(data: fireStoreContacts) { (error) in
                                if(error != nil){
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                }else{
                                    self.performSegue(withIdentifier: "toContactsVC", sender: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func cancelClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toContactsVC", sender: nil)
    }
    
}

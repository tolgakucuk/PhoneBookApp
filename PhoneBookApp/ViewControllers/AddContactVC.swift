

import UIKit
import Firebase
import SDWebImage

class AddContactVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var sirNameText: UITextField!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var notesText: UITextView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var contact: Contact?
    var documentId: String = ""
    
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    var isNewContact: Bool = false //bir önceki sayfadan kullanıcının herhangi bir kişiye mi tıklayıp geldiğini yoksa yeni kişi ekleden mi geldiğini anlamak için. True ise sil butonunu gizlicez.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        image.makeRounded()
        notesText.layer.cornerRadius = 10
        notesText.layer.borderWidth = 1
        notesText.layer.borderColor = UIColor.lightGray.cgColor
        deleteButton.layer.cornerRadius = 10
        
        //sil butonu ile ilgili işlemler
        if isNewContact {
            deleteButton.isHidden = true
            saveButton.setTitle("Save", for: .normal)
        } else {
            deleteButton.isHidden = false
            saveButton.setTitle("Update", for: .normal)
            //bir önceki sayfadan aldığımı verileri ekrana basma
            if contact != nil {
                nameText.text = contact!.contactName
                sirNameText.text = contact!.contactSirname
                phoneNumberText.text = contact!.contactPhone
                notesText.text = contact!.contactNote
                image.sd_setImage(with: URL(string: contact!.contactUrl))
            }
        }
        
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
                    imageReference.downloadURL { [self] (url, error) in
                        if(error != nil){
                            self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                        }else{
                            let imageUrl = url?.absoluteString
                            
                            //FireStore işlemleri
                            let fireStoreDatabase = Firestore.firestore()
                            
                            let fireStoreContacts = ["imageUrl" : imageUrl ?? "",
                                                     "contactBy" : Auth.auth().currentUser!.email ?? "",
                                                     "contactName" : self.nameText.text ?? "",
                                                     "contactSirname" : self.sirNameText.text!,
                                                     "contactPhone" : self.phoneNumberText.text ?? "",
                                                     "contactNote" : self.notesText.text ?? "",
                                                     "uid": userId] as [String : Any]
                            if self.isNewContact {
                                //add new person
                                fireStoreDatabase.collection("Contacts").document().setData(fireStoreContacts) { (err) in
                                    if(err != nil){
                                        self.makeAlert(title: "Error", message: err?.localizedDescription ?? "Error")
                                    }else{
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            } else {
                                //update person
                                fireStoreDatabase.collection("Contacts").document(self.documentId).setData(fireStoreContacts) { (err) in
                                    if(err != nil){
                                        self.makeAlert(title: "Error", message: err?.localizedDescription ?? "Error")
                                    }else{
                                        self.dismiss(animated: true, completion: nil)
                                    }
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
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        //delete user
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Contacts").document(self.documentId).delete { (err) in
            if err == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.makeAlert(title: "Error", message: "Deleting error")
            }
        }
    }
}

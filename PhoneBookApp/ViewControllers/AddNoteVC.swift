//
//  AddNoteVC.swift
//  PhoneBookApp
//
//  Created by Tolga on 15.06.2021.
//

import UIKit
import Firebase

class AddNoteVC: UIViewController {
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtNote: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    var note: Note?
    var documentId: String = ""
    
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    var isNewNote: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        deleteButton.layer.cornerRadius = 10
        
        if isNewNote {
            deleteButton.isHidden = true
            saveButton.setTitle("Save", for: .normal)
        } else {
            deleteButton.isHidden = false
            saveButton.setTitle("Uptade", for: .normal)
            
            if note != nil {
                txtTitle.text = note!.noteTitle
                txtNote.text = note!.noteName
            }
        }
    }
    
    //MARK: - Save Button Clicked
    @IBAction func saveClicked(_ sender: Any) {
        if(txtTitle.text == ""){
            self.makeAlert(title: "ERROR", message: "Please enter your title")
        }
        else{
            let fireStoreDatabase = Firestore.firestore()
            let fireStoreNotes = ["noteTitle" : self.txtTitle.text ?? "",
                                  "noteName" : self.txtNote.text ?? "",
                                  "uid" : userId] as [String : Any]
            
            if self.isNewNote{
                fireStoreDatabase.collection("Notes").document().setData(fireStoreNotes) { (error) in
                    if(error != nil){
                        self.makeAlert(title: "ERROR", message: error?.localizedDescription ?? "ERROR")
                    }else{
                        self.makeAlertForSegue(title: "", message: "Note has added succesfuly.")
                    }
                }
            }else{
                fireStoreDatabase.collection("Notes").document(self.documentId).setData(fireStoreNotes) { (err) in
                    if(err != nil){
                        self.makeAlert(title: "Error", message: err?.localizedDescription ?? "Error")
                    }else{
                        self.makeAlertForSegue(title: "", message: "You have updated the note succesfuly.")
                    }
                }

            }
        }
    }
    
    //MARK: - Alerts
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeAlertForSegue(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Delete Button Clicked
    @IBAction func deleteButtonClicked(_ sender: Any) {
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Notes").document(self.documentId).delete { (err) in
            if err == nil {
                self.makeAlertForSegue(title: "", message: "You have deleted the note succesfuly.")
            } else {
                self.makeAlert(title: "Error", message: "Deleting error")
            }
        }
    }
    
    //MARK: - Back Button Clicked
    @IBAction func backClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

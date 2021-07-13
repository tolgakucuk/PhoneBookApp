//
//  AddNoteVC.swift
//  PhoneBookApp
//
//  Created by Tolga on 15.06.2021.
//

import UIKit
import Firebase

class AddNoteVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var txtTitle: UITextField!
    
    @IBOutlet weak var txtNote: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    var note: Note?
    var documentId: String = ""
    
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    var isNewNote: Bool = false
    
    var indicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        deleteButton.layer.cornerRadius = 10
        txtNote.delegate = self
        txtNote.text = "ENTER_YOUR_NOTE_HERE".localized
        txtNote.textColor = UIColor.lightGray
        txtNote!.layer.borderWidth = 1
        txtNote!.layer.borderColor = UIColor.black.cgColor
        
        
        if isNewNote {
            deleteButton.isHidden = true
            saveButton.setTitle("Save", for: .normal)
        } else {
            deleteButton.isHidden = false
            saveButton.setTitle("Update", for: .normal)
            
            if note != nil {
                txtTitle.text = note!.noteTitle
                txtNote.text = note!.noteName
            }
        }
        
        
    }
    
    //MARK: - Save Button Clicked
    @IBAction func saveClicked(_ sender: Any) {
        self.startIndicator()
        if(txtTitle.text == ""){
            self.stopIndicator()
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
                        self.stopIndicator()
                        self.makeAlert(title: "ERROR", message: error?.localizedDescription ?? "ERROR")
                    }else{
                        self.stopIndicator()
                        self.makeAlertForSegue(title: "", message: "Note has added succesfuly.")
                    }
                }
            }else{
                fireStoreDatabase.collection("Notes").document(self.documentId).setData(fireStoreNotes) { (err) in
                    if(err != nil){
                        self.stopIndicator()
                        self.makeAlert(title: "Error", message: err?.localizedDescription ?? "Error")
                    }else{
                        self.stopIndicator()
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
        self.startIndicator()
        fireStoreDatabase.collection("Notes").document(self.documentId).delete { (err) in
            if err == nil {
                self.stopIndicator()
                self.makeAlertForSegue(title: "", message: "You have deleted the note succesfuly.")
            } else {
                self.stopIndicator()
                self.makeAlert(title: "Error", message: "Deleting error")
            }
        }
    }
    
    //MARK: - Back Button Clicked
    @IBAction func backClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TextView
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtNote.text == "ENTER_YOUR_NOTE_HERE".localized {
            txtNote.text = ""
            txtNote.textColor = UIColor.black
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtNote.text == "" {
            txtNote.text = "ENTER_YOUR_NOTE_HERE".localized
            txtNote.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    
    //MARK: - Indicator
    func startIndicator(){
        indicatorView.center = self.view.center
        indicatorView.hidesWhenStopped = true
        view.addSubview(indicatorView)
        
        indicatorView.startAnimating()
    }
    
    func stopIndicator(){
        indicatorView.stopAnimating()
    }
}


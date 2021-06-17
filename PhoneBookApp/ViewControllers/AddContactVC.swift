

import UIKit
import Firebase
import SDWebImage

class AddContactVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var sirNameText: UITextField!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var bloodGroupText: UITextField!
    @IBOutlet weak var birthDayText: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var contact: Contact?
    var documentId: String = ""
    
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    var isNewContact: Bool = false //bir önceki sayfadan kullanıcının herhangi bir kişiye mi tıklayıp geldiğini yoksa yeni kişi ekleden mi geldiğini anlamak için. True ise sil butonunu gizlicez.
    
    let bloodGroups = ["A+", "A-", "AB+", "AB-", "B+", "B-", "0+", "0-"]
    var pickerView = UIPickerView()
    
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        image.makeRounded()
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
                image.sd_setImage(with: URL(string: contact!.contactUrl))
                nameText.text = contact!.contactName
                sirNameText.text = contact!.contactSirname
                phoneNumberText.text = contact!.contactPhone
                emailText.text = contact!.contactEmail
                bloodGroupText.text = contact!.contactBloodgroup
                birthDayText.text = contact!.contactBirthday
            }
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        bloodGroupText.inputView = pickerView
        phoneNumberText.delegate = self
        createDatePicker()
        
        
    }
    
    //MARK: - Add Photo
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
    
    //MARK: - Save Button Clicked
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
                            
                            //Firebase İşlemleri
                            if(nameText.text == "" || phoneNumberText.text == ""){
                                makeAlert(title: "ERROR", message: "You should enter at least firstname and phone to create contact.")
                            }else{
                                let fireStoreDatabase = Firestore.firestore()
                                
                                let fireStoreContacts = ["contactUrl" : imageUrl ?? "",
                                                         "contactName" : self.nameText.text ?? "",
                                                         "contactSirname" : self.sirNameText.text ?? "",
                                                         "contactEmail" : self.emailText.text ?? "",
                                                         "contactPhone" : self.phoneNumberText.text ?? "",
                                                         "contactBloodGroup" : self.bloodGroupText.text ?? "",
                                                         "contactBirthday" : self.birthDayText.text ?? "",
                                                         "uid": userId] as [String : Any]
                                if self.isNewContact {
                                    //add new person
                                    fireStoreDatabase.collection("Contacts").document().setData(fireStoreContacts) { (err) in
                                        if(err != nil){
                                            self.makeAlert(title: "Error", message: err?.localizedDescription ?? "Error")
                                        }else{
                                            self.makeAlertForSegue(title: "", message: "You have added the contact succesfuly.")
                                        }
                                    }
                                } else {
                                    //update person
                                    fireStoreDatabase.collection("Contacts").document(self.documentId).setData(fireStoreContacts) { (err) in
                                        if(err != nil){
                                            self.makeAlert(title: "Error", message: err?.localizedDescription ?? "Error")
                                        }else{
                                            self.makeAlertForSegue(title: "", message: "You have updated the contact succesfuly.")
                                        }
                                    }
                                }
                            }
                            
                            
                        }
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
    
    //MARK: - Cancel Button Clicked
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Delete Button Clicked
    @IBAction func deleteButtonClicked(_ sender: Any) {
        //delete user
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Contacts").document(self.documentId).delete { (err) in
            if err == nil {
                self.makeAlertForSegue(title: "", message: "You have deleted the contact succesfuly.")
            } else {
                self.makeAlert(title: "Error", message: "Deleting error")
            }
        }
    }
    
    //MARK: - Picker View Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bloodGroups.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bloodGroups[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        bloodGroupText.text = bloodGroups[row]
        bloodGroupText.resignFirstResponder()
    }
    
    //MARK: - Date Picker Functions
    func createDatePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        birthDayText.inputAccessoryView = toolbar
        birthDayText.inputView = datePicker
        
        datePicker.datePickerMode = .date
        
    }
    
    @objc func donePressed(){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        
        birthDayText.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    //MARK: - Text Field Formatting
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         var fullString = phoneNumberText.text ?? ""
         fullString.append(string)
         if range.length == 1 {
            phoneNumberText.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
         } else {
            phoneNumberText.text = format(phoneNumber: fullString)
         }
         return false
       }

    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")

        if number.count > 11 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 11)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{4})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{4})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }
        
        return number
    }
}



import UIKit
import Firebase

class SignUPVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var PhoneNumberText: UITextField!{
        didSet{
            PhoneNumberText.setLeftView(image: UIImage.init(named: "phone")!)
           
        }
    }
    @IBOutlet weak var EmailText: UITextField!{
        didSet{
            EmailText.setLeftView(image: UIImage.init(named: "email")!)
        }
    }
    @IBOutlet weak var PasswordText: UITextField!{
        didSet{
            PasswordText.setLeftView(image: UIImage.init(named: "password")!)
        }
    }
    @IBOutlet weak var ConfirmPasswordText: UITextField!{
        didSet{
            ConfirmPasswordText.setLeftView(image: UIImage.init(named: "password")!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        PhoneNumberText.delegate = self
        hideKeyboardWhenTappedAround()
       
    }
    
    //MARK: - Sign Up Clicked
    @IBAction func SignUpClicked(_ sender: Any) {
        if(PhoneNumberText.text!.count <= 14){
            makeAlert(title: "Error", message: "Please enter a 11 character phone number")
        }
        else if(EmailText.text == ""){
            makeAlert(title: "Error", message: "Please enter an email")
        }
        else if(PasswordText.text == ""){
            makeAlert(title: "Error", message: "Please enter your password")
        }
        else if(ConfirmPasswordText.text != PasswordText.text){
            makeAlert(title: "Error", message: "Please confirm your password")
        }
        else{
            Auth.auth().createUser(withEmail: EmailText.text!, password: PasswordText.text!) { (auth, error) in
                if(error != nil){
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else{
                    let fireStore = Firestore.firestore()
                    let userDictionary = ["phoneNumber" : self.PhoneNumberText.text!, "e-mail" : self.EmailText.text!] as [String : Any]
                    fireStore.collection("UserInfo").addDocument(data: userDictionary)
                    self.makeAlertForSegue(title: "", message: "You have signed in succesfuly. You can sign in")
                    
                }
            }
        }
       
    }
    
    //MARK: - Sign In Clicked
    @IBAction func SignInClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: nil)
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
            self.performSegue(withIdentifier: "toSignIn", sender: nil)
        })
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Text Field Format
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         var fullString = PhoneNumberText.text ?? ""
         fullString.append(string)
         if range.length == 1 {
           PhoneNumberText.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
         } else {
           PhoneNumberText.text = format(phoneNumber: fullString)
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

        if number.count < 11 {
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


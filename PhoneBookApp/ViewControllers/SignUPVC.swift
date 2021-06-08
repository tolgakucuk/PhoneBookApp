

import UIKit
import Firebase
class SignUPVC: UIViewController {
    
    
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
        
        hideKeyboardWhenTappedAround()
       
    }
    
    
    @IBAction func SignUpClicked(_ sender: Any) {
        if(PhoneNumberText.text == ""){
            makeAlert(title: "Error", message: "Please enter a phone number")
        }
        else if(EmailText.text == ""){
            makeAlert(title: "Error", message: "Please enter an email")
        }
        else if(PasswordText.text == ""){
            makeAlert(title: "Error", message: "Please enter your password")
        }
        else if(ConfirmPasswordText.text == ""){
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
                    self.makeAlert(title: "", message: "Signed succesfully. You can sign in")
                }
            }
        }
    }
    
    
    @IBAction func SignInClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: nil)
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

}


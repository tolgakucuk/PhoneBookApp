

import UIKit
import Firebase

class SignINVC: UIViewController {

    
    @IBOutlet weak var emailText: UITextField!{
        didSet{
            emailText.setLeftView(image: UIImage.init(named: "email")!)
        }
    }
    @IBOutlet weak var passwordText: UITextField!{
        didSet{
            passwordText.setLeftView(image: UIImage.init(named: "password")!)
        }
    }
    
    
    var indicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    //MARK: - Sign In Clicked
    @IBAction func SignInClicked(_ sender: Any) {
        self.startIndicator()
        if(emailText.text == ""){
            self.stopIndicator()
            makeAlert(title: "Error", message: "Please enter an email")
        }
        else if(passwordText.text == ""){
            self.stopIndicator()
            makeAlert(title: "Error", message: "Please enter your password")
        }else{
           
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (result, error) in
                if(error != nil){
                    self.stopIndicator()
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else{
                    self.stopIndicator()
                    self.performSegue(withIdentifier: "toContactsVC", sender: nil)
                }
            }
        }
    }
    
    
    //MARK: - Sign Up
    @IBAction func SignUpClicked(_ sender: Any) {
        self.startIndicator()
        performSegue(withIdentifier: "toSignUp", sender: nil)
    }
    
    //MARK: - Alert
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
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

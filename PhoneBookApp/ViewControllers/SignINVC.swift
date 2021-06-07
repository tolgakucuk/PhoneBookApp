//
//  SignInViewController.swift
//  PhoneBookApp
//
//  Created by Tolga on 5.06.2021.
//

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func SignInClicked(_ sender: Any) {
        if(emailText.text == ""){
            makeAlert(title: "Error", message: "Please enter an email")
        }
        else if(passwordText.text == ""){
            makeAlert(title: "Error", message: "Please enter your password")
        }else{
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (result, error) in
                if(error != nil){
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else{
                    self.performSegue(withIdentifier: "toContactsVC", sender: nil)
                }
            }
        }
    }
    
    
    
    @IBAction func SignUpClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: nil)
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

}

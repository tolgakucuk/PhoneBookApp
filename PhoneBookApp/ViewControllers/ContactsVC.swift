//
//  ContactsVC.swift
//  PhoneBookApp
//
//  Created by Tolga on 5.06.2021.
//

import UIKit
import Firebase
import SDWebImage
class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    
    @IBOutlet weak var tableView: UITableView!
    
    let fireStoreDatabase = Firestore.firestore()
    var contactArray = [Contact]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFromFirebase()
    }
    
    func getDataFromFirebase(){
        
        fireStoreDatabase.collection("Contacts").whereField("contactBy", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot, error) in
            if(error != nil){
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }else{
                if snapshot?.isEmpty == false && snapshot != nil{
                    self.fireStoreDatabase.collection("Contacts").order(by: "contactName", descending: false).addSnapshotListener { (snapshot, error) in
                        if(error != nil){
                            self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                        }else{
                            if snapshot?.isEmpty == false && snapshot != nil{
                                self.contactArray.removeAll(keepingCapacity: false)
                                for document in snapshot!.documents {
                                    if let contactName = document.get("contactName") as? String{
                                        if let contactUrl = document.get("imageUrl") as? String{
                                            if let contactSirname = document.get("contactSirname") as? String{
                                
                                                let contacts = Contact(contactName: contactName, contactSirname: contactSirname, contactUrl: contactUrl)
                                                self.contactArray.append(contacts)
                                            }
                                        }
                                    }
                                }
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
  
    @IBAction func addClicked(_ sender: Any) {
        performSegue(withIdentifier: "toAddContactVC", sender: nil)
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contactArray.count
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactsViewCell
        cell.contactImage.sd_setImage(with: URL(string: contactArray[indexPath.row].contactUrl))
        cell.contactNameLabel.text = contactArray[indexPath.row].contactName
        cell.contactSirnameLabel.text = contactArray[indexPath.row].contactSirname
        return cell
    }
    
    
}

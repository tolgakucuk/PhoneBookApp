
import UIKit
import Firebase
import SDWebImage


class ContactsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let fireStoreDatabase = Firestore.firestore()
    var contactArray = [Contact]()
    
    var letters: [Character] = []
    
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFromFirebase()
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getDataFromFirebase(){
        fireStoreDatabase.collection("Contacts").order(by: "contactName").addSnapshotListener { (snapshot, err) in
            if err == nil {
                if snapshot?.isEmpty == false && snapshot != nil {
                    self.contactArray.removeAll(keepingCapacity: false)
                    for document in snapshot!.documents {
                        if let uid = document.get("uid") as? String {
                            if uid == self.userId {
                                if let contactName = document.get("contactName") as? String, let _ = document.get("contactBy") as? String, let contactNote = document.get("contactNote") as? String, let contactPhone = document.get("contactPhone") as? String, let contactSirname = document.get("contactSirname") as? String, let imageUrl = document.get("imageUrl") as? String {
                                    self.contactArray.append(Contact(contactName: contactName, contactSirname: contactSirname, contactUrl: imageUrl, contactNote: contactNote, contactPhone: contactPhone, documentId: document.documentID))
                                }
                            }
                        }
                    }
                    //Section işlemi için
                    self.letters.removeAll(keepingCapacity: false)
                    self.letters = self.contactArray.map({ (contact) in
                        return contact.contactName.uppercased().first!
                    })
                    self.letters = self.letters.sorted()
                    self.letters = self.letters.reduce([], { (list, name) -> [Character] in
                        if !list.contains(name) {
                            return list + [name]
                        }
                        return list
                    })
                    self.tableView.reloadData()
                } else {
                    self.contactArray.removeAll(keepingCapacity: false)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func addClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddContactVC") as! AddContactVC
        vc.isNewContact = true
        self.present(vc, animated: true, completion: nil)
    }
  
}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        letters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return letters[section].description
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactsViewCell
        
        if letters[indexPath.section] == contactArray[indexPath.row].contactName.uppercased().first {
            cell.contactImage.sd_setImage(with: URL(string: contactArray[indexPath.row].contactUrl))
            cell.contactFullNameLabel.text = contactArray[indexPath.row].contactName + " " + contactArray[indexPath.row].contactSirname
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if letters[indexPath.section] == contactArray[indexPath.row].contactName.uppercased().first {
            return 100.0
        } else {
            return 0.0
        }
    }
    
    //hangi kişiye tıkladığını belirtir
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddContactVC") as! AddContactVC
        vc.isNewContact = false
        vc.documentId = contactArray[indexPath.row].documentId
        vc.contact = contactArray[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
}

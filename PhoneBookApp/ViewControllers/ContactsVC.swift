
import UIKit
import Firebase
import SDWebImage


class ContactsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var hiddenView: UIView!
    
    
    @IBOutlet weak var emptyView: UIView!
    let fireStoreDatabase = Firestore.firestore()
    var contactArray = [Contact]()
    var tempContactArray = [Contact]()
    
    var letters: [Character] = []
    var tempLetters: [Character] = []
    
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    var indicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        hideKeyboardWhenTappedAround()
        getDataFromFirebase()
    }
    
    //MARK: - Alert
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Function to Get Contacts Data From Firebase
    func getDataFromFirebase(){
        fireStoreDatabase.collection("Contacts").order(by: "contactName").addSnapshotListener { (snapshot, err) in
            if err == nil {
                if snapshot?.isEmpty == false && snapshot != nil {
                    self.contactArray.removeAll(keepingCapacity: false)
                    for document in snapshot!.documents {
                        if let uid = document.get("uid") as? String {
                            if uid == self.userId {
                                if let contactUrl = document.get("contactUrl") as? String,
                                   let contactName = document.get("contactName") as? String,
                                   let contactSirname = document.get("contactSirname") as? String,
                                   let contactPhone = document.get("contactPhone") as? String,
                                   let contactEmail = document.get("contactEmail") as? String,
                                   let contactBloodgroup = document.get("contactBloodGroup") as? String,
                                   let contactBirthday = document.get("contactBirthday") as? String{
                                    
                                    self.contactArray.append(Contact(contactUrl: contactUrl, contactName: contactName, contactSirname: contactSirname, contactPhone: contactPhone, contactEmail: contactEmail, contactBloodgroup: contactBloodgroup, contactBirthday: contactBirthday, documentId: document.documentID))
                                }
                                
                            }
                        }
                    }
                    self.tempContactArray = self.contactArray
                    
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
                    self.tempLetters = self.letters
                    self.tableView.reloadData()
                    
                } else {
                    self.contactArray.removeAll(keepingCapacity: false)
                    self.tableView.reloadData()
                }
                
                if(self.contactArray.count == 0) {
                    self.emptyView.isHidden = false
                    self.tableView.isHidden = true
                }else{
                    self.emptyView.isHidden = true
                    self.tableView.isHidden = false
                }
            }
        }
    }
    
    func getLetters(contact: [Contact]) {
        //Section işlemi için
        letters.removeAll(keepingCapacity: false)
        letters = contact.map({ (contact) in
            return contact.contactName.uppercased().first!
        })
        letters = letters.sorted()
        letters = letters.reduce([], { (list, name) -> [Character] in
            if !list.contains(name) {
                return list + [name]
            }
            return list
        })
    }
    
    @IBAction func addClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddContactVC") as! AddContactVC
        vc.isNewContact = true
        self.present(vc, animated: true, completion: nil)
    }
    
        
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            self.startIndicator()
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toSignIn", sender: nil)
        } catch  {
            makeAlert(title: "Error", message: "Logout error!")
        }
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



//MARK: - Table View Functions
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}

//MARK: - Search Bar
extension ContactsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        letters.removeAll(keepingCapacity: false)
        
        
        if searchText.isEmpty == false {
            contactArray = contactArray.filter{$0.contactName.lowercased().contains(searchText.lowercased())}
            for i in contactArray {
                print(i.contactName)
            }
            getLetters(contact: contactArray)
        } else {
            contactArray = tempContactArray
            letters = tempLetters
        }
        
        self.tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}

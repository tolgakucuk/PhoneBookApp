

import UIKit
import Firebase
class NotesVC: UIViewController {

    @IBOutlet weak var notesTableView: UITableView!
    
    let fireStoreDatabase = Firestore.firestore()
    var notesArray: [Contact] = []
    
    var letters: [Character] = []
    
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        getNotes()
    }
    
    func getNotes() {
        
        fireStoreDatabase.collection("Contacts").addSnapshotListener { (snapshot, err) in
            if err == nil {
                if snapshot?.isEmpty == false && snapshot != nil {
                    self.notesArray.removeAll(keepingCapacity: false)
                    for document in snapshot!.documents {
                        if let uid = document.get("uid") as? String {
                            if uid == self.userId {
                                if let contactName = document.get("contactName") as? String, let _ = document.get("contactBy") as? String, let contactNote = document.get("contactNote") as? String, let contactPhone = document.get("contactPhone") as? String, let contactSirname = document.get("contactSirname") as? String, let imageUrl = document.get("imageUrl") as? String {
                                    self.notesArray.append(Contact(contactName: contactName, contactSirname: contactSirname, contactUrl: imageUrl, contactNote: contactNote, contactPhone: contactPhone, documentId: document.documentID))
                                }
                            }
                        }
                    }
                    self.letters.removeAll(keepingCapacity: false)
                    self.letters = self.notesArray.map({ (contact) in
                        return contact.contactName.uppercased().first!
                    })
                    self.letters = self.letters.sorted()
                    self.letters = self.letters.reduce([], { (list, name) -> [Character] in
                        if !list.contains(name) {
                            return list + [name]
                        }
                        return list
                    })
                    self.notesTableView.reloadData()
                } else {
                    //herhangi bir veri kalmayınca (tüm verileri silerken en son kalan veriyide silmek için)
                    self.notesArray.removeAll(keepingCapacity: false)
                    self.notesTableView.reloadData()
                }
            }
        }
        
    }
    
    

}


extension NotesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        letters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return letters[section].description
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if letters[indexPath.section] == notesArray[indexPath.row].contactName.uppercased().first {
            return 100.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotesCell
        
        if letters[indexPath.section] == notesArray[indexPath.row].contactName.uppercased().first {
            cell.notesLabel.text = notesArray[indexPath.row].contactNote
            cell.nameLabel.text = notesArray[indexPath.row].contactName + " " +  notesArray[indexPath.row].contactSirname
        }
        
        return cell
    }
    
    
}

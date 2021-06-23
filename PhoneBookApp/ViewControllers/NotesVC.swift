

import UIKit
import Firebase
class NotesVC: UIViewController {

    @IBOutlet weak var notesTableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    
    let fireStoreDatabase = Firestore.firestore()
    var notesArray: [Note] = []
    
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
    
    //MARK: - Plus Button Clicked
    @IBAction func plusClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddNoteVC") as! AddNoteVC
        vc.isNewNote = true
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: - Function to Get Notes Data From Firebase
    func getNotes() {
        
        fireStoreDatabase.collection("Notes").order(by: "noteTitle").addSnapshotListener { (snapshot, err) in
            if err == nil {
                if snapshot?.isEmpty == false && snapshot != nil {
                    self.notesArray.removeAll(keepingCapacity: false)
                    for document in snapshot!.documents {
                        if let uid = document.get("uid") as? String {
                            if uid == self.userId {
                                if let noteName = document.get("noteName") as? String, let noteTitle = document.get("noteTitle") as? String {
                                    self.notesArray.append(Note(noteTitle: noteTitle, noteName: noteName, documentId: document.documentID))
                                }
                            }
                        }
                    }
                    self.letters.removeAll(keepingCapacity: false)
                    self.letters = self.notesArray.map({ (note) in
                        return note.noteTitle.uppercased().first!
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
                
                if(self.notesArray.count == 0 ){
                    self.emptyView.isHidden = false
                    self.notesTableView.isHidden = true
                }else{
                    self.emptyView.isHidden = true
                    self.notesTableView.isHidden = false
                }
            }
        }
        
    }
    
    

}

//MARK: - Table View Functions
extension NotesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        letters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return letters[section].description
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if letters[indexPath.section] == notesArray[indexPath.row].noteTitle.uppercased().first {
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
        
        if letters[indexPath.section] == notesArray[indexPath.row].noteTitle.uppercased().first {
            cell.notesLabel.text = notesArray[indexPath.row].noteName
            cell.nameLabel.text = notesArray[indexPath.row].noteTitle
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddNoteVC") as! AddNoteVC
        vc.isNewNote = false
        vc.documentId = notesArray[indexPath.row].documentId
        vc.note = notesArray[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    
}

import UIKit
import RealmSwift

class ChatViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var SendChatTextField: UITextField!
    @IBOutlet weak var NavigationLabel: UINavigationItem!
    @IBOutlet weak var MessageTextFieldLabel: UITextField!
    
    let realm = try! Realm()
    var friend = Friend()
    var messages : Results<Message>?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.CollectionView.dataSource = self
        self.CollectionView.delegate = self
        self.NavigationLabel.title =  friend.firstname
        self.messages = realm.objects(Message.self).filter("receiver = '\(self.friend.username)'")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // telling the controller to use the reusuable 'receivecell' from chatCollectionViewCell
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ReceiveCell",
            forIndexPath: indexPath) as! ChatCollectionViewCell
        
        // use this cell for all received chats
        cell.receiveChatLabel.layer.cornerRadius = 5
        cell.receiveChatLabel.layer.masksToBounds = true
        
        // use this cell for chats user sends
        // cell.sendChatLabel.layer.cornerRadius = 5
        // cell.sendChatLabel.layer.masksToBounds = true
        
        // sample chat
        cell.receiveChatLabel.text = self.messages![indexPath.row].text
        return cell
    }
 
    @IBAction func sendButtonTapped(sender: AnyObject) {
        print("my friend", friend)
        let message = Message()
        message.text = self.MessageTextFieldLabel.text!
        message.receiver = friend.username
        message.sender = realm.objects(User)[0].username
        
        try! realm.write {
            realm.add(message)
            let sent = realm.objects(Message)
            print(sent)
        }
    }
    
  }

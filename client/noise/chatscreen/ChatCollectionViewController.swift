import UIKit
import RealmSwift

class ChatViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var SendChatTextField: UITextField!
    @IBOutlet weak var NavigationLabel: UINavigationItem!
    @IBOutlet weak var MessageTextFieldLabel: UITextField!
    
    let realm = try! Realm()
    var friend = Friend()
    var messages = List<Message>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure states
        self.CollectionView.dataSource = self
        self.CollectionView.delegate = self
        self.NavigationLabel.title = friend.firstname
        updateChatScreen()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func updateChatScreen() {
        if realm.objects(Conversation).filter("friendId = \(friend.friendID) ").count == 0 {
            try! realm.write{
                let startNewConversation = Conversation()
                startNewConversation.friendId = friend.friendID
                realm.add(startNewConversation)
            }
        } else {
            self.messages = realm.objects(Conversation).filter("friendId = \(friend.friendID) ")[0].messages
            print("not new", realm.objects(Conversation).filter("friendId = \(friend.friendID) "))
        }
        self.CollectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // telling the controller to use the reusuable 'receivecell' from chatCollectionViewCell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SendCell",
            forIndexPath: indexPath) as! ChatCollectionViewCell
        
        // use this cell for all received chats
        // cell.receiveChatLabel.layer.cornerRadius = 5
        // cell.receiveChatLabel.layer.masksToBounds = true
        
        // use this cell for chats user sends
        cell.sendChatLabel.layer.cornerRadius = 5
        cell.sendChatLabel.layer.masksToBounds = true
        cell.sendChatLabel.clipsToBounds = true
        //cell.sendChatLabel.text = self.messages![indexPath.row].text
        return cell
    }
 
    @IBAction func sendButtonTapped(sender: AnyObject) {
        let newMessage = Message()
        newMessage.sourceID = realm.objects(User)[0].userID
        newMessage.targetID = friend.friendID
        newMessage.body = self.SendChatTextField.text!
        
        try! realm.write{
            let conversationHistory = realm.objects(Conversation).filter("friendId = \(friend.friendID) ")[0].messages
            conversationHistory.append(newMessage)
            print("new history added", conversationHistory)
            updateChatScreen()
        }
        
        // send newMessage obj to socket
            // wait/listen for messageId from server
            // upon receive, query realm for the same newMessage sent
                // update message obj's messageID property
        
    }
    
  }


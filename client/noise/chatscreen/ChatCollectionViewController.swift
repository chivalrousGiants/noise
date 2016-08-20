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
    var newMessage = [String: AnyObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure states
        self.CollectionView.dataSource = self
        self.CollectionView.delegate = self
        self.title = friend.firstname
        updateChatScreen()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
 
    func updateChatScreen() {
        if realm.objects(Conversation).filter("friendID = \(friend.friendID) ").count == 0 {
            try! realm.write{
                let startNewConversation = Conversation()
                startNewConversation.friendID = friend.friendID
                realm.add(startNewConversation)
                print("instantiated a conversation")
            }
        } else {
            self.messages = realm.objects(Conversation).filter("friendID = \(friend.friendID) ")[0].messages
            self.CollectionView.reloadData()
        }
     
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // tell the controller to use the reusuable 'receivecell' from chatCollectionViewCell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SendCell",
            forIndexPath: indexPath) as! ChatCollectionViewCell
        
        // use this cell for all received chats
        // cell.receiveChatLabel.layer.cornerRadius = 5
        // cell.receiveChatLabel.layer.masksToBounds = true
        
        // use this cell for chats user sends
        cell.sendChatLabel.layer.cornerRadius = 5
        cell.sendChatLabel.layer.masksToBounds = true
        cell.sendChatLabel.clipsToBounds = true
        cell.sendChatLabel.text = self.messages[indexPath.row].body
        return cell
    }
 
    @IBAction func sendButtonTapped(sender: AnyObject) {
        self.newMessage = [
                "sourceID" : realm.objects(User)[0].userID,
                "targetID" : self.friend.friendID,
                "body"     : self.SendChatTextField.text!
            ]
        
//        newMessage.sourceID = realm.objects(User)[0].userID
//        newMessage.targetID = friend.friendID
//        newMessage.body = self.SendChatTextField.text!
//        
        // for immediate persistence to improve UX
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleNewMessage), name: "newMessage", object: nil)
        
        SocketIOManager.sharedInstance.sendEncryptedChat(newMessage)
        
    
        // send newMessage obj to socket
            // wait/listen for messageId from server
            // upon receive, query realm for the same newMessage sent
                // update message obj's messageID property
        
    }
    
    @objc func handleNewMessage(notification: NSNotification) -> Void {
        let message = Message()
        message.sourceID = self.newMessage["sourceID"] as! Int
        message.targetID = self.newMessage["targetID"] as! Int
        message.body = self.newMessage["body"] as! String
        message.messageID = Int(notification.userInfo!["messageID"] as! String)!
        
        let conversationHistory = realm.objects(Conversation).filter("friendID = \(self.friend.friendID)")[0]
        
        try! realm.write{
            conversationHistory.largestMessageID = message.messageID
            conversationHistory.messages.append(message)
            // TODO: optimize such that only new message is loaded.=
            updateChatScreen()
        }
        
        
    }
    
  }


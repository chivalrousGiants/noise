import UIKit
import RealmSwift

class ChatViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var SendChatTextField: UITextField!
    @IBOutlet weak var NavigationLabel: UINavigationItem!
    @IBOutlet weak var MessageTextFieldLabel: UITextField!
    
    let realm = try! Realm()
    
    // passed in by FriendslistViewController
    var friend = Friend()
    //  var below wont be needed as soon as friendId incorp in redis schema
    var friendID = 2
    
    var messages = List<Message>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CollectionView.dataSource = self
        self.CollectionView.delegate = self
        
        
        self.NavigationLabel.title = friend.firstname

        
//        try! realm.write{
//            let newConversation = Conversation()
//            newConversation.friendId = friendID
//            realm.add(newConversation)
//            
//        }
       print("add Convo Class", realm.objects(Conversation))
        
        try! realm.write{
            let newMessage = Message()
            newMessage.sourceID = 111
            newMessage.targetID = 222
            newMessage.body = "dummy"
            newMessage.messageID = 333
            
            let addMessageToConvo = realm.objects(Conversation).filter("friendId = \(friendID) ")[0]
            addMessageToConvo.messages.append(newMessage)
            
            print("this is addMessageObeject", addMessageToConvo)
            
        }
        
        updateChatScreen()
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
        //(self.messages?.count)!
    }
    
    func updateChatScreen() {
        self.messages = realm.objects(Conversation).filter("friendId = \(friendID) ")[0].messages
        print("printing messages", self.messages)
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
        let message = Message()
         message.sourceID = friendID
        // message.text = self.MessageTextFieldLabel.text!
        // message.receiver = friend.username
        // message.sender = realm.objects(User)[0].username
        
        try! realm.write {
            realm.add(message)
            updateChatScreen()
        }
    }
    
  }

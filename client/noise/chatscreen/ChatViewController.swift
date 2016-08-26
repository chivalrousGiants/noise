import UIKit
import RealmSwift
import JSQMessagesViewController
import Locksmith
import CryptoSwift

class ChatViewController: JSQMessagesViewController {
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.greenColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    // Must be 8 or 16 bytes (TODO: randomize)
    let iv: Array<UInt8> = [0, 1, 2, 3, 4, 5, 6, 7]
    
    let realm = try! Realm()
    var messagesFromRealm = List<Message>()
    var messages = [JSQMessage]()
    var newMessage = [String: AnyObject]()
    var friend = Friend()
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setup()
        self.updateChatScreen()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector (handleNewMessage), name: "newMessage", object: nil)
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
}

//Navigation methods
extension ChatViewController {
    
    func setup() {
        self.title = self.friend.username
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
        
        let friendInfoButton = UIBarButtonItem(title: "info", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(friendInfoButtonTapped))
        self.navigationItem.rightBarButtonItem = friendInfoButton
    }
    
    func friendInfoButtonTapped() -> Void {
        let friendInfoViewController = FriendInfoViewController()
        friendInfoViewController.friendInfo = self.friend
        self.presentViewController(UINavigationController(rootViewController: friendInfoViewController), animated: true, completion: nil)
    }
    
    func updateChatScreen() {
        if realm.objects(Conversation).filter("friendID = \(friend.friendID) ").count == 0 {
            print("-----ERROR: SEGUED TO CHAT SCREEN W/O INSTANTIATING CHAT OBJECT------")
        } else {
            self.messagesFromRealm = realm.objects(Conversation).filter("friendID = \(friend.friendID)")[0].messages
            for realmMessage in self.messagesFromRealm {
                let message = JSQMessage(senderId: String(realmMessage.sourceID), displayName: "sender display name", text: realmMessage.body)
                self.messages += [message]
            }
            self.reloadMessagesView()
        }
    }
    
    @objc func handleNewMessage(notification: NSNotification) -> Void {
        let userInfo = notification.userInfo!
        
        print("userInfo in handleNewMessage", userInfo)
        
        let sourceID = userInfo["sourceID"] as? Int
        let message = Message()
        
        if (sourceID != nil) {
            // reciever
            if (sourceID == self.friend.friendID) {
                message.sourceID = sourceID!
                message.targetID = userInfo["targetID"] as! Int
                
                // userInfo["body"] is of type '_NSInlineData'
                
                message.body = userInfo["body"] as! String
                message.messageID = Int((userInfo["messageID"] as! NSString).doubleValue)
                message.createdAt = userInfo["createdAt"] as! Int
            } else {
                return
            }
        } else {
            // sender
            message.sourceID = self.newMessage["sourceID"] as! Int
            message.targetID = self.newMessage["targetID"] as! Int
            message.body = self.newMessage["body"] as! String
            message.messageID = Int(userInfo["messageID"] as! String)!
            message.createdAt = userInfo["createdAt"] as! Int
        }
        
        try! realm.write{
            let conversationHistory = realm.objects(Conversation).filter("friendID = \(self.friend.friendID)")[0]
            conversationHistory.largestMessageID = message.messageID
            conversationHistory.messages.append(message)
            
            // TODO: optimize such that only new message is loaded.
            updateChatScreen()
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

//UI Configurations
extension ChatViewController  {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = self.messages[indexPath.row]
        
        if Int(data.senderId) == self.friend.friendID {
            return self.incomingBubble
        } else {
            return self.outgoingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}

extension ChatViewController {

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        // Encrypt message
        //let key = String(Locksmith.loadDataForUserAccount("noise:\(self.friend.friendID)")!["sharedSecret"]!)
        let key = "3438466385"
        print("In CCVC sharedSecret for encryption of new message:", key)
        
        var keyToUInt8Array = [UInt8](key.utf8)

        // pad keyToUInt8Array to 32 bytes
        let initialLength = 32 - keyToUInt8Array.count
        for _ in 1...initialLength {
            keyToUInt8Array.append(0)
        }
        
        let encryptedUInt8Array: Array<UInt8> = try! ChaCha20(key: keyToUInt8Array, iv: self.iv)!.encrypt([UInt8](text.utf8))
        print("encryptedUInt8Array", encryptedUInt8Array)
        
        // TODO: account for sending serveral messages in rapid succession (newMessage will be overwritten for now)
        self.newMessage = [
            "sourceID" : realm.objects(User)[0].userID,
            "targetID" : self.friend.friendID,
            "body"     : text
        ]
        
        let encryptedMessage: [String:AnyObject] = [
            "sourceID" : realm.objects(User)[0].userID,
            "targetID" : self.friend.friendID,
            "body"     : NSData(bytes: encryptedUInt8Array)
        ]
        
        // future refactor: consider immediate persistence (w/o waiting for the server to return) to improve UX
        SocketIOManager.sharedInstance.sendEncryptedChat(encryptedMessage)

        //let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        //self.messages += [message]
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }
}


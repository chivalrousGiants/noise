import Foundation
import UIKit
import RealmSwift

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://localhost:4000")!)
 //   let realm = try! Realm()
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
        
        socket.on("redis response for signin") { (userArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("signin", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response for signup") { (userArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("signup", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        // Listener for AddFriend endpoint
        socket.on("redis response checkUser") { (userArray, socketAck) -> Void in
           // print("redis response checkUser", userArray)
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response checkMessages") {(messageArray, socketAck) -> Void in
           // print("redis response checkMessages", messageArray)
            NSNotificationCenter.defaultCenter().postNotificationName("checkMessage", object: nil, userInfo: messageArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("successfully sent new message") {(messageArray, socketAck) -> Void in
            print("successfully sent new message", messageArray)
            print("sent message", messageArray[0])
            
            NSNotificationCenter.defaultCenter().postNotificationName("newMessage", object: nil, userInfo: messageArray[0] as? Dictionary)
        }
        
        socket.on("receive new message") {(messageArray, socketAck) -> Void in
            print("received message", messageArray[0])
            NSNotificationCenter.defaultCenter().postNotificationName("newMessage", object: nil, userInfo: messageArray[0] as? Dictionary)
        
        }
        
        socket.on("redis response for retrieveNewMessages") {(messageArray, socketAck) -> Void in
            //print("retrieve new messages", messageArray[0])
            NSNotificationCenter.defaultCenter().postNotificationName("retrievedNewMessages", object: nil, userInfo: ["messages" : messageArray[0]] as Dictionary)
        }
        

        socket.on("redis response KeyExchange complete") { (dhxInfo, socketAck) -> Void in
            print("KeyExchange complete")
            NSNotificationCenter.defaultCenter().postNotificationName("KeyExchangeComplete", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response KeyExchange initiated") { (dhxInfo, socketAck) -> Void in
            print("initiating keyExchange")
            NSNotificationCenter.defaultCenter().postNotificationName("stillPursuingKeyExchange", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        socket.on("redis response no need to undertake KeyExchange") { (userArray, socketAck) -> Void in
            print("no need to pursue keyExchange")
            NSNotificationCenter.defaultCenter().postNotificationName("KeyExchange dropped", object: nil)
        }
        socket.on("redis response retreived intermediary dhxInfo") { (dhxInfo, socketAck) -> Void in
            print("retreived stage1 dhxInfo")
             NSNotificationCenter.defaultCenter().postNotificationName("computeBob", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        socket.on("redis response Bob complete, Alice still pending") { (dhxInfo, socketAck) -> Void in
            print("user Bob complete")
            NSNotificationCenter.defaultCenter().postNotificationName("bobComplete", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
    }
    
    func signIn(user: Dictionary<String, String>) {
        socket.emit("signIn", user)
    }
    
    func signUp(user: Dictionary<String, String>) {
        socket.emit("signUp", user)
    }
    
    // TODO: send encrypted message
    func sendEncryptedChat(message: Dictionary<String, AnyObject>){
        socket.emit("encryptedChatSent", message)
    }
    func retrieveMessages(userID: Int, friends: Dictionary<String, Int>) {
        print("executing retrieveMessages", userID, friends)
        socket.emit("initial retrieval of new messages", userID, friends)
    }
    
    // newFriend is the username
    func addFriend(newFriend: String) {
        socket.emit("find new friend", newFriend)
    }
    
    func undertakeKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        socket.emit("check for pending key exchange", dhxInfo)
    }
    
    func checkForPendingKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        print("on login check for pending key exchange")
        //print("TEST: \(realm.objects(Conversation.self).filter("friendID = \(self.friendToChat["friendID"])").filter("friendID = \(self.friendToChat["friendID"])"))")
        //if(realm.objects(Conversation.self).filter("friendID = \(self.friendToChat["friendID"])").filter("friendID = \(self.friendToChat["friendID"])")) {
           socket.emit("check for pending key exchange", dhxInfo)
        //}
        //else, send notification: 
          //NSNotificationCenter.defaultCenter().postNotificationName("stillPursuingKeyExchange", object: nil)
    }
    func commencePart2KeyExchange (bob: Dictionary<String, AnyObject>) {
        print("hit commencePt2 keyX w \(bob)")
        socket.emit("commence part 2 key exchange", bob)
    }
    
    func closeConnection() {
        socket.disconnect()
    }


}

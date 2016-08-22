import Foundation
import UIKit
import RealmSwift

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://localhost:4000")!)
    let realm = try! Realm()
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
        
        socket.on("redis response KeyExchange complete") { (user, socketAck) -> Void in
            print("KeyExchange complete")
            NSNotificationCenter.defaultCenter().postNotificationName("KeyExchangeComplete", object: nil)
        }
        
        socket.on("redis response KeyExchange initiated") { (userArray, socketAck) -> Void in
            print("initiating keyExchange")
            NSNotificationCenter.defaultCenter().postNotificationName("stillPursuingKeyExchange", object: nil)
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
        }
    }
    
    func signIn(user: Dictionary<String, String>) {
        socket.emit("signIn", user)
    }
    
    func signUp(user: Dictionary<String, String>) {
        socket.emit("signUp", user)
    }
    
    // TODO: send encrypted message
    func sendEncryptedChat(message: String){
        socket.emit("encryptedChatSent", message)
    }
    
    // newFriend is the username
    func addFriend(newFriend: String) {
        socket.emit("find new friend", newFriend)
    }
    
    func undertakeKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        socket.emit("check for pending key exchange", dhxInfo)
    }
    
    func checkForPendingKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        print("on load check for pending key exchange")
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

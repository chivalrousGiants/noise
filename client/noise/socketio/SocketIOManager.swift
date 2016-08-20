import Foundation
import UIKit
import RealmSwift

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://localhost:4000")!)
    
    override init() {
        super.init()
        //TODO: get below line to hit server on app init
        //self.checkForPendingKeyExchange() <<gets called, but doesn't hit server
    }
    
    func establishConnection() {
        socket.connect()
        //TODO: get below line to hit server on app init
        //self.checkForPendingKeyExchange() <<gets called, but doesn't hit server
        socket.on("redis response for signin") { (userArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("signin", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response for signup") { (userArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("signup", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        // Listener for AddFriend endpoint
        socket.on("redis response checkUser") { (userArray, socketAck) -> Void in
            print("redis response checkUser", userArray)
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response checkMessages") {(messageArray, socketAck) -> Void in
            print("redis response checkMessages", messageArray)
            NSNotificationCenter.defaultCenter().postNotificationName("checkMessage", object: nil, userInfo: messageArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response KeyExchange complete") { (user, socketAck) -> Void in
            print("KeyExchange complete")
            NSNotificationCenter.defaultCenter().postNotificationName("KeyExchangeComplete", object: nil)
        }
        
        socket.on("redis response KeyExchange initiated") { (userArray, socketAck) -> Void in
            print("pursuing keyExchange")
            NSNotificationCenter.defaultCenter().postNotificationName("stillPursuingKeyExchange", object: nil)
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
        socket.emit("initial key query", dhxInfo)
    }
    
    func checkForPendingKeyExchange (userID: AnyObject) {
        print("on load check for pending key exchange")
        //print("TEST: \(realm.objects(Conversation.self).filter("friendID = \(self.friendToChat["friendID"])").filter("friendID = \(self.friendToChat["friendID"])"))")
        //if(realm.objects(Conversation.self).filter("friendID = \(self.friendToChat["friendID"])").filter("friendID = \(self.friendToChat["friendID"])")) {
           socket.emit("check for pending key exchange", userID)
        //}
        //else, send notification: 
          //NSNotificationCenter.defaultCenter().postNotificationName("stillPursuingKeyExchange", object: nil)
    }
    
    func closeConnection() {
        socket.disconnect()
    }


}

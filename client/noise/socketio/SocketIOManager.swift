import Foundation
import UIKit
import RealmSwift

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://localhost:4000")!)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
        
        socket.on("redis response for signin") { (userArray, socketAck) -> Void in
            print("redis response for signin", userArray[0])
            NSNotificationCenter.defaultCenter().postNotificationName("signin", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response for signup") { (userArray, socketAck) -> Void in
            print("redis response for signup", userArray[0])
            NSNotificationCenter.defaultCenter().postNotificationName("signup", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        // Listener for AddFriend endpoint
        socket.on("redis response checkUser") { (userArray, socketAck) -> Void in
            // print("redis response checkUser", userArray)
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response checkMessages") {(messageArray, socketAck) -> Void in
            print("redis response checkMessages", messageArray)
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
    
    func retrieveMessages(userID: Int, friends: Dictionary<String, Int>) {
        print("executing retrieveMessages", userID, friends)
        socket.emit("initial retrieval of new messages", userID, friends)
    }
    
    // TODO: change this to 1) encrypted message 2) noisified message --both dictionaries
    func sendEncryptedChat(message: AnyObject){
      
        ///let newmessage = realm.objects(Conversation).filter("friendID = \(messageID)")
        print("newMessage", message)
        
        socket.emit("send new message", message)
    }
    
    //TODO: Modify as needed
    func sendNoisifiedChat(messageDP: String){
        socket.emit("noisifiedChatSent", messageDP)

    }
    
    // newFriend is the username
    func addFriend(newFriend: String) {
        socket.emit("find new friend", newFriend)
    }
    
    func undertakeKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        socket.emit("initial key query", dhxInfo)
    }
    
    func checkForPendingKeyExchange () {
        socket.emit("check for pending key exchange")
    }
    
    func closeConnection() {
        socket.disconnect()
    }


}

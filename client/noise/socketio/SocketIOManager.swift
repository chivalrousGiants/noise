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
        
        //socket.on("redis response checkMessages") {(messageArray, socketAck) -> Void in
           // print("redis response checkMessages", messageArray)
           // NSNotificationCenter.defaultCenter().postNotificationName("checkMessage", object: nil, userInfo: messageArray[0] as? [NSObject : AnyObject])
        //}
    }
    
    func signIn(user: Dictionary<String, String>) {
        socket.emit("signIn", user)
    }
    
    func signUp(user: Dictionary<String, String>) {
        socket.emit("signUp", user)
    }
    
    // change this to 1) encrypted message 2) noisified message --both dictionaries
    func sendEncryptedChat(message: AnyObject){
        print("From socket func, sendEncryptedChat: \(message)")
        
        socket.emit("encryptedChatSent", message)
    }
    
    //TODO: Modify as needed
    func sendNoisifiedChat(messageDP: String){
        socket.emit("noisifiedChatSent", messageDP)
        
        // listen for successfully added
        socket.on("DP message sent") { (messageDP) -> Void in
            
        }
        
        // listen for fail
    }
    
    // newFriend is the username
    func addFriend(newFriend: String) {
        socket.emit("find new friend", newFriend)
    }
    
    func undertakeKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        socket.emit("initial key query", dhxInfo)
    }
    
    func closeConnection() {
        socket.disconnect()
    }

}

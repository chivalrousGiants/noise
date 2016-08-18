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
        
        socket.on("redis response undertake KeyExchange") { (userArray, socketAck) -> Void in
            print("Still need to undertakeKeyExchange : ")
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: nil)
        }
        socket.on("redis response no need to undertake KeyExchange") { (userArray, socketAck) -> Void in
            print("KeyExchange dropped")
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: nil)
        }
        socket.on("keyExchange initiated") { (userArray, socketAck) -> Void in
            print("keyExchange initiated")
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: nil)
        }
    }
    
    func signIn(user: Dictionary<String, String>) {
        socket.emit("signIn", user)
    }
    
    func signUp(user: Dictionary<String, String>) {
        socket.emit("signUp", user)
    }
    
    // TODO: change this to 1) encrypted message 2) noisified message --both dictionaries
    func sendEncryptedChat(message: String){
        socket.emit("encryptedChatSent", message)
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
        print("Test: hit initiKeyExchange socket with dhxObj: \(dhxInfo)")
        socket.emit("initial key query", dhxInfo)
    }
    
    func closeConnection() {
        socket.disconnect()
    }

}

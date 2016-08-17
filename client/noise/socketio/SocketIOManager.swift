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
            NSNotificationCenter.defaultCenter().postNotificationName("signin", object: userArray[0] as? Dictionary<String, String>)
        }
        
        socket.on("redis response for signup") { (userArray, socketAck) -> Void in
            print("redis response for signup", userArray[0])
            NSNotificationCenter.defaultCenter().postNotificationName("signup", object: userArray[0] as? Dictionary<String, String>)
        }
        
        // Listener for AddFriend endpoint
        socket.on("redis response checkUser") { (userArray, socketAck) -> Void in
            print("redis response checkUser", userArray)
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: userArray[0] as? Dictionary<String, String>)
        }
    }
    
    func signIn(user: Dictionary<String, String>) {
        // TEST: ping socket, display in console
        print("Test: hit signIn func for user: \(user)")
        
        // SEND: userData to db
        socket.emit("signIn", user)
    }
    
    func signUp(user: Dictionary<String, String>) {
        // TEST: ping socket, display in console
        print("Test: hit signUp func for user: \(user)")
        
        // SEND: userData to db
        socket.emit("signUp", user)
    }
    
    // change this to 1) encrypted message 2) noisified message --both dictionaries
    func sendEncryptedChat(message: String){
        print("From socket func, sendChat: \(message)")
        
        //
        socket.emit("encryptedChatSent", message)
    }
    
    // Dictionary<String, String>
    func sendNoisifiedChat(messageDP: String){
        print("TEST: socketMGMT sendingDPChat: \(messageDP)")
        socket.emit("noisifiedChatSent", messageDP)
        
        //listen for successfully added
        socket.on("DP message sent") { (messageDP) -> Void in
            
        }
        
        //listen for fail
    }
    
    // newFriend is the username
    func addFriend(newFriend: String) {
        
        print("Test: socket func, addFriend with username: \(newFriend)")
        
        // Query redis db
        socket.emit("find new friend", newFriend)
    }
    
    func closeConnection() {
        socket.disconnect()
    }

}

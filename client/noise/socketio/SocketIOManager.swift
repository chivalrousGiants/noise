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
            print("redis response checkUser", userArray)
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
    }
    
    func signIn(user: Dictionary<String, String>) {
        print("Test: hit signIn func for user: \(user)")
        socket.emit("signIn", user)
    }
    
    func signUp(user: Dictionary<String, String>) {
        print("Test: hit signUp func for user: \(user)")
        socket.emit("signUp", user)
    }
    
    // TODO: change this to 1) encrypted message 2) noisified message --both dictionaries
    func sendEncryptedChat(message: String){
        print("From socket func, sendChat: \(message)")
        socket.emit("encryptedChatSent", message)
    }
    
    //TODO: Modify as needed
    func sendNoisifiedChat(messageDP: String){
        print("TEST: socketMGMT sendingDPChat: \(messageDP)")
        socket.emit("noisifiedChatSent", messageDP)

    }
    
    // newFriend is the username
    func addFriend(newFriend: String) {
        print("Test: socket func, addFriend with username: \(newFriend)")
        socket.emit("find new friend", newFriend)
    }
    
    func initKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        print("Test: hit initiKeyExchange socket with dhxObj: \(dhxInfo)")
        socket.emit("initial key query", dhxInfo)
    }
    
    func closeConnection() {
        socket.disconnect()
    }

}

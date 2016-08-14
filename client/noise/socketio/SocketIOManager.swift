
import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://localhost:4000")!)
    
    override init() {
        super.init()
    }
    
    
    func establishConnection() {
        socket.connect()
    }
    /*change this to 1) encrypted message 2) noisified message --both dictionaries*/
    func sendEncryptedChat(message: String){
        print("From socket func, sendChat: \(message)")
        socket.emit("encryptedChatSent", message)
    }
    
    func sendNoisifiedChat(messageDP: Dictionary<String, String>){
        print("TEST: socketMGMT sendingDPChat: \(messageDP)")
        socket.emit("noisifiedChatSent", messageDP)
    }
    
    func addFriend(newFriend: String){
        print("Test: socket func, addFriend: \(newFriend)")
        socket.emit("friendAdded", newFriend)
          //Query db for existing friend
    }

    func signIn(user: Dictionary<String, String>, handleSignIn: (success: Bool) -> Void){
        print("Test: hit signIn func for user: \(user)")
        socket.emit("signIn", user)
        
        socket.on("signIn unsuccessful") { (userArray, socketAck) -> Void in
            print("Unsuccessful userArray", userArray)
            handleSignIn(success: false)
        }
        
        socket.on("signIn successful") { (userArray, socketAck) -> Void in
            print("Successful userArray", userArray)
            handleSignIn(success: true)
        }
    }
    
    func signUp(username: Dictionary<String, String>) {
        print("Test: socket func, addUser: \(username)")
        socket.emit("userSigningIn", username)
            //Query db for existing user.
            //if NO existing user
               //insert into db
    }
    func closeConnection() {
        socket.disconnect()
    }

}

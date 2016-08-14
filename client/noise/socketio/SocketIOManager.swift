
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
        //TEST:ping socket, display in console
        print("Test: hit signIn func for user: \(user)")
        
        //SEND: userData to db
        socket.emit("signIn", user)
        
          //FAIL: receive user_sign_in_data back from db
        socket.on("signIn unsuccessful") { (userArray, socketAck) -> Void in
            print("Unsuccessful userMatch", userArray)
            handleSignIn(success: false)
        }
        
         //SUCCESS: receive user_sign_in_data back from db
        socket.on("signIn successful") { (userArray, socketAck) -> Void in
            print("Successful userMatch", userArray)
            handleSignIn(success: true)
        }
    }
    
    func signUp(user: Dictionary<String, String>, handleSignUp: (success: Bool) -> Void) {
        //TEST:ping socket, display in console
        print("Test: socket func, addUser: \(user)")
        
        //TODO: if pwText1 matches pwText2
        
        //SEND: userData to db
        socket.emit("userSigningUp", user)
        
        
        //SUCCESS: receive user_sign_in_data back from db
        socket.on("sign up success") { (user) -> Void in
            print("signUP success!!!", user)
            handleSignUp(success: true)
        }
        
        //FAIL: receive user_sign_UP_data back from db
        socket.on("username taken") { (user) -> Void in
            print("Unsuccessful userMatch", user)
            handleSignUp(success: false)
        }
    }
    func closeConnection() {
        socket.disconnect()
    }

}

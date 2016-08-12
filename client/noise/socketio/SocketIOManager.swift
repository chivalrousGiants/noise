
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
    
    func sendChat(message: String){
        print("From socket func, sendChat: \(message)")
        socket.emit("chatSent", message)
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    //for development purposes
    func signInOrSignUp(username: String) {
        socket.emit("signinOrSignup", username)
    }

}

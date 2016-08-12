
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
//TODO:
       // socket.emit()
       // socket.on()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    //for development purposes
    func signInOrSignUp(username: String, completionHandler:(username: String!) -> Void) {
        socket.emit("signinOrSignup", username)
    }

}

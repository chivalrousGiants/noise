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
        
        ///////////////////////////////////////
        /////////// User Auth routes
        socket.on("redis response for signin") { (userArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("signin", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response for signup") { (userArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("signup", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        // Listener for AddFriend endpoint
        socket.on("redis response checkUser") { (userArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("checkUser", object: nil, userInfo: userArray[0] as? [NSObject : AnyObject])
        }
        
        ///////////////////////////////////////
        /////////// Messages Routes
        socket.on("successfully sent new message") {(messageArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("newMessage", object: nil, userInfo: messageArray[0] as? Dictionary)
        }
        
        socket.on("receive new message") {(messageArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("newMessage", object: nil, userInfo: messageArray[0] as? Dictionary)
        }
        
        socket.on("redis response for retrieveNewMessages") {(messageArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("retrievedNewMessages", object: nil, userInfo: ["messages" : messageArray[0]] as Dictionary)
        }

        ///////////////////////////////////////
        /////////// DHKeyExchange routes
        socket.on("redis response KeyExchange complete") { (dhxInfo, socketAck) -> Void in
            // print("redis response KeyExchange complete", dhxInfo[0])
            NSNotificationCenter.defaultCenter().postNotificationName("KeyExchangeComplete", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response client must init") { (dhxInfo, socketAck) -> Void in
            // print("redis response client must init \(dhxInfo)")
            NSNotificationCenter.defaultCenter().postNotificationName("init KeyExchange", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response KeyExchange initiated") { (dhxInfo, socketAck) -> Void in
            // print("redis response KeyExchange initiated")
            NSNotificationCenter.defaultCenter().postNotificationName("completeKeyExchangeInitiation", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response retreived intermediary dhxInfo") { (dhxInfo, socketAck) -> Void in
            // print("retreived stage1 dhxInfo", dhxInfo[0])
            NSNotificationCenter.defaultCenter().postNotificationName("computeBob", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response Bob complete, Alice still pending") { (dhxInfo, socketAck) -> Void in
            // print("user Bob complete", dhxInfo[0])
            NSNotificationCenter.defaultCenter().postNotificationName("bobComplete", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        
        socket.on("redis response client has ongoing exchange") { (dhxInfo, socketAck) -> Void in
            // print("redis response client has ongoing exchange")
            NSNotificationCenter.defaultCenter().postNotificationName("wait", object: nil, userInfo: dhxInfo[0] as? [NSObject : AnyObject])
        }
        
        /*
        // TODO: Alert online friend of advancements in dhKeyExchange
        socket.on("redis response to client_Friend should check pending") { (userArray, socketAck) -> Void in
            // get ID & other info
            var myID = userArray[0]["friendID"]
            var friendID = userArray[0]["userID"]
            userArray["friendID"] = myID
            userArray.userID = friendID
            
            //just pass on DHX but mod it so id = friend id and friend id = id
            print("reordered dhxobj", userArray)
            self.checkForPendingKeyExchange(userArray[0] as! Dictionary<String, AnyObject>)
        }
        */
    }
    
    func signIn(user: Dictionary<String, String>) {
        socket.emit("signIn", user)
    }
    
    func signUp(user: Dictionary<String, String>) {
        socket.emit("signUp", user)
    }

    func sendEncryptedChat(message: AnyObject){
        socket.emit("send new message", message)
    }
    
    func retrieveMessages(userID: Int, friends: Dictionary<String, Int>) {
        socket.emit("initial retrieval of new messages", userID, friends)
    }
    
    // newFriend is the username
    func addFriend(newFriend: String) {
        socket.emit("find new friend", newFriend)
    }
    
    func checkNeedToInitKeyExchange (dhxInfo: Dictionary<String, AnyObject>){
        // print("hit checkNeedtoInitKeyExchanged on way to server")
        socket.emit("check need to init key exchange", dhxInfo)
    }
    
    func initiateKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        socket.emit("initiate key exchange", dhxInfo)
    }
    
    func checkForPendingKeyExchange (dhxInfo: Dictionary<String, AnyObject>) {
        // print("on loading of friendList check for pending key exchange")
        socket.emit("check for pending key exchange", dhxInfo)
    }
    
    func commencePart2KeyExchange (bob: Dictionary<String, AnyObject>) {
        // print("hit commencePt2 keyX w \(bob)")
        socket.emit("commence part 2 key exchange", bob)
    }
    
    func closeConnection() {
        socket.disconnect()
    }
}

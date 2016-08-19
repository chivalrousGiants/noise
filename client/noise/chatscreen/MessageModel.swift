import Foundation
import RealmSwift

class Message: Object {
    dynamic var sourceID = 0
    dynamic var targetID = 0
    dynamic var body = ""
    dynamic var createdAt = NSDate()
    dynamic var messageID = 0
}

class Conversation: Object {
    dynamic var friendId = 0
    let messages = List<Message>()
    dynamic var largestMessageID = 0
}

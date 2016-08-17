import Foundation
import RealmSwift

class Friend: Object {
    dynamic var username = ""
    dynamic var lastname = ""
    dynamic var firstname = ""
    dynamic var friendedAt = NSDate()
    dynamic var photo = ""
    dynamic var friendID = ""
    
    // boolean flag denoting whether a private chat has been initiated with this friend
    dynamic var chatInitiated: Bool = false
}

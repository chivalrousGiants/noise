import Foundation
import RealmSwift

class Message: Object {
    dynamic var text = ""
    dynamic var createdAt = NSDate()
    dynamic var receiver = ""
    dynamic var sender = ""

}

import Foundation
import RealmSwift

class User: Object {
    dynamic var username = ""
    dynamic var lastname = ""
    dynamic var firstname = ""
    dynamic var createdAt = NSDate()
    dynamic var photo = ""
    dynamic var userID = ""
    
}


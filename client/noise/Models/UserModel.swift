import Foundation
import RealmSwift

class User: Object {
    dynamic var username = ""
    dynamic var lastname = ""
    dynamic var firstname = ""
    dynamic var createdAt = NSDate()
    dynamic var photo = ""
    dynamic var userID = 0
    
    
    // Primary key
    dynamic var ID = 0
    
    override static func primaryKey() -> String? {
        return "ID"
    }
}


import Foundation
import RealmSwift

class User: Object {
    dynamic var username = ""
    dynamic var lastname = ""
    dynamic var firstname = ""
    dynamic var createdAt = NSDate()
    dynamic var photo = ""
    
    // Primary key
    dynamic var id = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


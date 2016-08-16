import Foundation
import RealmSwift

class Friend: Object {
    dynamic var friendUsername = ""
    dynamic var friendLastname = ""
    dynamic var friendFirstame = ""
    dynamic var friendedAt = NSDate()
    dynamic var friendPhoto = ""
    dynamic var friendID = ""
}

import RealmSwift

// MARK: - Model
@objcMembers
class Task: Object {
    dynamic var taskName = ""
    dynamic var isCompleted = false
}

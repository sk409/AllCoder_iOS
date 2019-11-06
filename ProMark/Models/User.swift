
class User: Decodable {
    
    let id: Int
    let name: String
    let bioText: String
    let profileImagePath: String?
    let email: String
    let purchasedMaterials: [Material]
    let createdMaterials: [Material]
    //let lessonCompletions: [LessonCompletion]
    let createdAt: String
    let updatedAt: String
    
}

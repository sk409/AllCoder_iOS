
class User: Decodable {
    
    let id: Int
    let name: String
    let bioText: String
    let profileImageBlob: String?   //  TODO: 修正
    let email: String
    let emailVerifiedAt: String?   //  TODO: 修正
    let purchasedMaterials: [Material]
    let createdMaterials: [Material]
    let lessonCompletions: [LessonCompletion]
    let createdAt: String
    let updatedAt: String
    
}

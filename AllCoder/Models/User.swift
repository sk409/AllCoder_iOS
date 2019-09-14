

class User: Decodable {
    
    let id: Int
    let name: String
    let bioText: String
    let profileImageBlob: String?   //  TODO: 修正
    let email: String
    let emailVerifiedAt: String?
    let createdAt: String
    let updatedAt: String
    
}

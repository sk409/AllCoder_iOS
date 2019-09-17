

class Material: Decodable {
    
    let id: Int
    let title: String
    let description: String
    let price: Int
    let thumbnailImagePath: String?
    let createdAt: String
    let updatedAt: String
    let lessons: [Lesson]
    let comments: [MaterialComment]
    
    
}

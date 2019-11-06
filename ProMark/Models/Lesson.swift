

class Lesson: Decodable {
    
    let id: Int
    let index: Int
    let title: String
    let description: String
    let book: String
    let createdAt: String
    let updatedAt: String
    let ratings: [Int]
    let rootFolder: Folder?
    let comments: [LessonComment]
    
}

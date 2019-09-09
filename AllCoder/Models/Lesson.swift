

struct Lesson: Decodable {
    
    let id: Int
    let title: String
    let description: String
    let createdAt: String
    let updatedAt: String
    let evaluations: [Int]
    let rootFolder: Folder?
    let comments: [LessonComment]
    
}

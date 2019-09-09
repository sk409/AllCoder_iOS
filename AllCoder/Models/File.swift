struct File: Decodable {
    
    let id: Int
    let name: String
    let text: String
    let createdAt: String
    let updatedAt: String
    let descriptions: [Description]
    
}

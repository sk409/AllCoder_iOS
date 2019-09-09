struct Description: Decodable {
    
    let id: Int
    let index: Int
    let text: String
    let createdAt: String
    let updatedAt: String
    let targets: [DescriptionTarget]
    let questions: [Question]
    
}

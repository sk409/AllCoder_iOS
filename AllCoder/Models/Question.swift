import UIKit

class Question: Decodable {
    
    let id: Int
    let startIndex: Int
    let endIndex: Int
    let createdAt: String
    let updatedAt: String
    let inputButtons: [InputButton]
    
}

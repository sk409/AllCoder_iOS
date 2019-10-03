import UIKit

class Question: Decodable {
    
    let id: Int
    let index: Int
    let createdAt: String
    let updatedAt: String
    let inputButtons: [InputButton]
    
}

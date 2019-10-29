import UIKit

class Question: Decodable {
    
    let id: Int
    let startIndex: Int
    let endIndex: Int
    let answer: String
    var input: String
    
}

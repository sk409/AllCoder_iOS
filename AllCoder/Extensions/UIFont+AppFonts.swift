import UIKit

extension UIFont {
    
    static let small = UIFont.systemFont(ofSize: UIScreen.main.bounds.width * 0.06)
    static let medium = UIFont.systemFont(ofSize: small.pointSize * 1.3)
    static let large = UIFont.systemFont(ofSize: medium.pointSize * 1.3)
    
    static let boldSmall = UIFont.boldSystemFont(ofSize: small.pointSize)
    static let boldMedium = UIFont.boldSystemFont(ofSize: medium.pointSize)
    static let boldLarge = UIFont.boldSystemFont(ofSize: large.pointSize)
    
}

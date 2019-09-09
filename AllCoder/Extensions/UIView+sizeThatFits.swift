import UIKit

extension UIView {
    
    var sizeThatFits: CGSize {
        return sizeThatFits(CGSize(width: CGFloat.infinity, height: .infinity))
    }
    
}

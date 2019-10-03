import UIKit

extension UIView {
    
    var fitSize: CGSize {
        return sizeThatFits(CGSize(width: CGFloat.infinity, height: .infinity))
    }
    
}

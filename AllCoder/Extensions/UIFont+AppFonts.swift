import UIKit

extension UIFont {
    
    static var tiny: UIFont {
        return UIFont.systemFont(ofSize: baseScreenSize * 0.046)
    }
    static var small: UIFont {
        return UIFont.systemFont(ofSize: tiny.pointSize * 1.3)
    }
    static var medium: UIFont {
        return UIFont.systemFont(ofSize: small.pointSize * 1.3)
    }
    static var large: UIFont {
        return UIFont.systemFont(ofSize: medium.pointSize * 1.3)
    }
    
    static var boldTiny: UIFont {
        return UIFont.boldSystemFont(ofSize: tiny.pointSize)
    }
    static var boldSmall: UIFont {
        return UIFont.boldSystemFont(ofSize: small.pointSize)
    }
    static var boldMedium: UIFont {
        return UIFont.boldSystemFont(ofSize: medium.pointSize)
    }
    static var boldLarge: UIFont {
        return UIFont.boldSystemFont(ofSize: large.pointSize)
    }
    
    private static var baseScreenSize: CGFloat {
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .landscapeLeft:
            fallthrough
        case .landscapeRight:
            return UIScreen.main.bounds.height
        default:
            return UIScreen.main.bounds.width
        }
    }
    
}

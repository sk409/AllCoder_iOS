import UIKit

extension UIView {
    
    private static let blackoutViewTag = Int.max
    
    func addBlackout(
        alpha: CGFloat = 0.7,
        duration: TimeInterval = UIView.Animation.Duration.normal,
        completion: (() -> Void)? = nil) -> UIView
    {
        let blackoutView = UIView()
        blackoutView.frame.origin = .zero
        blackoutView.frame.size = bounds.size
        blackoutView.backgroundColor = .black
        blackoutView.tag = UIView.blackoutViewTag
        blackoutView.alpha = 0
        addSubview(blackoutView)
        UIView.animate(withDuration: duration, animations: {
            blackoutView.alpha = alpha
        }) { _ in
            completion?()
        }
        return blackoutView
    }
    
    func removeBlackout(
        duration: TimeInterval = UIView.Animation.Duration.normal,
        completion: (() -> Void)? = nil
    ) {
        guard let blackoutView = viewWithTag(UIView.blackoutViewTag) else {
            return
        }
        UIView.animate(withDuration: duration, animations: {
            blackoutView.alpha = 0
        }) { _ in
            blackoutView.removeFromSuperview()
            completion?()
        }
    }
    
}

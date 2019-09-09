import UIKit

extension UIView {
    
    struct Animation {
        
        struct Duration {
            
            static let slow: TimeInterval = 1
            static let normal: TimeInterval = 0.5
            static let fast: TimeInterval = 0.25
            
        }
        
        static func slow(delay: TimeInterval, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.slow, delay: delay, options: options, animations: animations, completion: completion)
        }
        
        static func slow(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.slow, animations: animations, completion: completion)
        }
        
        static func slow(animations: @escaping () -> Void) {
            UIView.animate(withDuration: Duration.slow, animations: animations)
        }
        
        static func slow(delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.slow, delay: delay, options: options, animations: animations, completion: completion)
        }
        
        static func normal(delay: TimeInterval, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.normal, delay: delay, options: options, animations: animations, completion: completion)
        }
        
        static func normal(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.normal, animations: animations, completion: completion)
        }
        
        static func normal(animations: @escaping () -> Void) {
            UIView.animate(withDuration: Duration.normal, animations: animations)
        }
        
        static func normal(delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.normal, delay: delay, options: options, animations: animations, completion: completion)
        }
        
        static func fast(delay: TimeInterval, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.fast, delay: delay, options: options, animations: animations, completion: completion)
        }
        
        static func fast(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.fast, animations: animations, completion: completion)
        }
        
        static func fast(animations: @escaping () -> Void) {
            UIView.animate(withDuration: Duration.fast, animations: animations)
        }
        
        static func fast(delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: Duration.fast, delay: delay, options: options, animations: animations, completion: completion)
        }
        
    }
    
}

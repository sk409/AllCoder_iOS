import UIKit

class CurtainView: UIView {
    
    var hiddenView: UIView? {
        didSet {
            removeFromSuperview()
            guard let hiddenView = hiddenView else {
                return
            }
            hiddenView.addSubview(self)
            translatesAutoresizingMaskIntoConstraints = false
            leadingConstraint = leadingAnchor.constraint(equalTo: hiddenView.trailingAnchor)
            NSLayoutConstraint.activate([
                leadingConstraint!,
                topAnchor.constraint(equalTo: hiddenView.topAnchor),
                widthAnchor.constraint(equalTo: hiddenView.widthAnchor),
                heightAnchor.constraint(equalTo: hiddenView.heightAnchor),
                ])
        }
    }
    let panGestureRecognizer = UIPanGestureRecognizer()
    
    var contentView: UIView? {
        willSet {
            contentView?.removeFromSuperview()
        }
        didSet {
            guard let contentView = contentView else {
                return
            }
            addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                ])
        }
    }
    
    private var leadingConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestureRecognizers()
    }
    
    func slideIn(
        withDuration animationDuration: TimeInterval = UIView.Animation.Duration.fast,
        completion: ((Bool) -> Void)? = nil
    ) {
//        guard let hiddenView = hiddenView else {
//            completion?(false)
//            return
//        }
        leadingConstraint?.constant = -bounds.width
        UIView.animate(withDuration: animationDuration, animations: {
            self.superview?.layoutIfNeeded()
        }) { finished in
            completion?(finished)
        }
    }
    
    func slideOut(
        withDuration animationDuration: TimeInterval = UIView.Animation.Duration.fast,
        completion: ((Bool) -> Void)? = nil
    ) {
        leadingConstraint?.constant = 0
        UIView.animate(withDuration: animationDuration, animations: {
            self.superview?.layoutIfNeeded()
        }) { finished in
            completion?(finished)
        }
    }
    
    private func setupGestureRecognizers() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc
    private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let hiddenView = hiddenView else {
            return
        }
        if sender.state == .changed {
            let velocity = sender.velocity(in: self)
            if 3000 <= velocity.x {
                slideOut()
            } else {
                if let leadingConstraint = leadingConstraint {
                    leadingConstraint.constant += velocity.x * 0.015
                    leadingConstraint.constant = min(0, max(-hiddenView.bounds.width, leadingConstraint.constant))
                }
            }
        } else if sender.state == .ended {
            if (hiddenView.bounds.width * 0.5) < frame.origin.x {
                slideOut()
            } else {
               slideIn()
            }
        }
    }
    
}

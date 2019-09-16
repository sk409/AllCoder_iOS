import UIKit

class CurtainView: UIView {
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        setupGestureRecognizers()
    }
    
    func slideIn(
        withDuration animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.frame.origin.x = 0
        }) { finished in
            completion?(finished)
        }
    }
    
    func slideOut(
        withDuration animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.frame.origin.x = UIScreen.main.bounds.width
        }) { finished in
            completion?(finished)
        }
    }
    
    private func setupViews() {
        frame.origin.x = UIScreen.main.bounds.width
        frame.origin.y = 0
        frame.size.width = UIScreen.main.bounds.width
        frame.size.height = UIScreen.main.bounds.height
    }
    
    private func setupGestureRecognizers() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc
    private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .changed {
            let velocity = sender.velocity(in: self)
            if 3000 <= velocity.x {
                slideOut()
            } else {
                frame.origin.x += velocity.x * 0.015
                frame.origin.x = min(UIScreen.main.bounds.width, max(0, frame.origin.x))
            }
        } else if sender.state == .ended {
            if (UIScreen.main.bounds.width * 0.5) < frame.origin.x {
                slideOut()
            } else {
               slideIn()
            }
        }
    }
    
}

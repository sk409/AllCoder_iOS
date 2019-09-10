import UIKit

class FormViewController: UIViewController {
    
    var formViewFrame: CGRect {
        return formView.frame
    }
    
    private var maxY: CGFloat = 0
    private var contentOffsetYBeforeScrollToFormControlView: CGFloat = 0
    
    private let scrollView = UIScrollView()
    private let formView = FormView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addGestureRecognizers()
        addObservers()
    }
    
    func append(view: UIView, frame: CGRect) {
        scrollView.addSubview(view)
        view.frame = frame
        maxY = max(maxY, frame.maxY)
        scrollView.contentSize.height = max(scrollView.contentSize.height, maxY)
    }
    
    func appendFormControlView(labelText: String) -> FormControlView {
        let formControlHeight = view.bounds.width * 0.3
        let formControlSpacing = view.bounds.width * 0.05
        let formControlView = formView.appendFormControlView(labelText: labelText)
        formControlView.textField.addTarget(self, action: #selector(onBeganEditingTextField(_:)), for: .editingDidBegin)
        formView.frame.size.height += (formControlHeight + formControlSpacing)
        return formControlView
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(formView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        formView.frame.size.width = view.bounds.width * 0.8
        formView.frame.origin = CGPoint(
            x: (view.bounds.width * 0.5) - (formView.frame.width * 0.5),
            y: view.bounds.height * 0.05
        )
        formView.controlsStackView.spacing = view.bounds.height * 0.05
    }
    
    private func addGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapView(_:))))
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(observeKeyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(observeKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func observeKeyboardWillShowNotification(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        let contentHeight = max(
            contentOffsetYBeforeScrollToFormControlView + view.safeAreaLayoutGuide.layoutFrame.height,
            maxY + keyboardFrame.height
        )
        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentOffset.y = self.contentOffsetYBeforeScrollToFormControlView
            self.scrollView.contentSize.height = contentHeight
        }
    }
    
    @objc
    private func observeKeyboardWillHideNotification(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentSize.height -= keyboardFrame.height
        }
    }
    
    @objc
    private func onTapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc
    private func onBeganEditingTextField(_: UITextField) {
        guard let activeFormControlView = formView.controlsStackView.arrangedSubviews.first(where: { arrangedSubview in
            guard let formControlView = arrangedSubview as? FormControlView else {
                return false
            }
            return formControlView.isActive
        }) else {
            return
        }
        contentOffsetYBeforeScrollToFormControlView = self.formView.frame.origin.y + activeFormControlView.frame.origin.y
        UIView.Animation.normal {
            self.scrollView.contentOffset.y = self.contentOffsetYBeforeScrollToFormControlView
            self.scrollView.contentSize.height = max(self.scrollView.contentSize.height, self.contentOffsetYBeforeScrollToFormControlView + self.view.safeAreaLayoutGuide.layoutFrame.height)
        }
    }
    
}

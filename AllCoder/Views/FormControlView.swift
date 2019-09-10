import UIKit

class FormControlView: UIView {
    
    enum FeedbackType {
        case success
        case error
    }
    
    var normalColor = UIColor(white: 0.5, alpha: 1)
    var activeColor = UIColor.systemBlue
    
    let label = UILabel()
    let textField = UITextField()
    
    private(set) var isActive = false
    
    private var feedbackLabelHeightConstraint: NSLayoutConstraint?
    private let feedbackLabel = UILabel()
    private let borderView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func showFeedback(text: String, type: FeedbackType) {
        feedbackLabel.text = text
        switch type {
        case .success:
            feedbackLabel.textColor = .signalGreen
        case .error:
            feedbackLabel.textColor = .signalRed
        }
        feedbackLabelHeightConstraint?.constant = max(safeAreaLayoutGuide.layoutFrame.height * 0.1, feedbackLabel.sizeThatFits.height)
        UIView.Animation.normal {
            self.layoutIfNeeded()
        }
    }
    
    func hideFeedback() {
        feedbackLabelHeightConstraint?.constant = 0
        UIView.Animation.normal {
            self.layoutIfNeeded()
        }
    }
    
    private func setupViews() {
        addSubview(label)
        addSubview(feedbackLabel)
        addSubview(textField)
        addSubview(borderView)
        backgroundColor = UIColor(white: 0.8, alpha: 1)
        label.font = .small
        label.textColor = normalColor
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            label.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
            ])
        feedbackLabel.font = .tiny
        feedbackLabelHeightConstraint = feedbackLabel.heightAnchor.constraint(equalToConstant: 0)
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedbackLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            feedbackLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            feedbackLabel.topAnchor.constraint(equalTo: label.bottomAnchor),
            feedbackLabelHeightConstraint!,
            ])
        textField.font = .small
        textField.addTarget(self, action: #selector(onBeganEditingTextField(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(onEndEditingTextField(_:)), for: .editingDidEnd)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            textField.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor),
            textField.bottomAnchor.constraint(equalTo: borderView.topAnchor)
            ])
        borderView.backgroundColor = normalColor
        borderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            borderView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.025),
            ])
    }
    
    @objc
    private func onBeganEditingTextField(_ sender: UITextField) {
        isActive = true
        label.textColor = activeColor
        borderView.backgroundColor = activeColor
    }
    
    @objc
    private func onEndEditingTextField(_ sender: UITextField) {
        isActive = false
        label.textColor = normalColor
        borderView.backgroundColor = normalColor
    }
    
}


import UIKit

class FormView: UIView {
    
    let controlsStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func appendFormControlView(labelText: String) -> FormControlView {
        let formControlView = FormControlView()
        controlsStackView.addArrangedSubview(formControlView)
        formControlView.label.text = labelText
        return formControlView
    }
    
    private func setupViews() {
        addSubview(controlsStackView)
        controlsStackView.frame.size = UIScreen.main.bounds.size
        //controlsStackView.frame.size = CGSize(width: bounds.width, height: view.bounds.height)
        controlsStackView.distribution = .fillEqually
        controlsStackView.axis = .vertical
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            controlsStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            controlsStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            controlsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            ])
    }
    
    
    
}

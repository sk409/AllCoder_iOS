import UIKit

class FileTreeItemView: UIView {
    
    let nameLabel = UILabel()
    
    var treeSize: CGSize {
        return nameLabel.sizeThatFits
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func set(name: String) {
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.frame.size = nameLabel.sizeThatFits
    }
    
    private func setupViews() {
        addSubview(nameLabel)
        nameLabel.font = .small
        nameLabel.isUserInteractionEnabled = true
    }
    
}

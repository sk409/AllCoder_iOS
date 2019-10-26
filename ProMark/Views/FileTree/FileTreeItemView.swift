import UIKit

class FileTreeItemView: UIView {
    
    let nameLabel = UILabel()
    
    var treeSize: CGSize {
        return nameLabel.fitSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func set(path: String) {
        nameLabel.text = String(path.split(separator: "/").last ?? "")
        nameLabel.textColor = .white
        nameLabel.frame.size = nameLabel.fitSize
    }
    
    private func setupViews() {
        addSubview(nameLabel)
        nameLabel.font = .small
        nameLabel.isUserInteractionEnabled = true
    }
    
}

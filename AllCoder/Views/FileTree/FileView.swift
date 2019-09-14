import UIKit

class FileView: FileTreeItemView {
    
    static let userInfoKey = "FileView"
    
    private(set) var file: File?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGestureRecognizers()
    }
    
    func set(file: File) -> CGSize {
        self.file = file
        set(name: file.name)
        return nameLabel.fitSize
    }
    
    private func addGestureRecognizers() {
        nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
    }
    
    @objc
    private func onTap(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: .fileViewTapped, object: nil, userInfo: [FileView.userInfoKey: self])
    }
    
}

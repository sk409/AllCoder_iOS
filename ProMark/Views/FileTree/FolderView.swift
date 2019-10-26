import UIKit

class FolderView: FileTreeItemView, FileTreeItemHolder {
    
    override var treeSize: CGSize {
        if !isExpanded || children.isEmpty {
            return nameLabel.fitSize
        }
        var width: CGFloat = 0
        var height: CGFloat = nameLabel.fitSize.height
        for child in children {
            let childTreeSize = child.treeSize
            width = max(width, childTreeSize.width)
            height += childTreeSize.height
        }
        return CGSize(width: indent + width, height: height)
    }
    
    var indent = UIScreen.main.bounds.width * 0.05
    
    var parent: FileTreeItemHolder?
    
    private var isExpanded = true
    private var folder: Folder?
    private var children = [FileTreeItemView]()
    private var heightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGestureRecognizers()
    }
    
    func stretch(constant: CGFloat) {
        heightConstraint?.constant += constant
        parent?.stretch(constant: constant)
    }
    
    func set(folder: Folder) -> CGSize {
        self.folder = folder
        set(path: folder.path)
        var size = nameLabel.fitSize
        for child in folder.childFolders {
            let childSize = append(child: child)
            size.width = max(size.width, childSize.width + indent)
            size.height += childSize.height
        }
        for child in folder.childFiles {
            let childSize = append(child: child)
            size.width = max(size.width, childSize.width + indent)
            size.height += childSize.height
        }
        return size
    }
    
    func append(child: Folder) -> CGSize {
        let folderView = FolderView()
        folderView.translatesAutoresizingMaskIntoConstraints = false
        folderView.parent = self
        let size = folderView.set(folder: child)
        folderView.heightConstraint = folderView.heightAnchor.constraint(equalToConstant: size.height)
        NSLayoutConstraint.activate([
            folderView.widthAnchor.constraint(equalToConstant: size.width),
            folderView.heightConstraint!,
            ])
        append(child: folderView)
        return size
    }
    
    func append(child: File) -> CGSize {
        let fileView = FileView()
        fileView.translatesAutoresizingMaskIntoConstraints = false
        let size = fileView.set(file: child)
        NSLayoutConstraint.activate([
            fileView.widthAnchor.constraint(equalToConstant: size.width),
            fileView.heightAnchor.constraint(equalToConstant: size.height),
            ])
        append(child: fileView)
        return size
    }
    
    private func addGestureRecognizers() {
        nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
    }
    
    private func append(child: FileTreeItemView) {
        addSubview(child)
        let parent = children.last ?? nameLabel
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: indent),
            child.topAnchor.constraint(equalTo: parent.bottomAnchor),
            ])
        children.append(child)
    }
    
    @objc
    private func onTap(_ sender: UITapGestureRecognizer) {
        isExpanded = !isExpanded
        var constant: CGFloat = 0
        for child in children {
            child.isHidden = !child.isHidden
            constant += (child.isHidden ? -child.bounds.height : child.bounds.height)
        }
        stretch(constant: constant)
    }
    
}

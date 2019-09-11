import UIKit

class FileTreeView: UIScrollView, FileTreeItemHolder {
    
    var rootFolder: Folder? {
        didSet {
            guard let rootFolder = rootFolder else {
                return
            }
            let size = rootFolderView.set(folder: rootFolder)
            rootFolderView.frame.size = size
            contentSize = rootFolderView.bounds.size
        }
    }
    
    private let rootFolderView = FolderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func stretch(constant: CGFloat) {
        contentSize = rootFolderView.treeSize
    }
    
    private func setupViews() {
        addSubview(rootFolderView)
        rootFolderView.indent = 0
        rootFolderView.parent = self
    }
    
}

import UIKit

class LessonViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    
    var lesson: Lesson? {
        didSet {
            fileTreeView.rootFolder = lesson?.rootFolder
            codeEditorView.file = lesson?.rootFolder?.childFiles.first
        }
    }
    
    private let fileTreeView = FileTreeView()
    private let codeEditorView = CodeEditorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addObservers()
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        view.addSubview(fileTreeView)
        view.addSubview(codeEditorView)
        fileTreeView.backgroundColor = UIColor(red: 48/255, green: 50/255, blue: 61/255, alpha: 1)
        fileTreeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fileTreeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            fileTreeView.topAnchor.constraint(equalTo: view.topAnchor),
            fileTreeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fileTreeView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3)
            ])
        codeEditorView.backgroundColor = .black
        codeEditorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            codeEditorView.leadingAnchor.constraint(equalTo: fileTreeView.trailingAnchor),
            codeEditorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            codeEditorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            codeEditorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(observeFileViewTapNotification(_:)), name: .fileViewTapped, object: nil)
    }
    
    @objc
    private func observeFileViewTapNotification(_ sender: Notification) {
        guard let fileView = sender.userInfo?[FileView.userInfoKey] as? FileView else {
            return
        }
        codeEditorView.file = fileView.file
    }
    
}

fileprivate struct Frame {
    
    private let borderViews: [UIView]
    
    init(_ borderViews: [UIView]) {
        self.borderViews = borderViews
    }
    
    func remove() {
        borderViews.forEach { $0.removeFromSuperview() }
    }
    
}


fileprivate class CodeEditorView: UIScrollView {
    
    var font = UIFont.boldSmall
    var insets = UIEdgeInsets(
        top: UIFont.tiny.pointSize * 0.3,
        left: UIFont.tiny.pointSize * 0.5,
        bottom: UIFont.tiny.pointSize * 0.3,
        right: UIFont.tiny.pointSize * 0.5
    )
    
    var lineSpacing: CGFloat = UIFont.tiny.pointSize {
        didSet {
            fatalError("未対応")
//            guard let codeLabelAttributedText = codeLabel.attributedText else {
//                return
//            }
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.lineSpacing = lighHeight
//            let attributedText = NSMutableAttributedString(attributedString:  codeLabelAttributedText)
//            attributedText.setAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: NSString(string: codeLabelAttributedText.string).length))
//            codeLabel.attributedText = attributedText
        }
    }
    var file: File? {
        didSet {
            setCode()
        }
    }
    
    private var questionFrames = [Frame]()
    private let codeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(codeLabel)
        codeLabel.numberOfLines = 0
        codeLabel.font = font
    }
    
    private func setCode() {
        guard let file = file else {
            return
        }
        questionFrames.forEach { $0.remove() }
        questionFrames.removeAll(keepingCapacity: true)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        var attributes = [NSAttributedString.Key.font: font, .paragraphStyle: paragraphStyle]
        let attributedCodeLabelText = NSMutableAttributedString()
        let questions = file.descriptions.map { $0.questions }.flatMap { $0 }
        var startIndex = 0
        for question in questions {
            attributes.updateValue(Appearance.CodeEditor.textColor, forKey: .foregroundColor)
            attributedCodeLabelText.append(NSAttributedString(
                string: file.text[startIndex..<question.startIndex],
                attributes: attributes
            ))
            //attributes.updateValue(UIColor.clear, forKey: .foregroundColor)
            attributedCodeLabelText.append(NSAttributedString(
                string: file.text[question.startIndex..<question.endIndex],
                attributes: attributes
            ))
            startIndex = question.endIndex
            if let frame = drawFrame(startIndex: question.startIndex, endIndex: question.endIndex) {
                questionFrames.append(frame)
            }
        }
        if startIndex < file.text.count {
            attributes.updateValue(Appearance.CodeEditor.textColor, forKey: .foregroundColor)
            attributedCodeLabelText.append(NSAttributedString(
                string: file.text[startIndex...],
                attributes: attributes
            ))
        }
        codeLabel.attributedText = attributedCodeLabelText
        let codeLabelSize = codeLabel.sizeThatFits
        codeLabel.frame = CGRect(
            x: insets.left,
            y: insets.top,
            width: codeLabelSize.width,
            height: codeLabelSize.height
        )
        contentSize = CGSize(
            width: codeLabelSize.width + insets.right,
            height: codeLabelSize.height + insets.bottom
        )
    }
    
    private func drawFrame(startIndex: Int, endIndex: Int) -> Frame? {
        guard let file = file else {
            return nil
        }
        guard let lastLine = file.text[..<startIndex]
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map({String($0)})
            .last
            else {
            return nil
        }
        let size: (String?) -> CGSize = { string in
            guard let string = string else {
                return .zero
            }
            let attributes = [NSAttributedString.Key.font: self.font]
            var size = string.size(withAttributes: attributes)
            let lines = string.split(separator: "\n", omittingEmptySubsequences: false)
            size.height += self.lineSpacing * CGFloat(lines.count - 1)
            return size
        }
        let lastLineSize = size(lastLine)
        let targetLines = file.text[startIndex..<endIndex].split(separator: "\n").map{ String($0) }
//        guard let firstLine = targetLines.first else {
//            return nil
//        }
        let borderSize = font.pointSize * 0.1
        let prefixLinesHeight = size(file.text[..<startIndex]).height
        var borderViews = [UIView]()
//        //TODO: origin.x -> center.x
//        var leftX: CGFloat = 0
//        var rightX: CGFloat = 0
        let horizontalBuffer = insets.left / 2
        let verticalBuffer = lineSpacing / 2
        var y = prefixLinesHeight - lastLineSize.height - (verticalBuffer / 2)
        for (index, line) in targetLines.enumerated() {
            let makeBorderView = { () -> UIView in
                let borderView = UIView()
                self.addSubview(borderView)
                borderViews.append(borderView)
                borderView.backgroundColor = Appearance.CodeEditor.textColor
                return borderView
            }
            let headSpaceRegex = try! NSRegularExpression(pattern: "^ +", options: .anchorsMatchLines)
            var headSpaceWidth: CGFloat = 0
            if let headSpace = headSpaceRegex.matches(in: line, range: NSRange(location: 0, length: NSString(string: line).length)).first {
                let headSpaces = String(NSString(string: line).substring(with: headSpace.range))
                headSpaceWidth = size(headSpaces).width
            }
            let lineSize = size(line)
            let leftBorderView = makeBorderView()
            leftBorderView.frame.origin.y = y
            leftBorderView.frame.size.width = borderSize
            leftBorderView.frame.size.height = lineSize.height + verticalBuffer
            leftBorderView.center.x = headSpaceWidth - horizontalBuffer
            if index == 0 {
                leftBorderView.center.x += lastLineSize.width
            }
            let topBorderView = makeBorderView()
            topBorderView.frame.origin.x = leftBorderView.frame.origin.x
            topBorderView.frame.origin.y = y
            topBorderView.frame.size.width = lineSize.width - headSpaceWidth + (horizontalBuffer * 2)
            topBorderView.frame.size.height = borderSize
            let rightBorderView = makeBorderView()
            rightBorderView.frame.origin.x = topBorderView.frame.maxX - borderSize
            rightBorderView.frame.origin.y = y
            rightBorderView.frame.size = leftBorderView.bounds.size
            let bottomBorderView = makeBorderView()
            bottomBorderView.frame.origin.x = topBorderView.frame.origin.x
            bottomBorderView.frame.origin.y = y + leftBorderView.frame.size.height
            bottomBorderView.frame.size = topBorderView.bounds.size
//            let makeHorizontalBorderView: (CGFloat, CGFloat) -> Void = { centerX, width in
//                let horizontalBorderView = makeBorderView()
//                horizontalBorderView.center.x = centerX
//                horizontalBorderView.frame.origin.y = y
//                horizontalBorderView.frame.size.width = width
//                horizontalBorderView.frame.size.height = borderSize
//            }
//            let makeVerticalBorderView: (CGFloat) -> Void = { centerX in
//                let boderView = makeBorderView()
//                boderView.center.x = centerX
//                boderView.frame.origin.y = y
//                boderView.frame.size.width = borderSize
//                boderView.frame.size.height = lineSize.height + borderSize
//            }
//            let makeLeftVerticalBorderView: (CGFloat) -> Void = { centerX in
//                makeVerticalBorderView(centerX)
//                leftX = centerX
//            }
//            let makeRightVerticalBorderView: (CGFloat) -> Void = { centerX in
//                makeVerticalBorderView(centerX)
//                rightX = centerX
//            }
//            if index == 0 {
//                makeHorizontalBorderView(lastLineSize.width + headSpaceWidth, lineSize.width - headSpaceWidth)
//                makeLeftVerticalBorderView(lastLineSize.width + headSpaceWidth)
//                makeRightVerticalBorderView(lastLineSize.width + lineSize.width)
//            } else {
//                makeHorizontalBorderView(min(leftX, headSpaceWidth), abs(leftX - headSpaceWidth))
//                makeHorizontalBorderView(min(rightX, lineSize.width), abs(rightX - lineSize.width))
//                makeLeftVerticalBorderView(headSpaceWidth)
//                makeRightVerticalBorderView(lineSize.width)
//            }
            y += lineSize.height + lineSpacing
        }
//        let bottomBorderView = makeBorderView()
//        bottomBorderView.center.x = leftX
//        bottomBorderView.frame.origin.y = y
//        bottomBorderView.frame.size.width = rightX - leftX
//        bottomBorderView.frame.size.height = borderSize
//        let borderView1 = makeBorderView()
//        borderView1.frame.origin = CGPoint(x: insets.left, y: y)
//        borderView1.frame.size = CGSize(width: x, height: borderSize)
//        let borderView2 = makeBorderView()
//        borderView2.frame.origin = CGPoint(x: insets.left, y: prefixLinesHeight + lastLineSize.height)
//        borderView2.frame.size = CGSize(width: borderSize, height: y - borderView2.frame.origin.y)
//        let borderView3 = makeBorderView()
//        borderView3.frame.origin = CGPoint(x: insets.left, y: prefixLinesHeight + lastLineSize.height)
//        borderView3.frame.size = CGSize(width: lastLineSize.width, height: borderSize)
//        let borderView4 = makeBorderView()
//        borderView4.frame.origin = CGPoint(x: insets.left + lastLineSize.width, y: prefixLinesHeight)
//        borderView4.frame.size = CGSize(width: borderSize, height: lastLineSize.height + borderSize)
//        let borderView5 = makeBorderView()
//        borderView5.frame.origin = CGPoint(x: insets.left + lastLineSize.width, y: prefixLinesHeight)
//        borderView5.frame.size = CGSize(width: size(firstLine).width, height: borderSize)
        for borderView in borderViews {
            borderView.frame.origin.x += insets.left
            borderView.frame.origin.y += insets.top
        }
        return Frame(borderViews)
    }
    
}


fileprivate class DescriptionCollectionViewCell: UICollectionViewCell {
    
    static let className = "DescriptionCollectionViewCell"
    
    var data: Description? {
        didSet {
            textLabel.text = data?.text
        }
    }
    
    private let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(textLabel)
        textLabel.numberOfLines = 0
        
    }
    
}


fileprivate class DescriptionView: UIView {
    
    var descriptions = [Description]()
    
    private let collectionView = UICollectionView()
    
}

//extension DescriptionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return descriptions.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DescriptionCollectionViewCell.className, for: indexPath)
//        
//    }
//    
//}

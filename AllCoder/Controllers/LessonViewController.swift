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
            files.removeAll(keepingCapacity: true)
            if let rootFolder = lesson?.rootFolder {
                var folders = [rootFolder]
                while !folders.isEmpty {
                    let folder = folders.popLast()!
                    files.append(contentsOf: folder.childFiles)
                    folders.append(contentsOf: folder.childFolders)
                }
            }
            releaseDescriptions()
        }
    }
    
    private var descriptionCollectionViewTopConstraint: NSLayoutConstraint?
    private var releasedDescriptions = [Description]()
    private var files = [File]()
    private let fileTreeView = FileTreeView()
    private let codeEditorView = CodeEditorView()
    private let descriptionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }())
    
    private var descriptionIndex: Int? {
        let descriptionIndex = Int((descriptionCollectionView.contentOffset.x + (descriptionCollectionView.bounds.width / 2)) / descriptionCollectionView.bounds.width)
        return (descriptionIndex < releasedDescriptions.count) ? descriptionIndex : nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showDescriptionCollectionView()
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        view.addSubview(fileTreeView)
        view.addSubview(codeEditorView)
        view.addSubview(descriptionCollectionView)
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
        descriptionCollectionView.dataSource = self
        descriptionCollectionView.delegate = self
        descriptionCollectionView.isPagingEnabled = true
        descriptionCollectionView.bounces = false
        descriptionCollectionView.register(DescriptionCollectionViewCell.self, forCellWithReuseIdentifier: DescriptionCollectionViewCell.className)
        descriptionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionCollectionViewTopConstraint = descriptionCollectionView.topAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            descriptionCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            descriptionCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            descriptionCollectionViewTopConstraint!,
            descriptionCollectionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.45),
            ])
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(observeFileViewTapNotification(_:)), name: .fileViewTapped, object: nil)
    }
    
    private func releaseDescriptions() {
        var fileIndex = releasedDescriptions.count
        while fileIndex < files.count {
            let file = files[fileIndex]
            for description in file.descriptions {
                releasedDescriptions.append(description)
                return
            }
            fileIndex += 1
        }
    }
    
    private func showDescriptionCollectionView(
        animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
        ) {
        descriptionCollectionViewTopConstraint?.constant =
            -view.safeAreaInsets.bottom - descriptionCollectionView.bounds.height
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
            self.codeEditorView.contentSize.height += self.descriptionCollectionView.bounds.height
        }) { _ in
            guard let descriptionIndex = self.descriptionIndex else {
                return
            }
            let indexPairs = self.releasedDescriptions[descriptionIndex].targets.map { IndexPair(start: $0.startIndex, end: $0.endIndex) }
            self.codeEditorView.applyFocus(indexPairs: indexPairs) { finished in
                completion?(finished)
            }
        }
    }
    
    private func hideDescriptionCollectionView(
        animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
        ) {
        codeEditorView.cancelFocus(animationDuration: animationDuration) { _ in
            self.descriptionCollectionViewTopConstraint?.constant = self.view.bounds.height
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            }) { finished in
                completion?(finished)
            }
        }
    }
    
    @objc
    private func observeFileViewTapNotification(_ sender: Notification) {
        guard let fileView = sender.userInfo?[FileView.userInfoKey] as? FileView else {
            return
        }
        codeEditorView.file = fileView.file
    }
    
    @objc
    private func onTouchUpInsideAnswerButton(_ sender: UIButton) {
        hideDescriptionCollectionView()
    }
    
}

extension LessonViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let descriptionIndex = descriptionIndex else {
            return
        }
        let indexPairs = releasedDescriptions[descriptionIndex].targets.map({ IndexPair(start: $0.startIndex, end: $0.endIndex) })
        descriptionCollectionView.isScrollEnabled = false
        codeEditorView.cancelFocus(animationDuration: UIView.Animation.Duration.fast) { _ in
            self.codeEditorView.applyFocus(indexPairs: indexPairs) { _ in
                self.descriptionCollectionView.isScrollEnabled = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return releasedDescriptions.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DescriptionCollectionViewCell.className, for: indexPath) as! DescriptionCollectionViewCell
        if indexPath.item == releasedDescriptions.count {
            cell.mode = .button
            cell.buttonTitle = "問題を解く"
            cell.button.addTarget(self, action: #selector(onTouchUpInsideAnswerButton(_:)), for: .touchUpInside)
        } else {
            cell.mode = .text
            cell.data = releasedDescriptions[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

fileprivate struct IndexPair {
    let start: Int
    let end: Int
    init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}


fileprivate class CodeEditorView: UIScrollView {
    
    private struct Frame {
        
        let borderViews: [UIView]
        
        init(_ borderViews: [UIView]) {
            self.borderViews = borderViews
        }
        
        func remove() {
            borderViews.forEach { $0.removeFromSuperview() }
        }
        
    }
    
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
    private var focusFrames = [Frame]()
    private let codeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func applyFocus(
        indexPairs: [IndexPair],
        animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
        ) {
        guard let top = indexPairs.sorted(by: { $0.start < $1.start }).first else {
            return
        }
        let size = textSize(upTo: top.start, omittingLastLine: true)
        UIView.animate(withDuration: animationDuration, animations: {
            self.contentOffset.y = size.height
        }) { finished in
            for indexPair in indexPairs {
                let frameAnimationCompletion: (Bool) -> Void = { _ in
                    completion?(finished)
                }
                guard let focusFrame =
                    self.drawFrame(
                        startIndex: indexPair.start,
                        endIndex: indexPair.end,
                        color: .signalRed,
                        animationDuration: UIView.Animation.Duration.normal,
                        animationCompletion: frameAnimationCompletion
                    )
                    else {
                        continue
                }
                self.focusFrames.append(focusFrame)
            }
        }
    }
    
    func cancelFocus(
        animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
        ) {
        UIView.animate(withDuration: animationDuration, animations: {
            self.focusFrames.forEach { $0.borderViews.forEach { $0.alpha = 0} }
        }) { finished in
            self.focusFrames.forEach { $0.remove() }
            self.focusFrames.removeAll(keepingCapacity: true)
            completion?(finished)
        }
    }
    
    private func setupViews() {
        addSubview(codeLabel)
        codeLabel.numberOfLines = 0
        codeLabel.font = font
    }
    
    private func textSize(upTo index: Int, omittingLastLine: Bool = false) -> CGSize {
        return textSize(startIndex: 0, endIndex: index, omittingLastLine: omittingLastLine)
    }
    
    private func textSize(startIndex: Int, endIndex: Int, omittingLastLine: Bool = false) -> CGSize {
        return textSize(file?.text[startIndex..<endIndex], omittingLastLine: omittingLastLine)
    }
    
    private func textSize(_ text: String?, omittingLastLine: Bool = false) -> CGSize {
        guard let text = text else {
            return .zero
        }
        let attributes = [NSAttributedString.Key.font: self.font]
        var size = text.size(withAttributes: attributes)
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        size.height += self.lineSpacing * CGFloat(lines.count - 1)
        if omittingLastLine {
            size.height -= textSize(lines.last).height
        }
        return size
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
    
    private func drawFrame(
        startIndex: Int,
        endIndex: Int,
        color: UIColor = Appearance.CodeEditor.textColor,
        animationDuration: TimeInterval? = nil,
        animationCompletion: ((Bool) -> Void)? = nil
        ) -> Frame? {
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
        let targetLines = file.text[startIndex..<endIndex].split(separator: "\n").map{ String($0) }
        let borderSize = font.pointSize * 0.1
        let horizontalBuffer = insets.left / 2
        let verticalBuffer = lineSpacing / 2
        var borderViews = [UIView]()
        var y = textSize(file.text[..<startIndex], omittingLastLine: true).height - (verticalBuffer / 2)
        for (index, line) in targetLines.enumerated() {
            let makeBorderView = { () -> UIView in
                let borderView = UIView()
                self.addSubview(borderView)
                borderViews.append(borderView)
                borderView.backgroundColor = color
                return borderView
            }
            let headSpaceRegex = try! NSRegularExpression(pattern: "^ +", options: .anchorsMatchLines)
            var headSpaceWidth: CGFloat = 0
            if let headSpace = headSpaceRegex.matches(in: line, range: NSRange(location: 0, length: NSString(string: line).length)).first {
                let headSpaces = String(NSString(string: line).substring(with: headSpace.range))
                headSpaceWidth = textSize(headSpaces).width
            }
            let lineSize = textSize(line)
            let leftBorderView = makeBorderView()
            leftBorderView.frame.origin.y = y
            leftBorderView.frame.size.width = borderSize
            leftBorderView.frame.size.height = lineSize.height + verticalBuffer
            leftBorderView.center.x = headSpaceWidth - horizontalBuffer
            if index == 0 {
                leftBorderView.center.x += textSize(lastLine).width
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
        if let animationDuration = animationDuration {
            borderViews.forEach { $0.alpha = 0 }
            UIView.animate(withDuration: animationDuration, animations: {
                borderViews.forEach { $0.alpha = 1}
            }) { finished in
                animationCompletion?(finished)
            }
        }
        return Frame(borderViews)
    }
    
}


fileprivate class DescriptionCollectionViewCell: UICollectionViewCell {
    
    enum Mode {
        case text
        case button
    }
    
    static let className = "DescriptionCollectionViewCell"
    
    let button = UIButton()
    
    var data: Description? {
        didSet {
            textLabel.text = data?.text
        }
    }
    var mode: Mode = .text {
        didSet {
            textLabel.isHidden = mode != .text
            button.isHidden = !textLabel.isHidden
        }
    }
    var buttonTitle: String? {
        didSet {
            guard let buttonTitle = buttonTitle else {
                return
            }
            button.setTitle(buttonTitle, for: .normal)
            let sizeThatFits = button.sizeThatFits
            button.frame.size.width = sizeThatFits.width * 1.5
            button.frame.size.height = sizeThatFits.height * 1.5
            button.frame.origin.x = (bounds.width / 2) - (button.bounds.width / 2)
            button.frame.origin.y = (bounds.height / 2) - (button.bounds.height / 2)
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
        addSubview(button)
        textLabel.numberOfLines = 0
        textLabel.font = .boldTiny
        textLabel.textColor = Appearance.CodeEditor.textColor
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            textLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            ])
        button.isHidden = true
        button.backgroundColor = .seaGreen
        button.titleLabel?.font = .boldMedium
        button.setTitleColor(.white, for: .normal)
    }
    
}

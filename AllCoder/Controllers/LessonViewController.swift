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
            codeEditorViews.removeAll(keepingCapacity: true)
            releasedDescriptions.removeAll(keepingCapacity: true)
            questions.removeAll(keepingCapacity: true)
            focusFrames.removeAll(keepingCapacity: true)
            fileTreeView.rootFolder = lesson?.rootFolder
            //codeEditorView.set(file: lesson?.rootFolder?.childFiles.first)
            if let rootFolder = lesson?.rootFolder {
                var folders = [rootFolder]
                while !folders.isEmpty {
                    let folder = folders.popLast()!
                    let describedFiles = folder.childFiles.filter { $0.index != nil }
                    codeEditorViews.append(contentsOf: describedFiles.map { describedFile in
                        let codeEditorView = CodeEditorView()
                        codeEditorView.set(file: describedFile)
                        return codeEditorView
                    })
                    folders.append(contentsOf: folder.childFolders)
                }
            }
            releaseDescriptions()
        }
    }
    
    private var keyboardViewTrailingConstraint: NSLayoutConstraint?
    private var descriptionCollectionViewTopConstraint: NSLayoutConstraint?
    //private var describedFiles = [File]()
    private var codeEditorViews = [CodeEditorView]()
    private var releasedDescriptions = [Description]()
    private var activeQuestion: Question?
    private var questions = [Question]()
    private var focusFrames = [Frame]()
    private let fileTreeView = FileTreeView()
    //private let codeEditorView = CodeEditorView()
    private let keyboardView = KeyboardView()
    private let descriptionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }())
    
    private var descriptionIndex: Int? {
        let descriptionIndex = Int((descriptionCollectionView.contentOffset.x + (descriptionCollectionView.bounds.width / 2)) / descriptionCollectionView.bounds.width)
        return (descriptionIndex < releasedDescriptions.count) ? descriptionIndex : nil
    }
    
    private var codeEditorView: CodeEditorView? {
        let descriptionIndex = self.descriptionIndex ?? (releasedDescriptions.count - 1)
        let description = releasedDescriptions[descriptionIndex]
        return codeEditorViews.first { codeEditorView in
            guard let file = codeEditorView.file else {
                return false
            }
            return file.id == description.fileId
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let button = UIButton()
//        var p = NSMutableParagraphStyle()
//        p.lineSpacing = 10
//        button.setAttributedTitle(NSAttributedString(string: ""), for: .normal)
//        button.titleLabel?.font = .boldSmall
//        print(button.fitSize)
        setupViews()
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showDescriptionCollectionView()
        codeEditorView?.alpha = 1
        codeEditorViews.forEach { $0.contentSize.height += descriptionCollectionView.bounds.height }
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        view.addSubview(fileTreeView)
        codeEditorViews.forEach { view.addSubview($0) }
        view.addSubview(keyboardView)
        view.addSubview(descriptionCollectionView)
        fileTreeView.backgroundColor = UIColor(red: 48/255, green: 50/255, blue: 61/255, alpha: 1)
        fileTreeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fileTreeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            fileTreeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            fileTreeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            fileTreeView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3)
            ])
        for codeEditorView in codeEditorViews {
            codeEditorView.alpha = 0
            codeEditorView.backgroundColor = .black
            codeEditorView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                codeEditorView.leadingAnchor.constraint(equalTo: fileTreeView.trailingAnchor),
                codeEditorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                codeEditorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                codeEditorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                ])
        }
        keyboardView.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        keyboardViewTrailingConstraint = keyboardView.trailingAnchor.constraint(equalTo: view.leadingAnchor)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardViewTrailingConstraint!,
            keyboardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            keyboardView.widthAnchor.constraint(equalTo: fileTreeView.widthAnchor),
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
        NotificationCenter.default.addObserver(self, selector: #selector(observeTapFileViewNotification(_:)), name: .fileViewTapped, object: nil)
    }
    
    private func releaseDescriptions() {
        var found = false
        var fileIndex = 0
        var descriptionCounter = 0
        let describedFiles = codeEditorViews.compactMap { $0.file }
        for (index, file) in describedFiles.enumerated() {
            fileIndex = index
            descriptionCounter += file.descriptions.count
            if releasedDescriptions.count < descriptionCounter {
                found = true
                break
            }
        }
        guard found else {
            return
        }
        while fileIndex < describedFiles.count {
            let file = describedFiles[fileIndex]
            for description in file.descriptions {
                guard !releasedDescriptions.contains(where: {$0 === description}) else {
                    continue
                }
                releasedDescriptions.append(description)
                guard description.questions.isEmpty else {
                    questions = description.questions
                    return
                }
            }
            fileIndex += 1
        }
    }
    
    private func changeCodeEditorView(fileId: Int? = nil) {
        let fileId = fileId ??
                     releasedDescriptions[
                        descriptionIndex ?? (releasedDescriptions.count - 1)
                        ].fileId
        codeEditorViews.forEach { $0.alpha = 0 }
        codeEditorViews.first { codeEditorView in
            guard let file = codeEditorView.file else {
                return false
            }
            return file.id == fileId
        }?.alpha = 1
    }
    
    private func focusDescriptionTargets(
        animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
        )
    {
        guard let descriptionIndex = self.descriptionIndex else {
            completion?(false)
            return
        }
        let focus = {
            for target in self.releasedDescriptions[descriptionIndex].targets {
                guard let frame = self.codeEditorView?.addFrame(
                    startIndex: target.startIndex,
                    endIndex: target.endIndex,
                    color: .signalRed)
                    else
                {
                        continue
                }
                self.focusFrames.append(frame)
            }
            self.focusFrames.forEach { $0.borderViews.forEach { $0.alpha = 0 } }
            if let topIndex = self.releasedDescriptions[descriptionIndex].targets.first?.startIndex
            {
                self.codeEditorView?.scroll(to: topIndex, animationDuration: animationDuration)
                { finished in
                    UIView.animate(withDuration: animationDuration, animations: {
                        self.focusFrames.forEach { $0.borderViews.forEach { $0.alpha = 1 }}
                    }) { finished in
                        completion?(finished)
                    }
                }
            } else {
                completion?(false)
            }
        }
        if focusFrames.isEmpty {
            focus()
        } else {
            UIView.animate(withDuration: animationDuration, animations: {
                self.focusFrames.forEach { $0.borderViews.forEach { $0.alpha = 0 }}
            }) { _ in
                self.focusFrames.forEach { $0.remove() }
                focus()
            }
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
        }) { _ in
            self.focusDescriptionTargets(
                animationDuration: animationDuration,
                completion: completion
            )
        }
    }
    
    private func hideDescriptionCollectionView(
        animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
        )
    {
        descriptionCollectionViewTopConstraint?.constant = self.view.bounds.height
        UIView.animate(withDuration: animationDuration, animations: {
            self.focusFrames.forEach { $0.borderViews.forEach { $0.alpha = 1}}
            self.view.layoutIfNeeded()
        }) { finished in
            self.focusFrames.forEach { $0.remove() }
            completion?(finished)
        }
    }
    
    private func nextPhase() {
        let deactivateActiveQuestion = {
            guard let activeQuestion = self.activeQuestion else {
                return
            }
            self.codeEditorView?.deactivateQuestion(id: activeQuestion.id)
            self.activeQuestion = nil
        }
        if questions.isEmpty {
            keyboardViewTrailingConstraint?.constant = 0
            UIView.Animation.fast(animations: {
                self.view.layoutIfNeeded()
                deactivateActiveQuestion()
            }) { _ in
                self.codeEditorView?.hideCaret()
                self.releaseDescriptions()
                self.changeCodeEditorView()
                self.descriptionCollectionView.reloadData()
                UIView.Animation.fast {
                    self.showDescriptionCollectionView()
                }
            }
        } else {
            let question = questions.removeFirst()
            guard let firstInputButton = question.inputButtons.first else {
                return
            }
            let activateNextQuestion = {
                self.codeEditorView?.scroll(
                    to: firstInputButton.startIndex,
                    animationDuration: UIView.Animation.Duration.fast
                ) { _ in
                    var counter = [NSAttributedString: Int]()
                    for inputButton in question.inputButtons {
                        guard let attributedSubtext = self.codeEditorView?.attributedSubtext(
                            from: NSRange(
                                location: inputButton.startIndex,
                                length: inputButton.endIndex - inputButton.startIndex
                            )
                        ) else {
                                return
                        }
                        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedSubtext)
                        mutableAttributedString.removeAttribute(.paragraphStyle, range: mutableAttributedString.string.fullRange)
                        counter[mutableAttributedString] = (counter[mutableAttributedString] ?? 0) + 1
                    }
                    self.keyboardView.counter = counter
                    self.keyboardView.buttons.forEach { $0.addTarget(self, action: #selector(self.onTouchUpInsideKeyboardButton(_:)), for: .touchUpInside) }
                    self.keyboardView.setNeedsDisplay()
                    self.keyboardViewTrailingConstraint?.constant = self.keyboardView.bounds.width + self.view.safeAreaInsets.left
                    UIView.Animation.fast {
                        self.view.layoutIfNeeded()
                        self.codeEditorView?.activateQuestion(id: question.id)
                    }
                }
            }
            if activeQuestion == nil {
                activateNextQuestion()
                codeEditorView?.showCaret()
            } else {
                UIView.Animation.fast(animations: {
                    deactivateActiveQuestion()
                }) { _ in
                    activateNextQuestion()
                }
            }
            activeQuestion = question
        }
    }
    
    @objc
    private func observeTapFileViewNotification(_ sender: Notification) {
        guard let file = (sender.userInfo?[FileView.userInfoKey] as? FileView)?.file else {
            return
        }
        changeCodeEditorView(fileId: file.id)
    }
    
    @objc
    private func onTouchUpInsideAnswerButton(_ sender: UIButton) {
        hideDescriptionCollectionView() { _ in
            self.nextPhase()
        }
    }
    
    @objc
    private func onTouchUpInsideKeyboardButton(_ sender: KeyboardButton) {
        guard let text = sender.text else {
            return
        }
        guard let activeQuestion = activeQuestion else {
            return
        }
        guard let codeEditorView = codeEditorView else {
            return
        }
        let notificationLabel = UILabel()
        view.addSubview(notificationLabel)
        notificationLabel.font = .boldLarge
        notificationLabel.textColor = Appearance.CodeEditor.textColor
        notificationLabel.textAlignment = .center
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            notificationLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            ])
        let animateNotificationLabel = {
            let magnification: CGFloat = 1.25
            let notificationLabelFitSize = notificationLabel.fitSize
            NSLayoutConstraint.activate([
                notificationLabel.widthAnchor.constraint(equalToConstant: notificationLabelFitSize.width * magnification),
                notificationLabel.heightAnchor.constraint(equalToConstant: notificationLabelFitSize.height * magnification),
                ])
            notificationLabel.alpha = 0
            UIView.Animation.normal(animations: {
                notificationLabel.alpha = 1
            }) { _ in
                UIView.Animation.normal(animations: {
                    notificationLabel.alpha = 0
                }) { _ in
                    notificationLabel.removeFromSuperview()
                }
            }
        }
        guard codeEditorView.isCorrect(text: text) else {
            notificationLabel.text = "✖︎"
            notificationLabel.backgroundColor = .signalRed
            animateNotificationLabel()
            return
        }
        notificationLabel.text = "◯"
        notificationLabel.backgroundColor = .seaGreen
        animateNotificationLabel()
        guard codeEditorView.solve(questionId: activeQuestion.id, text: text) else {
            return
        }
        nextPhase()
    }
    
}

extension LessonViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        changeCodeEditorView()
        descriptionCollectionView.isScrollEnabled = false
        focusDescriptionTargets(animationDuration: UIView.Animation.Duration.fast) { _ in
            self.descriptionCollectionView.isScrollEnabled = true
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

fileprivate class Frame {
    
    let borderViews: [UIView]
    
    init(_ borderViews: [UIView]) {
        self.borderViews = borderViews
    }
    
    func remove() {
        borderViews.forEach { $0.removeFromSuperview() }
    }
    
}

fileprivate class CodeEditorView: UIScrollView {
    
    struct QuestionAnswer {
        
        let questionId: Int
        let range: NSRange
        let answer: String
        var enteredText: String = ""
        
        init(range: NSRange, questionId: Int, answer: String) {
            self.range = range
            self.questionId = questionId
            self.answer = answer
        }
        
    }
    
    private class QuestionFrame: Frame {
        
        let questionId: Int
        
        var origin: CGPoint {
            let x = borderViews.reduce(CGFloat.infinity, { min($0, $1.frame.origin.x) })
            let y = borderViews.reduce(CGFloat.infinity, { min($0, $1.frame.origin.y) })
            return CGPoint(x: x, y: y)
        }
        var size: CGSize {
            let origin = self.origin
            let maxX = borderViews.reduce(0, { max($0, $1.frame.maxX) })
            let maxY = borderViews.reduce(0, { max($0, $1.frame.maxY) })
            return CGSize(width: maxX - origin.x, height: maxY - origin.y)
        }
        
        init(questionId: Int, borderViews: [UIView]) {
            self.questionId = questionId
            super.init(borderViews)
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
    var frameInsets: UIEdgeInsets {
        let horizontaInset = insets.left / 4
        let verticalInset = lineSpacing / 4
        return UIEdgeInsets(
            top: verticalInset,
            left: horizontaInset,
            bottom: verticalInset,
            right: horizontaInset
        )
    }
    var frameBorderSize: CGFloat {
        return font.pointSize * 0.1
    }
    
    private(set) var file: File?
    
    private var syntaxHighlightedText: NSAttributedString?
    private var questionFrames = [QuestionFrame]()
    private var questionAnswers = [QuestionAnswer]()
    private let codeLabel = UILabel()
    private let caretView = CaretView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func set(file: File?) {
        self.file = file
        guard let file = file else {
            return
        }
        guard let syntaxHighlightedText = SyntaxHighlighter.highlight(file: file) else {
            return
        }
        self.syntaxHighlightedText = NSAttributedString(attributedString: syntaxHighlightedText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        syntaxHighlightedText.addAttributes(
            [NSAttributedString.Key.font: font, .paragraphStyle: paragraphStyle],
            range: NSRange(location: 0, length: syntaxHighlightedText.string.count)
        )
        questionAnswers.removeAll(keepingCapacity: true)
        questionFrames.forEach { $0.remove() }
        questionFrames.removeAll(keepingCapacity: true)
        let questions = file.descriptions.flatMap { $0.questions }
        for question in questions {
            for inputButton in question.inputButtons {
                let range = NSRange(
                    location: inputButton.startIndex,
                    length: inputButton.endIndex - inputButton.startIndex
                )
                questionAnswers.append(
                    QuestionAnswer(
                        range: range,
                        questionId: question.id,
                        answer: file.text[inputButton.startIndex..<inputButton.endIndex]
                    )
                )
                syntaxHighlightedText.addAttributes(
                    [.foregroundColor: UIColor.clear],
                    range: range
                )
            }
            if let frame = addFrame(
                startIndex: question.inputButtons.reduce(Int.max, { min($0, $1.startIndex) }),
                endIndex: question.inputButtons.reduce(0, { max($0, $1.endIndex) })
            ) {
                questionFrames.append(QuestionFrame(questionId: question.id, borderViews: frame.borderViews))
            }
        }
        codeLabel.attributedText = syntaxHighlightedText
        let codeLabelSize = codeLabel.fitSize
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
    
    func scroll(
        to textIndex: Int,
        animationDuration: TimeInterval = UIView.Animation.Duration.normal,
        completion: ((Bool) -> Void)? = nil
        )
    {
        let size = textSize(upTo: textIndex, omittingLastLine: true)
        UIView.animate(withDuration: animationDuration, animations: {
            self.contentOffset.y = size.height
        }) { finished in
            completion?(finished)
        }
    }
    
    func addFrame(
        startIndex: Int,
        endIndex: Int,
        color: UIColor = Appearance.CodeEditor.textColor
        ) -> Frame?
    {
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
        let targetLines = file.text[startIndex..<endIndex].split(separator: "\n", omittingEmptySubsequences: false).map{ String($0) }
        let frameInsets = self.frameInsets
        let borderSize = frameBorderSize
        var borderViews = [UIView]()
        var y = textSize(file.text[..<startIndex], omittingLastLine: true).height - frameInsets.top - borderSize
        for (index, line) in targetLines.enumerated() {
            let makeBorderView = { () -> UIView in
                let borderView = UIView()
                self.addSubview(borderView)
                borderViews.append(borderView)
                borderView.backgroundColor = color
                return borderView
            }
//            let headSpaceRegex = try! NSRegularExpression(pattern: "^ +", options: .anchorsMatchLines)
            let headSpaceWidth: CGFloat = 0
//            if let headSpace = headSpaceRegex.matches(in: line, range: NSRange(location: 0, length: NSString(string: line).length)).first {
//                let headSpaces = String(NSString(string: line).substring(with: headSpace.range))
//                headSpaceWidth = textSize(headSpaces).width
//            }
            let lineSize = textSize(line)
            if !line.isEmpty {
                let leftBorderView = makeBorderView()
                leftBorderView.frame.origin.x = headSpaceWidth - frameInsets.left - borderSize
                leftBorderView.frame.origin.y = y
                leftBorderView.frame.size.width = borderSize
                leftBorderView.frame.size.height = lineSize.height + frameInsets.top + frameInsets.bottom + (borderSize * 2)
                if index == 0 {
                    leftBorderView.frame.origin.x += textSize(lastLine).width
                }
                let topBorderView = makeBorderView()
                topBorderView.frame.origin.x = leftBorderView.frame.origin.x
                topBorderView.frame.origin.y = y
                topBorderView.frame.size.width = lineSize.width /*- headSpaceWidth*/ + frameInsets.left + frameInsets.right + (borderSize * 2)
                topBorderView.frame.size.height = borderSize
                let rightBorderView = makeBorderView()
                rightBorderView.frame.origin.x = topBorderView.frame.maxX - borderSize
                rightBorderView.frame.origin.y = y
                rightBorderView.frame.size = leftBorderView.bounds.size
                let bottomBorderView = makeBorderView()
                bottomBorderView.frame.origin.x = topBorderView.frame.origin.x
                bottomBorderView.frame.origin.y = y + leftBorderView.frame.size.height - borderSize
                bottomBorderView.frame.size = topBorderView.bounds.size
            }
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
//        if let animationDuration = animationDuration {
//            borderViews.forEach { $0.alpha = 0 }
//            UIView.animate(withDuration: animationDuration, animations: {
//                borderViews.forEach { $0.alpha = 1}
//            }) { finished in
//                animationCompletion?(finished)
//            }
//        }
        return Frame(borderViews)
    }
    
    func textSize(upTo index: Int, omittingLastLine: Bool = false) -> CGSize {
        return textSize(startIndex: 0, endIndex: index, omittingLastLine: omittingLastLine)
    }
    
    func textSize(startIndex: Int, endIndex: Int, omittingLastLine: Bool = false) -> CGSize {
        return textSize(file?.text[startIndex..<endIndex], omittingLastLine: omittingLastLine)
    }
    
    func lineSize(characterIndex: Int) -> CGSize {
        guard let file = file else {
            return .zero
        }
        guard characterIndex < file.text.count else {
            return .zero
        }
        let line = String(file.text[...characterIndex].split(separator: "\n").last ?? "")
        return textSize(line)
    }
    
    func isCorrect(text: String) -> Bool {
        guard let questionAnswer = nextQuestionAnswer() else {
            return false
        }
        return questionAnswer.answer.hasPrefix(questionAnswer.enteredText + text)
    }
    
    func solve(questionId: Int, text: String) -> Bool {
        guard let attributedText = codeLabel.attributedText else {
            return false
        }
        guard isCorrect(text: text) else {
            return false
        }
        guard let questionAnswerIndex = nextQuestionAnswerIndex() else {
                return false
        }
        let questionAnswer = questionAnswers[questionAnswerIndex]
        guard let attributedAnswer = attributedSubtext(from: questionAnswer.range) else {
            return false
        }
        let mutableAttributedText = NSMutableAttributedString(
            attributedString: attributedText
        )
        attributedAnswer.enumerateAttribute(
            .foregroundColor,
            in: NSRange(
                location: questionAnswer.enteredText.count,
                length: text.count
            ))
        { foregroundColor, range, _ in
            guard let foregroundColor = foregroundColor else {
                return
            }
            mutableAttributedText.addAttribute(
                .foregroundColor,
                value: foregroundColor,
                range: NSRange(
                    location: questionAnswer.range.location + range.location,
                    length: range.length
                )
            )
        }
        codeLabel.attributedText = mutableAttributedText
        questionAnswers[questionAnswerIndex].enteredText += text
        moveCaret()
        if let nextQuestionAnswer = nextQuestionAnswer() {
            return nextQuestionAnswer.questionId != questionId
        }
        return true
    }
    
    func activateQuestion(id: Int) {
        questionFrames.first { $0.questionId == id }?.borderViews.forEach { $0.backgroundColor = Appearance.CodeEditor.activeColor }
    }
    
    func deactivateQuestion(id: Int) {
        questionFrames.first { $0.questionId == id }?.borderViews.forEach { $0.backgroundColor = Appearance.CodeEditor.inactiveColor }
    }
    
    func attributedSubtext(from range: NSRange) -> NSAttributedString? {
        return syntaxHighlightedText?.attributedSubstring(from: range)
    }
    
    func showCaret() {
        moveCaret()
        //resizeCaret()
        caretView.show()
    }
    
    func hideCaret() {
        caretView.hide()
    }
    
    func nextQuestionAnswerIndex() -> Int? {
        return questionAnswers.firstIndex(
            where: {
                ($0.answer.count != $0.enteredText.count)
            }
        )
    }
    
    func nextQuestionAnswer() -> QuestionAnswer? {
        guard let nextQuestionAnswerIndex = nextQuestionAnswerIndex() else {
            return nil
        }
        return questionAnswers[nextQuestionAnswerIndex]
    }
    
    private func setupViews() {
        addSubview(codeLabel)
        addSubview(caretView)
        codeLabel.numberOfLines = 0
        codeLabel.font = font
        caretView.hide()
        caretView.backgroundColor = Appearance.CodeEditor.textColor
        caretView.frame.size.width = UIFont.small.pointSize * 0.1
    }
    
    private func moveCaret() {
        guard let nextQuestionAnswer = nextQuestionAnswer() else {
            return
        }
        let textSize = self.textSize(upTo: nextQuestionAnswer.range.location, omittingLastLine: true)
        var lineSize = self.lineSize(characterIndex: nextQuestionAnswer.range.location + nextQuestionAnswer.enteredText.count - 1)
        if self.textSize(upTo: nextQuestionAnswer.range.location + nextQuestionAnswer.enteredText.count).height !=
           self.textSize(upTo: nextQuestionAnswer.range.location + nextQuestionAnswer.enteredText.count - 1).height
        {
            lineSize.width = 0
        }
        let originX = lineSize.width + insets.left
        let originY = textSize.height + frameBorderSize + frameInsets.top
        let height = lineSize.height
        caretView.frame.origin.x = originX
        caretView.frame.origin.y = originY
        caretView.frame.size.height = height
    }
    
//    private func resizeCaret() {
//        guard let nextQuestionAnswer = nextQuestionAnswer() else {
//            return
//        }
//        let height = lineSize(characterIndex: nextQuestionAnswer.range.location + nextQuestionAnswer.enteredText.count).height
//
//        caretView.frame.size.height = height
//    }
    
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
            let sizeThatFits = button.fitSize
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


fileprivate class KeyboardButton: UIButton {
    
    var count: Int?
    var text: String?
    
}

fileprivate class KeyboardView: UIScrollView {
    
    var counter: [NSAttributedString: Int]? {
        didSet {
            buttons.forEach { $0.removeFromSuperview() }
            buttons.removeAll(keepingCapacity: true)
            counter?.forEach { (attributedString, count) in
                var backgroundColorHue: CGFloat = 0
                var backgroundColorSaturation: CGFloat = 0
                var backgroundColorBrightness: CGFloat = 0
                var backgroundColorAlpha: CGFloat = 0
                guard backgroundColor?.getHue(
                    &backgroundColorHue,
                    saturation: &backgroundColorSaturation,
                    brightness: &backgroundColorBrightness,
                    alpha: &backgroundColorAlpha) ?? false
                    else {
                        return
                }
                let font = UIFont.boldSmall
                let button = KeyboardButton()
                addSubview(button)
                buttons.append(button)
                button.backgroundColor = UIColor(
                    hue: backgroundColorHue,
                    saturation: backgroundColorSaturation,
                    brightness: backgroundColorBrightness / 2,
                    alpha: backgroundColorAlpha
                )
                button.titleLabel?.font = font
                button.titleLabel?.textAlignment = .center
                if attributedString.string == "\n" {
                    button.setTitle(" ", for: .normal)
                } else {
                    button.setAttributedTitle(attributedString, for: .normal)
                }
                button.count = count
                button.text = attributedString.string
                let buttonFitSize = button.fitSize
                let buttonSize: CGSize
                let ratio: CGFloat = 1.2
                if attributedString.string == " " || attributedString.string == "\n" {
                    buttonSize = CGSize(
                        width: buttonFitSize.height * ratio,
                        height: buttonFitSize.height * ratio
                    )
                } else {
                    buttonSize = CGSize(
                        width: buttonFitSize.width * ratio,
                        height: buttonFitSize.height * ratio
                    )
                }
                button.frame.size = buttonSize
                let setButtonImage: (UIImage?, CGSize) -> Void = { image, imageSize in
                    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
                    image?.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    button.setImage(resizedImage, for: .normal)
                    button.contentEdgeInsets = UIEdgeInsets(
                        top: (buttonSize.height - imageSize.height) / 2,
                        left: (buttonSize.width - imageSize.width) / 2,
                        bottom: (buttonSize.height - imageSize.height) / 2,
                        right: (buttonSize.width - imageSize.width) / 2
                    )
                }
                if attributedString.string == " " {
                    setButtonImage(
                        UIImage(named: "space-icon"),
                        CGSize(width: buttonSize.width * 0.6, height: buttonSize.width * 0.3)
                    )
                } else if attributedString.string == "\n" {
                    setButtonImage(
                        UIImage(named: "enter-key-icon"),
                        CGSize(width: buttonSize.width * 0.6, height: buttonSize.width * 0.3)
                    )
                }
            }
        }
    }
    
    var margin = UIFont.tiny.pointSize
    var insets = UIEdgeInsets(
        top: UIFont.tiny.pointSize / 2,
        left: UIFont.tiny.pointSize / 2,
        bottom: UIFont.tiny.pointSize / 2,
        right: UIFont.tiny.pointSize / 2
    )
    
    private(set) var buttons = [KeyboardButton]()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layoutButtons()
    }
    
    private func layoutButtons() {
        let maxButtonWidth = buttons.reduce(0, { max($0, $1.bounds.width) })
        contentSize.width = max(bounds.width, maxButtonWidth + insets.left + insets.right)
        var rows: [[UIButton]] = [[]]
        var maxLineHeight: CGFloat = 0
        var pointer = CGPoint(x: insets.left, y: insets.top)
        buttons.sort { $0.bounds.width < $1.bounds.width }
        for button in buttons {
            if contentSize.width <
                (pointer.x + button.bounds.width + insets.right)
            {
                pointer.x = insets.left
                pointer.y += (maxLineHeight + margin)
                maxLineHeight = 0
                rows.append([])
            }
            button.frame.origin = pointer
            rows[rows.count - 1].append(button)
            pointer.x += (button.bounds.width + margin)
            maxLineHeight = max(maxLineHeight, button.bounds.height)
        }
        for row in rows {
            let padding = (
                contentSize.width - insets.left - insets.right -
                row.reduce(0, { $0 + $1.bounds.width }) -
                (margin * CGFloat(row.count - 1))
                ) / 2
            row.forEach { $0.frame.origin.x += padding }
        }
        contentSize.height = (pointer.y + maxLineHeight)
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
}

fileprivate class CaretView: UIView {
    
    var timeInterval: TimeInterval = 0.6
    
    private var timer: Timer?
    
    func show() {
        hide()
        isHidden = false
        timer = Timer.scheduledTimer(
            withTimeInterval: timeInterval,
            repeats: true
        ) { _ in
            self.isHidden = !self.isHidden
        }
    }
    
    func hide() {
        isHidden = true
        timer?.invalidate()
    }
    
}

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
            describedFiles.removeAll(keepingCapacity: true)
            releasedDescriptions.removeAll(keepingCapacity: true)
            questions.removeAll(keepingCapacity: true)
            focusFrames.removeAll(keepingCapacity: true)
            fileTreeView.rootFolder = lesson?.rootFolder
            codeEditorView.set(file: lesson?.rootFolder?.childFiles.first)
            if let rootFolder = lesson?.rootFolder {
                var folders = [rootFolder]
                while !folders.isEmpty {
                    let folder = folders.popLast()!
                    describedFiles.append(contentsOf: folder.childFiles.filter { $0.index != nil })
                    folders.append(contentsOf: folder.childFolders)
                }
            }
            releaseDescriptions()
        }
    }
    
    private var keyboardViewTrailingConstraint: NSLayoutConstraint?
    private var descriptionCollectionViewTopConstraint: NSLayoutConstraint?
    private var describedFiles = [File]()
    private var releasedDescriptions = [Description]()
    private var activeQuestion: Question?
    private var questions = [Question]()
    private var focusFrames = [Frame]()
    private let fileTreeView = FileTreeView()
    private let codeEditorView = CodeEditorView()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showDescriptionCollectionView()
        codeEditorView.contentSize.height += descriptionCollectionView.bounds.height
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        view.addSubview(fileTreeView)
        view.addSubview(codeEditorView)
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
        codeEditorView.backgroundColor = .black
        codeEditorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            codeEditorView.leadingAnchor.constraint(equalTo: fileTreeView.trailingAnchor),
            codeEditorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            codeEditorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            codeEditorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
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
                guard let frame = self.codeEditorView.addFrame(
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
                self.codeEditorView.scroll(to: topIndex, animationDuration: animationDuration)
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
            self.codeEditorView.deactivateQuestion(id: activeQuestion.id)
            self.activeQuestion = nil
        }
        if questions.isEmpty {
            keyboardViewTrailingConstraint?.constant = 0
            UIView.Animation.fast(animations: {
                self.view.layoutIfNeeded()
                deactivateActiveQuestion()
            }) { _ in
                self.releaseDescriptions()
                self.descriptionCollectionView.reloadData()
                UIView.Animation.fast {
                    self.showDescriptionCollectionView()
                }
            }
        } else {
            let question = questions.removeFirst()
            let activateNextQuestion = {
                self.codeEditorView.scroll(
                    to: question.startIndex,
                    animationDuration: UIView.Animation.Duration.fast
                ) { _ in
                    guard let questionAnswer = self.codeEditorView.questionAnswers.first(where: { $0.questionId == question.id })
                    else {
                            return
                    }
                    var counter = [NSAttributedString: Int]()
                    for inputButton in question.inputButtons {
                        let attributedString = questionAnswer.answer.attributedSubstring(
                            from: NSRange(
                                location: inputButton.startIndex,
                                length: inputButton.endIndex - inputButton.startIndex
                            )
                        )
                        counter[attributedString] = (counter[attributedString] ?? 0) + 1
                    }
                    self.keyboardView.counter = counter
                    self.keyboardView.buttons.forEach { $0.addTarget(self, action: #selector(self.onTouchUpInsideKeyboardButton(_:)), for: .touchUpInside) }
                    self.keyboardView.setNeedsDisplay()
                    self.keyboardViewTrailingConstraint?.constant = self.keyboardView.bounds.width + self.view.safeAreaInsets.left
                    UIView.Animation.fast {
                        self.view.layoutIfNeeded()
                        self.codeEditorView.activateQuestion(id: question.id)
                    }
                }
            }
            if activeQuestion == nil {
                activateNextQuestion()
            } else {
                UIView.Animation.fast(animations: {
                    self.keyboardView.alpha = 0
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
        guard let fileView = sender.userInfo?[FileView.userInfoKey] as? FileView else {
            return
        }
        codeEditorView.set(file: fileView.file)
    }
    
    @objc
    private func onTouchUpInsideAnswerButton(_ sender: UIButton) {
        hideDescriptionCollectionView() { _ in
            self.nextPhase()
        }
    }
    
    @objc
    private func onTouchUpInsideKeyboardButton(_ sender: UIButton) {
        guard let text = sender.attributedTitle(for: .normal)?.string else {
            return
        }
        guard let activeQuestion = activeQuestion else {
            return
        }
        guard codeEditorView.isCorrect(questionId: activeQuestion.id, text: text) else {
            return
        }
        guard codeEditorView.solve(question: activeQuestion, text: text) else {
            return
        }
        nextPhase()
    }
    
}

extension LessonViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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

fileprivate struct IndexPair {
    let start: Int
    let end: Int
    init(start: Int, end: Int) {
        self.start = start
        self.end = end
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
        let answer: NSAttributedString
        var enteredText: String = ""
        
        init(questionId: Int, answer: NSAttributedString) {
            self.questionId = questionId
            self.answer = answer
        }
        
    }
    
    private class QuestionFrame: Frame {
        
        let questionId: Int
        
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
    
    private(set) var questionAnswers = [QuestionAnswer]()
    
    private var file: File?
    private var questionFrames = [QuestionFrame]()
    private let codeLabel = UILabel()
    
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        syntaxHighlightedText.addAttributes(
            [NSAttributedString.Key.font: font, .paragraphStyle: paragraphStyle],
            range: NSRange(location: 0, length: syntaxHighlightedText.string.count)
        )
        questionAnswers.removeAll(keepingCapacity: true)
        questionFrames.forEach { $0.remove() }
        questionFrames.removeAll(keepingCapacity: true)
        let questions = file.descriptions.map { $0.questions }.flatMap { $0 }.sorted { $0.startIndex < $1.startIndex }
        for question in questions {
            questionAnswers.append(
                QuestionAnswer(
                    questionId: question.id,
                    answer: syntaxHighlightedText.attributedSubstring(
                        from: NSRange(
                            location: question.startIndex,
                            length: question.endIndex - question.startIndex
                        )
                    )
                )
            )
            syntaxHighlightedText.addAttributes(
                [.foregroundColor: UIColor.clear],
                range: NSRange(
                    location: question.startIndex,
                    length: question.endIndex - question.startIndex
                )
            )
            if let frame = addFrame(startIndex: question.startIndex, endIndex: question.endIndex)
            {
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
//            let headSpaceRegex = try! NSRegularExpression(pattern: "^ +", options: .anchorsMatchLines)
            let headSpaceWidth: CGFloat = 0
//            if let headSpace = headSpaceRegex.matches(in: line, range: NSRange(location: 0, length: NSString(string: line).length)).first {
//                let headSpaces = String(NSString(string: line).substring(with: headSpace.range))
//                headSpaceWidth = textSize(headSpaces).width
//            }
            let lineSize = textSize(line)
            if !line.isEmpty {
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
    
    func textSize(_ text: String?, omittingLastLine: Bool = false) -> CGSize {
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
    
    func isCorrect(questionId: Int, text: String) -> Bool {
        guard let questionAnswer = questionAnswers.first(where: { $0.questionId == questionId})
        else {
            return false
        }
        return questionAnswer.answer.string.hasPrefix(questionAnswer.enteredText + text)
    }
    
    func solve(question: Question, text: String) -> Bool {
        guard let attributedText =  codeLabel.attributedText else {
            return false
        }
        guard isCorrect(questionId: question.id, text: text) else {
            return false
        }
        guard let questionAnswerIndex = questionAnswers.firstIndex(
            where: { $0.questionId == question.id }
        ) else {
                return false
        }
        let mutableAttributedText = NSMutableAttributedString(
            attributedString: attributedText
        )
        questionAnswers[questionAnswerIndex].answer.enumerateAttribute(
            .foregroundColor,
            in: NSRange(
                location: questionAnswers[questionAnswerIndex].enteredText.count,
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
                    location: question.startIndex + range.location,
                    length: range.length
                )
            )
        }
        codeLabel.attributedText = mutableAttributedText
        questionAnswers[questionAnswerIndex].enteredText += text
        return questionAnswers[questionAnswerIndex].answer.string.count == questionAnswers[questionAnswerIndex].enteredText.count
    }
    
    func activateQuestion(id: Int) {
        questionFrames.first { $0.questionId == id }?.borderViews.forEach { $0.backgroundColor = Appearance.CodeEditor.activeColor }
    }
    
    func deactivateQuestion(id: Int) {
        questionFrames.first { $0.questionId == id }?.borderViews.forEach { $0.backgroundColor = Appearance.CodeEditor.inactiveColor }
    }
    
    private func setupViews() {
        addSubview(codeLabel)
        codeLabel.numberOfLines = 0
        codeLabel.font = font
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
    
    var count = 0
    
}

fileprivate class KeyboardView: UIScrollView {
    
    var counter: [NSAttributedString: Int]? {
        didSet {
            buttons.forEach { $0.removeFromSuperview() }
            buttons.removeAll(keepingCapacity: true)
            counter?.forEach { (attributedString, count) in
                let button = KeyboardButton()
                addSubview(button)
                buttons.append(button)
                button.setAttributedTitle(attributedString, for: .normal)
                button.count = count
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
        var maxWidth: CGFloat = 0
        for button in buttons {
            button.backgroundColor = UIColor(
                hue: backgroundColorHue,
                saturation: backgroundColorSaturation,
                brightness: backgroundColorBrightness / 2,
                alpha: backgroundColorAlpha
            )
            button.titleLabel?.font = .boldSmall
            button.titleLabel?.textAlignment = .center
            //button.setTitleColor(Appearance.CodeEditor.textColor, for: .normal)
            let buttonFitSize = button.fitSize
            let buttonSize = CGSize(
                width: buttonFitSize.width * 1.2,
                height: buttonFitSize.height * 1.2
            )
            button.frame.size = buttonSize
            maxWidth = max(maxWidth, buttonSize.width)
        }
        contentSize.width = max(bounds.width, maxWidth + insets.left + insets.right)
        var rows: [[UIButton]] = [[]]
        var maxLineHeight: CGFloat = 0
        var pointer = CGPoint(x: insets.left, y: insets.top)
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

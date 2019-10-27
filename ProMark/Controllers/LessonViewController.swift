import UIKit
import MarkdownView

class LessonViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//    override var shouldAutorotate: Bool {
//        return true
//    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return [.landscapeLeft, .landscapeRight]
//    }
    
    var lesson: Lesson? {
        didSet {
            fileTreeView.rootFolder = lesson?.rootFolder
        }
    }
    
    private let sideTabBarView = TabBarView()
    private let fileTreeView = FileTreeView()
    private let keyboardView = KeyboardView()
    private let codeEditorView = CodeEditorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addObservers()
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        view.addSubview(sideTabBarView)
        view.addSubview(codeEditorView)
        let sideViewBackgroundColor = UIColor(red: 51/255, green: 58/255, blue: 73/255, alpha: 1)
        fileTreeView.backgroundColor = sideViewBackgroundColor
        keyboardView.backgroundColor = sideViewBackgroundColor
        sideTabBarView.set(contentViews: ["ファイルツリー": fileTreeView, "入力ボタン": keyboardView])
        sideTabBarView.tabBarView.backgroundColor = UIColor(red: 47/255, green: 53/255, blue: 69/255, alpha: 1)
        sideTabBarView.tabUnderLineView.backgroundColor = .white
        sideTabBarView.contentCollectionView.isScrollEnabled = false
        sideTabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sideTabBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sideTabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sideTabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            sideTabBarView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
        ])
        codeEditorView.backgroundColor = .black
        codeEditorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            codeEditorView.leadingAnchor.constraint(equalTo: sideTabBarView.trailingAnchor),
            codeEditorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            codeEditorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            codeEditorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(observeTapFileViewNotification(_:)), name: .fileViewTapped, object: nil)
    }
    
    private func changeCodeEditorView(fileId: Int? = nil) {
//        let fileId = fileId ??
//                     releasedDescriptions[
//                        descriptionIndex ?? (releasedDescriptions.count - 1)
//                        ].fileId
//        codeEditorViews.forEach { $0.alpha = 0 }
//        codeEditorViews.first { codeEditorView in
//            guard let file = codeEditorView.file else {
//                return false
//            }
//            return file.id == fileId
//        }?.alpha = 1
    }
    
    @objc
    private func observeTapFileViewNotification(_ sender: Notification) {
        guard let file = (sender.userInfo?[FileView.userInfoKey] as? FileView)?.file else {
            return
        }
        codeEditorView.set(file: file)
        codeEditorView.questionFrameViews.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapQuestionFrameView(_:))))}
    }
    
    @objc
    private func onTapQuestionFrameView(_ sender: UITapGestureRecognizer) {
        guard let tappedQuestionFrameView = sender.view as? QuestionFrameView else {
            return
        }
        var counter = [NSAttributedString: Int]()
        for questionFrameView in codeEditorView.questionFrameViews {
            if let id1 = tappedQuestionFrameView.questionId,
                let id2 = questionFrameView.questionId,
                id1 == id2
            {
                questionFrameView.layer.borderColor = Appearance.CodeEditor.activeColor.cgColor
                if /*let file = codeEditorView.file,*/
                    let startIndex = questionFrameView.startIndex,
                    let endIndex = questionFrameView.endIndex
                {
                    let attributedSubstring = codeEditorView.syntaxhighlightedText.attributedSubstring(from: NSRange(location: startIndex, length: endIndex - startIndex))
                    if let count = counter[attributedSubstring] {
                        counter[attributedSubstring] = count + 1
                    } else {
                        counter[attributedSubstring] = 0
                    }
//                    var location = startIndex
//                    var length = 0
//                    for character in file.text[startIndex..<endIndex] {
//                        if character == " " {
//                            let attributedSubstring = codeEditorView.syntaxhighlightedText.attributedSubstring(from: NSRange(location: location, length: length))
//                            if let count = counter[attributedSubstring] {
//                                counter[attributedSubstring] = count + 1
//                            } else {
//                                counter[attributedSubstring] = 0
//                            }
//                            location += length
//                            length = 0
//                        }
//                        length += 1
//                    }
                }
            } else {
                questionFrameView.layer.borderColor = Appearance.CodeEditor.textColor.cgColor
            }
        }
        keyboardView.counter = counter
        sideTabBarView.selectedTabIndex = 1
    }
    
    @objc
    private func onTouchUpInsideKeyboardButton(_ sender: KeyboardButton) {
//        guard let text = sender.text else {
//            return
//        }
//        guard let activeQuestion = activeQuestion else {
//            return
//        }
//        guard let codeEditorView = codeEditorView else {
//            return
//        }
//        let notificationLabel = UILabel()
//        view.addSubview(notificationLabel)
//        notificationLabel.font = .boldLarge
//        notificationLabel.textColor = Appearance.CodeEditor.textColor
//        notificationLabel.textAlignment = .center
//        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            notificationLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
//            notificationLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
//            ])
//        let animateNotificationLabel = {
//            let magnification: CGFloat = 1.25
//            let notificationLabelFitSize = notificationLabel.fitSize
//            NSLayoutConstraint.activate([
//                notificationLabel.widthAnchor.constraint(equalToConstant: notificationLabelFitSize.width * magnification),
//                notificationLabel.heightAnchor.constraint(equalToConstant: notificationLabelFitSize.height * magnification),
//                ])
//            notificationLabel.alpha = 0
//            UIView.Animation.normal(animations: {
//                notificationLabel.alpha = 1
//            }) { _ in
//                UIView.Animation.normal(animations: {
//                    notificationLabel.alpha = 0
//                }) { _ in
//                    notificationLabel.removeFromSuperview()
//                }
//            }
//        }
//        guard codeEditorView.isCorrect(text: text) else {
//            notificationLabel.text = "✖︎"
//            notificationLabel.backgroundColor = .signalRed
//            animateNotificationLabel()
//            return
//        }
//        notificationLabel.text = "◯"
//        notificationLabel.backgroundColor = .seaGreen
//        animateNotificationLabel()
//        guard codeEditorView.solve(questionId: activeQuestion.id, text: text) else {
//            if let nextAnswer = codeEditorView.answers.first {
//                codeEditorView.scroll(to: nextAnswer.range.location)
//            }
//            return
//        }
//        nextPhase()
    }
    
}

fileprivate class QuestionFrameView: UIView {
    
    var questionId: Int?
    var startIndex: Int?
    var endIndex: Int?
    
}

fileprivate class CodeEditorView: UIScrollView {
    
    struct Answer {
        let questionId: Int
        let inputButtonId: Int
        let attributedText: NSAttributedString
        let range: NSRange
        init(questionId: Int, inputButtonId: Int, attributedText: NSAttributedString, range: NSRange) {
            self.questionId = questionId
            self.inputButtonId = inputButtonId
            self.attributedText = attributedText
            self.range = range
        }
    }
    
    var insets = UIEdgeInsets(
        top: UIFont.tiny.pointSize * 0.3,
        left: UIFont.tiny.pointSize * 0.5,
        bottom: UIFont.tiny.pointSize * 0.3,
        right: UIFont.tiny.pointSize * 0.5
    )
    var font = UIFont.boldSmall
    var letterSpacing: CGFloat = 0 {
        didSet {
            fatalError("未対応")
        }
    }
    var lineSpacing: CGFloat = UIFont.tiny.pointSize {
        didSet {
            fatalError("未対応")
        }
    }
    var textAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        return [
            .foregroundColor: UIColor.white,
            .font: font,
            .kern: letterSpacing,
            .paragraphStyle: paragraphStyle,
        ]
    }
    
    private(set) var file: File?
    private(set) var answers = [Answer]()
    private(set) var questionFrameViews = [QuestionFrameView]()
    private(set) var syntaxhighlightedText = NSMutableAttributedString(string: "")
    
    private let codeTextView = UITextView()
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
//        guard let syntaxHighlightedText = SyntaxHighlighter.highlight(file: file) else {
//            return
//        }
        let syntaxhighlightedText = NSMutableAttributedString(string: file.text, attributes: textAttributes)
        self.syntaxhighlightedText = NSMutableAttributedString(attributedString: syntaxhighlightedText)
        answers.removeAll(keepingCapacity: true)
        questionFrameViews.forEach { $0.removeFromSuperview() }
        questionFrameViews.removeAll(keepingCapacity: true)
        if let questions = file.option?.questions {
            for question in questions {
                questionFrameViews.append(contentsOf: addQuestionFrameViews(
                    id: question.id,
                    startIndex: question.startIndex,
                    endIndex: question.endIndex
                ))
                syntaxhighlightedText.addAttributes(
                    [.foregroundColor: UIColor.clear],
                    range: NSRange(
                        location: question.startIndex,
                        length: question.endIndex - question.startIndex
                    )
                )

            }
        }
        codeTextView.attributedText = syntaxhighlightedText
        let codeTextViewSize = codeTextView.fitSize
        codeTextView.frame = CGRect(
            x: insets.left,
            y: insets.top,
            width: codeTextViewSize.width,
            height: codeTextViewSize.height
        )
        contentSize = CGSize(
            width: codeTextViewSize.width + insets.right,
            height: codeTextViewSize.height + insets.bottom
        )
    }
    
    func scroll(
        to textIndex: Int,
        animationDuration: TimeInterval = UIView.Animation.Duration.fast,
        completion: ((Bool) -> Void)? = nil
    ) {
        let size = textSize(upTo: textIndex, omittingLastLine: true)
        UIView.animate(withDuration: animationDuration, animations: {
            self.contentOffset.y = size.height
        }) { finished in
            completion?(finished)
        }
    }
    
    func addQuestionFrameViews(
        id: Int,
        startIndex: Int,
        endIndex: Int,
        color: UIColor = Appearance.CodeEditor.textColor
    ) -> [QuestionFrameView]
    {
        guard let file = file else {
            return []
        }
        var questionFrameViews = [QuestionFrameView]()
        var s = startIndex
        var e = startIndex
        let addQuestionFrameView = {
            guard let questionFrameView = self.addQuestionFrameView(id: id, startIndex: s, endIndex: e) else {
                return
            }
            questionFrameViews.append(questionFrameView)
        }
        for character in file.text[startIndex..<endIndex] {
            if character == "\n" {
                if s != e {
                    addQuestionFrameView()
                }
                s = e + 1
            }
            e += 1
        }
        addQuestionFrameView()
        return questionFrameViews
    }
    
    func addQuestionFrameView(
        id: Int,
        startIndex: Int,
        endIndex: Int,
        color: UIColor = Appearance.CodeEditor.textColor
    ) -> QuestionFrameView?
    {
        guard let file = file else {
            return nil
        }
        let borderSize = UIFont.tiny.pointSize * 0.1
        let head = file.text[...startIndex].split(separator: "\n").last
        let line = file.text[startIndex..<endIndex]
        let lineSize = textSize(String(line))
        let x = ((head != nil) ?
            (textSize(String(head!)).width - textSize(String(file.text[startIndex])).width) :
            CGFloat(0)) + insets.left
        let y = textSize(upTo: startIndex, omittingLastLine: true).height + insets.top
        let questionFrameView = QuestionFrameView()
        addSubview(questionFrameView)
        questionFrameView.questionId = id
        questionFrameView.startIndex = startIndex
        questionFrameView.endIndex = endIndex
        questionFrameView.layer.borderWidth = borderSize
        questionFrameView.layer.borderColor = color.cgColor
        questionFrameView.frame = CGRect(x: x, y: y, width: lineSize.width, height: lineSize.height)
        return questionFrameView
    }
    
    func textSize(upTo index: Int, omittingLastLine: Bool = false) -> CGSize {
        return textSize(startIndex: 0, endIndex: index, omittingLastLine: omittingLastLine)
    }
    
    func textSize(startIndex: Int, endIndex: Int, omittingLastLine: Bool = false) -> CGSize {
        return textSize(file?.text[startIndex..<endIndex], omittingLastLine: omittingLastLine)
    }
    
    func isCorrect(text: String) -> Bool {
        guard let nextAnswer = answers.first else {
            return false
        }
        return nextAnswer.attributedText.string == text
    }
    
    func solve(questionId: Int, text: String) -> Bool {
        guard isCorrect(text: text) else {
            return false
        }
        guard let attributedText = codeTextView.attributedText else {
            return false
        }
        guard let nextAnswer = answers.first else {
            return false
        }
        let mutableAttributedText = NSMutableAttributedString(
            attributedString: attributedText
        )
        nextAnswer.attributedText.enumerateAttribute(
            .foregroundColor,
            in: nextAnswer.attributedText.string.fullRange
        ) { foregroundColor, range, _ in
            guard let foregroundColor = foregroundColor else {
                return
            }
            mutableAttributedText.addAttribute(
                .foregroundColor,
                value: foregroundColor,
                range: NSRange(
                    location: nextAnswer.range.location + range.location,
                    length: range.length
                )
            )
        }
        codeTextView.attributedText = mutableAttributedText
        _ = answers.removeFirst()
        moveCaret()
        return answers.first { $0.questionId == questionId } == nil
    }
    
    func activateQuestion(id: Int) {
//        questionFrames.filter { $0.questionId == id}.forEach { $0.borderViews.forEach { $0.backgroundColor = Appearance.CodeEditor.activeColor }}
    }

    func deactivateQuestion(id: Int) {
//        questionFrames.filter { $0.questionId == id}.forEach { $0.borderViews.forEach { $0.backgroundColor = Appearance.CodeEditor.inactiveColor }}
    }
    
    func showCaret() {
        moveCaret()
        caretView.show()
    }
    
    func hideCaret() {
        caretView.hide()
    }
    
    private func setupViews() {
        addSubview(codeTextView)
        addSubview(caretView)
        codeTextView.isEditable = false
        codeTextView.isSelectable = false
        codeTextView.isScrollEnabled = false
        codeTextView.font = font
        codeTextView.textContainerInset = .zero
        codeTextView.backgroundColor = .clear
        caretView.hide()
        caretView.backgroundColor = Appearance.CodeEditor.textColor
        caretView.frame.size.width = UIFont.small.pointSize * 0.1
        caretView.frame.size.height = textSize(" ").height
    }
    
    private func moveCaret() {
        guard let file = file else {
            return
        }
        guard let nextAnswer = answers.first else {
            return
        }
        let line = file.text[...nextAnswer.range.location].split(separator: "\n").last
        let x = (line != nil) ?
            textSize(String(line!)).width - textSize(String(file.text[nextAnswer.range.location])).width :
            CGFloat(0)
        let y = textSize(upTo: nextAnswer.range.location, omittingLastLine: true).height
        caretView.frame.origin.x = insets.left + x
        caretView.frame.origin.y = insets.top + y
        bringSubviewToFront(caretView)
    }
    
    private func textSize(_ text: String?, omittingLastLine: Bool = false) -> CGSize {
        guard let text = text else {
            return .zero
        }
        var attributes = textAttributes
        attributes.removeValue(forKey: .paragraphStyle)
        var size = text.size(withAttributes: attributes)
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        size.height += self.lineSpacing * CGFloat(lines.count - 1)
        if omittingLastLine {
            size.height -= textSize(lines.last).height
        }
        return size
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

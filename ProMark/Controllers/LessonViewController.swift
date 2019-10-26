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
        fileTreeView.backgroundColor = .lightGray
        fileTreeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fileTreeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            fileTreeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            fileTreeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            fileTreeView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
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
//        changeCodeEditorView(fileId: file.id)
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


fileprivate struct Frame {
    
    let borderViews: [UIView]
    
    init(_ borderViews: [UIView]) {
        self.borderViews = borderViews
    }
    
    func remove() {
        borderViews.forEach { $0.removeFromSuperview() }
    }
    
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
    
    private struct QuestionFrame {
        
        let questionId: Int
        let borderViews: [UIView]
        
        init(questionId: Int, borderViews: [UIView]) {
            self.questionId = questionId
            self.borderViews = borderViews
        }
        
        func remove() {
            borderViews.forEach { $0.removeFromSuperview() }
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
    
    private var questionFrames = [QuestionFrame]()
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
        let syntaxHighlightedText = NSMutableAttributedString(string: file.text)
        syntaxHighlightedText.addAttributes(
            textAttributes,
            range: NSRange(location: 0, length: syntaxHighlightedText.string.count)
        )
        answers.removeAll(keepingCapacity: true)
        questionFrames.forEach { $0.remove() }
        questionFrames.removeAll(keepingCapacity: true)
//        let questions = file.descriptions.flatMap { $0.questions }
//        for question in questions {
//            for inputButton in question.inputButtons {
//                let range = NSRange(
//                    location: inputButton.startIndex,
//                    length: inputButton.endIndex - inputButton.startIndex
//                )
//                answers.append(Answer(
//                    questionId: question.id,
//                    inputButtonId: inputButton.id,
//                    attributedText: syntaxHighlightedText.attributedSubstring(from: range),
//                    range: range
//                ))
//                syntaxHighlightedText.addAttributes(
//                    [.foregroundColor: UIColor.clear],
//                    range: range
//                )
//            }
//            let group = Dictionary(grouping: question.inputButtons) { inputButton in
//                return inputButton.lineNumber
//            }
//            for inputButtons in group.values {
//                if let frame = addFrame(
//                    startIndex: inputButtons.reduce(Int.max, { min($0, $1.startIndex)}),
//                    endIndex: inputButtons.reduce(0, { max($0, $1.endIndex) })
//                ) {
//                    questionFrames.append(QuestionFrame(
//                        questionId: question.id,
//                        borderViews: frame.borderViews
//                    ))
//                }
//            }
//        }
        //codeTextView.attributedText = syntaxHighlightedText
        codeTextView.textColor = .white
        codeTextView.text = file.text
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
    
    func addFrame(
        startIndex: Int,
        endIndex: Int,
        color: UIColor = Appearance.CodeEditor.textColor
    ) -> Frame? {
        guard let file = file else {
            return nil
        }
        var borderViews = [UIView]()
        let makeBorderView = { () -> UIView in
            let borderView = UIView()
            self.addSubview(borderView)
            borderViews.append(borderView)
            borderView.backgroundColor = color
            return borderView
        }
        let borderSize = UIFont.tiny.pointSize * 0.1
        let head = file.text[...startIndex].split(separator: "\n").last
        let line = file.text[startIndex..<endIndex]
        let lineSize = textSize(String(line))
        let x = (head != nil) ?
            (textSize(String(head!)).width - textSize(String(file.text[startIndex])).width) :
            CGFloat(0)
        let y = textSize(upTo: startIndex, omittingLastLine: true).height
        let leftBorderView = makeBorderView()
        leftBorderView.frame.origin.x = x
        leftBorderView.frame.origin.y = y
        leftBorderView.frame.size.width = borderSize
        leftBorderView.frame.size.height = lineSize.height
        let topBorderView = makeBorderView()
        topBorderView.frame.origin.x = leftBorderView.frame.maxX
        topBorderView.frame.origin.y = y
        topBorderView.frame.size.width = lineSize.width
        topBorderView.frame.size.height = borderSize
        let rightBorderView = makeBorderView()
        rightBorderView.frame.origin.x = topBorderView.frame.maxX
        rightBorderView.frame.origin.y = y
        rightBorderView.frame.size = leftBorderView.bounds.size
        let bottomBorderView = makeBorderView()
        bottomBorderView.frame.origin.x = topBorderView.frame.origin.x
        bottomBorderView.frame.origin.y = leftBorderView.frame.maxY - borderSize
        bottomBorderView.frame.size = topBorderView.bounds.size
        for borderView in borderViews {
            borderView.frame.origin.x += insets.left
            borderView.frame.origin.y += insets.top
        }
        return Frame(borderViews)
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
        questionFrames.filter { $0.questionId == id}.forEach { $0.borderViews.forEach { $0.backgroundColor = Appearance.CodeEditor.activeColor }}
    }

    func deactivateQuestion(id: Int) {
        questionFrames.filter { $0.questionId == id}.forEach { $0.borderViews.forEach { $0.backgroundColor = Appearance.CodeEditor.inactiveColor }}
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

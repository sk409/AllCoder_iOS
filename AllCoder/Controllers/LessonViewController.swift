import UIKit

class LessonViewController: UIViewController {
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    
    var lesson: Lesson? {
        didSet {
            fileTreeView.rootFolder = lesson?.rootFolder
            // TODO: ファイルの順番を決める
            codeEditorView.file = lesson?.rootFolder?.childFiles.first
            //
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
            fileTreeView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4)
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
        //print(fileView.file?.text)
    }
    
}


fileprivate class QuestionView: UIView {
    
    private var framePath = UIBezierPath()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        UIColor.white.setStroke()
        framePath.lineWidth = UIScreen.main.bounds.width * 0.01
        framePath.stroke()
        //framePath.fill()
        let imageView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
        imageView.frame.size = bounds.size
        addSubview(imageView)
        UIGraphicsEndImageContext()
    }
    
    func build(font: UIFont, text: String, question: Question) {
        let prefixLines = text[..<question.startIndex].split(separator: "\n", omittingEmptySubsequences: false).map({String($0)})
        guard let lastLine = prefixLines.last else {
            return
        }
        let size: (String?) -> CGSize = { string in
            guard let string = string else {
                return .zero
            }
            return string.size(withAttributes: [.font: font])
        }
        let lastLineSize = size(lastLine)
        let questionLines = text[question.startIndex..<question.endIndex].split(separator: "\n").map{ String($0) }
        var y: CGFloat = 0
        for (index, line) in questionLines.enumerated() {
            let lineSize = size(line)
            if index == 0 {
                framePath.move(to: CGPoint(x: lastLineSize.width + lineSize.width, y: y))
                framePath.addLine(to: CGPoint(x: lastLineSize.width + lineSize.width, y: y + lineSize.height))
            } else {
                framePath.addLine(to: CGPoint(x: lineSize.width, y: y))
                framePath.addLine(to: CGPoint(x: lineSize.width, y: y + lineSize.height))
            }
            y += lineSize.height
            frame.size.width = max(frame.size.width, lineSize.width)
            frame.size.height += lineSize.height
        }
        framePath.addLine(to: CGPoint(x: 0, y: y))
        framePath.addLine(to: CGPoint(x: 0, y: lastLineSize.height))
        framePath.addLine(to: CGPoint(x: lastLineSize.width, y: lastLineSize.height))
        framePath.addLine(to: CGPoint(x: lastLineSize.width, y: 0))
        framePath.close()
        frame.origin = CGPoint(
            x: 0,
            y: prefixLines.reduce(0, { $0 + size($1).height }) - lastLineSize.height
        )
    }
    
}


fileprivate class CodeEditorView: UIScrollView {
    
    var font = UIFont.boldSmall
    var insets = UIEdgeInsets(
        top: UIScreen.main.bounds.width * 0.01,
        left: UIScreen.main.bounds.width * 0.01,
        bottom: UIScreen.main.bounds.width * 0.01,
        right: UIScreen.main.bounds.width * 0.01
    )
    //var insets = UIEdgeInsets.zero
    
    var file: File? {
        didSet {
            guard let file = file else {
                return
            }
            let codeLabel = UILabel()
            addSubview(codeLabel)
            codeLabel.numberOfLines = 0
            codeLabel.text = file.text
            codeLabel.textColor = .white
            codeLabel.font = font
            let codeLabelSize = codeLabel.sizeThatFits
            codeLabel.frame = CGRect(
                x: insets.left,
                y: insets.top,
                width: codeLabelSize.width,
                height: codeLabelSize.height
            )
            contentSize = codeLabelSize
            let questions = file.descriptions.map { $0.questions }.flatMap { $0 }
            for question in questions {
                let prefixLines = file.text[..<question.startIndex].split(separator: "\n", omittingEmptySubsequences: false).map({String($0)})
                guard let lastLine = prefixLines.last else {
                    continue
                }
                let size: (String?) -> CGSize = { string in
                    guard let string = string else {
                        return .zero
                    }
                    return string.size(withAttributes: [.font: self.font])
                }
                let lastLineSize = size(lastLine)
                let questionLines = file.text[question.startIndex..<question.endIndex].split(separator: "\n").map{ String($0) }
                guard let firstLine = questionLines.first else {
                    return
                }
                let borderSize = font.pointSize * 0.1
                let prefixLinesHeight = insets.top + prefixLines.reduce(0, { $0 + size($1).height }) - lastLineSize.height
                let makeBorderView = { () -> UIView in
                    let boderView = UIView()
                    self.addSubview(boderView)
                    boderView.backgroundColor = .white
                    return boderView
                }
                //TODO: origin.x -> center.x
                var x: CGFloat = 0
                var y: CGFloat = prefixLinesHeight
                for (index, line) in questionLines.enumerated() {
                    let lineSize = size(line)
                    let makeVerticalBorderView: (CGFloat) -> Void = { originX in
                        let boderView = makeBorderView()
                        boderView.frame.origin.y = y
                        boderView.frame.size.width = borderSize
                        boderView.frame.size.height = lineSize.height + borderSize
                        boderView.frame.origin.x = originX + self.insets.left
                        x = (boderView.frame.origin.x - self.insets.left)
                    }
                    if index == 0 {
                        makeVerticalBorderView(lastLineSize.width + lineSize.width)
                    } else {
                        let horizontalBorderView = makeBorderView()
                        horizontalBorderView.frame.origin.y = y
                        horizontalBorderView.frame.origin.x = min(x, lineSize.width) + insets.left
                        horizontalBorderView.frame.size.width = abs(x - lineSize.width)
                        horizontalBorderView.frame.size.height = borderSize
                        makeVerticalBorderView(lineSize.width)
                    }
                    y += lineSize.height
                }
                let borderView1 = makeBorderView()
                borderView1.frame.origin = CGPoint(x: insets.left, y: y)
                borderView1.frame.size = CGSize(width: x, height: borderSize)
                let borderView2 = makeBorderView()
                borderView2.frame.origin = CGPoint(x: insets.left, y: prefixLinesHeight + lastLineSize.height)
                borderView2.frame.size = CGSize(width: borderSize, height: y - borderView2.frame.origin.y)
                let borderView3 = makeBorderView()
                borderView3.frame.origin = CGPoint(x: insets.left, y: prefixLinesHeight + lastLineSize.height)
                borderView3.frame.size = CGSize(width: lastLineSize.width, height: borderSize)
                let borderView4 = makeBorderView()
                borderView4.frame.origin = CGPoint(x: insets.left + lastLineSize.width, y: prefixLinesHeight)
                borderView4.frame.size = CGSize(width: borderSize, height: lastLineSize.height + borderSize)
                let borderView5 = makeBorderView()
                borderView5.frame.origin = CGPoint(x: insets.left + lastLineSize.width, y: prefixLinesHeight)
                borderView5.frame.size = CGSize(width: size(firstLine).width, height: borderSize)
//                framePath.addLine(to: CGPoint(x: lastLineSize.width, y: 0))
//                framePath.close()
//                frame.origin = CGPoint(
//                    x: 0,
//                    y: prefixLines.reduce(0, { $0 + size($1).height }) - lastLineSize.height
//                )
            }
        }
    }
    
}

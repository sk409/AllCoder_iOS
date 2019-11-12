import Foundation

struct SyntaxHighlighter {
    
    static func highlight(file: File) -> NSMutableAttributedString?
    {
        guard let fileExtension = FileExtension(file: file) else {
            return nil
        }
        let mutableAttributedString = NSMutableAttributedString(string: file.text, attributes: [.foregroundColor: Appearance.CodeEditor.textColor])
        switch fileExtension {
        case .html:
            HTMLSyntaxHighlighter.highlight(mutableAttributedString)
        case .php:
            PHPSyntaxHighlighter.highlight(mutableAttributedString)
        case .blade:
            LaravelBladeSyntaxHighlighter.highlight(mutableAttributedString)
        }
        return mutableAttributedString
    }
    
}

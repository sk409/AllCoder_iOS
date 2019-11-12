import Foundation
import UIKit

struct PHPSyntaxHighlighter {
    
    static var stringColor = UIColor(red: 206/255, green: 145/255, blue: 120/255, alpha: 1)
    static var variableColor = UIColor(red: 169/255, green: 219/255, blue: 250/255, alpha: 1)
    static var classColor = UIColor(red: 112/255, green: 197/255, blue: 176/255, alpha: 1)
    static var functionColor = UIColor(red: 195/255, green: 195/255, blue: 157/255, alpha: 1)
    
    static func highlight(_ mutableAttributedString: NSMutableAttributedString, range: NSRange? = nil) {
        let text = mutableAttributedString.string
        let highlightRange = range ?? text.fullRange
        let stringRegex = try! NSRegularExpression(pattern: "\".*?\"|'.*?'", options: .dotMatchesLineSeparators)
        let stringMatches = stringRegex.matches(in: text, range: highlightRange)
        for stringMatch in stringMatches {
            mutableAttributedString.addAttribute(.foregroundColor, value: PHPSyntaxHighlighter.stringColor, range: stringMatch.range)
        }
        let variableRegex = try! NSRegularExpression(pattern: "$[^ ]*")
        let variableMatches = variableRegex.matches(in: text, range: highlightRange)
        for variableMatch in variableMatches {
            mutableAttributedString.addAttribute(.foregroundColor, value: PHPSyntaxHighlighter.variableColor, range: variableMatch.range)
        }
        let classRegex = try! NSRegularExpression(pattern: "([a-zA-Z0-9_]+?)::|new ([a-zA-Z0-9_]+?)")
        let classMatches = classRegex.matches(in: text, range: highlightRange)
        for classMatch in classMatches {
            let classNameRange = classMatch.range(at: 1)
            mutableAttributedString.addAttribute(.foregroundColor, value: PHPSyntaxHighlighter.classColor, range: classNameRange)
        }
        let functionRegex = try! NSRegularExpression(pattern: "([a-zA-Z0-9_]+?)\\(", options: .dotMatchesLineSeparators)
        let functionMatches = functionRegex.matches(in: text, range: highlightRange)
        for functionMatch in functionMatches {
            let functionNameRange = functionMatch.range(at: 1)
            mutableAttributedString.addAttribute(.foregroundColor, value: PHPSyntaxHighlighter.functionColor, range: functionNameRange)
        }
    }
    
    static func highlightInsidePHPTag(_ mutableAttributedString: NSMutableAttributedString, range: NSRange? = nil) {
        HTMLSyntaxHighlighter.highlight(mutableAttributedString)
        let text = mutableAttributedString.string
        let highlightRange = range ?? text.fullRange
        let phpRegex = try! NSRegularExpression(pattern: "<?php.*?>")
        let phpMatches = phpRegex.matches(in: text, range: highlightRange)
        for phpMatch in phpMatches {
            mutableAttributedString.addAttribute(.foregroundColor, value: HTMLSyntaxHighlighter.tagColor, range: NSRange(location: phpMatch.range.location, length: 5))
            mutableAttributedString.addAttribute(.foregroundColor, value: HTMLSyntaxHighlighter.tagColor, range: NSRange(location: phpMatch.range.location + phpMatch.range.length - 2, length: 2))
            PHPSyntaxHighlighter.highlight(mutableAttributedString, range: phpMatch.range)
        }
    }
    
}

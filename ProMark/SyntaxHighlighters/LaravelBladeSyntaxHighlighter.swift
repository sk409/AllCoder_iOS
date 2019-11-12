import Foundation
import UIKit

struct LaravelBladeSyntaxHighlighter {
    
    static var mustacheColor = UIColor(red: 195/255, green: 195/255, blue: 157/255, alpha: 1)
    static var directiveColor = UIColor(red: 66/255, green: 92/255, blue: 119/255, alpha: 1)
    
    static func highlight(_ mutableAttributedString: NSMutableAttributedString, range: NSRange? = nil) {
        PHPSyntaxHighlighter.highlightInsidePHPTag(mutableAttributedString)
        let text = mutableAttributedString.string
        let highlightRange = range ?? text.fullRange
        let mustacheRegex = try! NSRegularExpression(pattern: "(\\{\\{).*?(\\}\\})", options: .dotMatchesLineSeparators)
        let mustacheMatches = mustacheRegex.matches(in: text, range: highlightRange)
        for mustacheMatch in mustacheMatches {
            mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: mustacheMatch.range)
            mutableAttributedString.addAttribute(.foregroundColor, value: LaravelBladeSyntaxHighlighter.mustacheColor, range: mustacheMatch.range(at: 1))
            mutableAttributedString.addAttribute(.foregroundColor, value: LaravelBladeSyntaxHighlighter.mustacheColor, range: mustacheMatch.range(at: 2))
            PHPSyntaxHighlighter.highlight(mutableAttributedString, range: mustacheMatch.range)
        }
        let directives = ["@auth", "@endauth", "@else", "@elseif", "@foreach", "@endforeach", "@if", "@endif",]
        let directiveRegex = try! NSRegularExpression(pattern: directives.joined(separator: "|"))
        let directiveMatches = directiveRegex.matches(in: text, range: highlightRange)
        for directiveMatch in directiveMatches {
            let directive = NSString(string: text).substring(with: directiveMatch.range)
            if ["@if", "@foreach"].contains(directive) {
                let location = directiveMatch.range.location + directiveMatch.range.length
                var length = 0
                var open = false
                for character in text[location...] {
                    if character == "(" {
                        open = true
                    }
                    if character == ")" && open {
                        break
                    }
                    length += 1
                }
                PHPSyntaxHighlighter.highlight(mutableAttributedString, range: NSRange(location: location, length: length))
            }
            mutableAttributedString.addAttribute(.foregroundColor, value: LaravelBladeSyntaxHighlighter.directiveColor, range: directiveMatch.range)
        }
    }
    
}

import Foundation
import UIKit

struct CSSSyntaxHighlighter {
    
    static var selectorColor = UIColor(red: 205/255, green: 182/255, blue: 130/255, alpha: 1)
    static var propertyNameColor = UIColor(red: 169/255, green: 219/255, blue: 250/255, alpha: 1)
    static var propertyValueColor = UIColor(red: 206/255, green: 145/255, blue: 120/255, alpha: 1)
    
    static func highlight(_ mutableAttributedString: NSMutableAttributedString, range: NSRange? = nil) {
        let text = mutableAttributedString.string
        let highlightRange = range ?? text.fullRange
        let selectorRegex = try! NSRegularExpression(pattern: "^.+\\{$", options: .anchorsMatchLines)
        let selectorMatches = selectorRegex.matches(in: text, range: highlightRange)
        for selectorMatch in selectorMatches {
            let selectorNameRegex = try! NSRegularExpression(pattern: "[a-zA-Z0-9\\-]+")
            let selectorNameMatches = selectorNameRegex.matches(in: text, range: selectorMatch.range)
            for selectorNameMatch in selectorNameMatches {
                mutableAttributedString.addAttribute(.foregroundColor, value: CSSSyntaxHighlighter.selectorColor, range: selectorNameMatch.range)
            }
        }
        let propertyRegex = try! NSRegularExpression(pattern: "([a-zA-Z\\-]+?):(.+?);")
        let propertyMatches = propertyRegex.matches(in: text, range: highlightRange)
        for propertyMatch in propertyMatches {
            mutableAttributedString.addAttribute(.foregroundColor, value: CSSSyntaxHighlighter.propertyNameColor, range: propertyMatch.range(at: 1))
            mutableAttributedString.addAttribute(.foregroundColor, value: CSSSyntaxHighlighter.propertyValueColor, range: propertyMatch.range(at: 2))
        }
    }
    
}

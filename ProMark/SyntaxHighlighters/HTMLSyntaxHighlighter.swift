import Foundation
import UIKit

struct HTMLSyntaxHighlighter {
    
    static var tagColor = UIColor(red: 78/255, green: 138/255, blue: 187/255, alpha: 1)
    static var attributeNameColor = UIColor(red: 150/255, green: 211/255, blue: 244/255, alpha: 1)
    static var attributeValueColor = UIColor(red: 206/255, green: 145/255, blue: 120/255, alpha: 1)
    static var commentColor = UIColor(red: 97/255, green: 125/255, blue: 79/255, alpha: 1)
    
    static func highlight(_ mutableAttributedString: NSMutableAttributedString, range: NSRange? = nil) {
        let text = mutableAttributedString.string
        let highlightRange = range ?? text.fullRange
        let tagRegex = try! NSRegularExpression(
            pattern: "<.+?>",
            options: .dotMatchesLineSeparators
        )
        let tagMatches = tagRegex.matches(in: text, range: highlightRange)
        for tagMatch in tagMatches {
            let tagNameRegex = try! NSRegularExpression(pattern: "</?([^ >]+)")
            guard let tagNameMatch = tagNameRegex.firstMatch(in: text, range: tagMatch.range)
            else {
                continue
            }
            mutableAttributedString.addAttribute(
                .foregroundColor,
                value: HTMLSyntaxHighlighter.tagColor,
                range: tagNameMatch.range(at: 1)
            )
            let attributes = ["accesskey",  "class",  "contenteditable",  "contextmenu",  "dir",  "draggable",  "dropzone",  "hidden",  "id",  "lang",  "spellcheck",  "style",  "tabindex",  "title",  "translate", "width",  "height",  "src",  "name",  "srcdoc",  "sandbox",  "seamless",  "alt",  "crossorigin",  "usemap",  "ismap",  "href",  "target",  "rel",  "media",  "hreflang",  "coords",  "shape",  "type",  "preload",  "autoplay",  "mediagroup",  "loop",  "muted",  "controls",  "cite",  "autofocus",  "disabled",  "form",  "formaction",  "formenctype",  "formmethod",  "formnovalidate",  "formtarget",  "value",  "readonly",  "accept-charset",  "action",  "autocomplete",  "enctype",  "method",  "novalidate",  "span",  "icon",  "label",  "checked",  "size",  "list",  "required",  "multiple",  "maxlength",  "pattern",  "placeholder",  "dirname",  "accept",  "max",  "min",  "step",  "sizes",  "high",  "low",  "optimum",  "reversed",  "start",  "selected",  "async",  "defer",  "charset",  "scoped",  "colspan",  "rowspan",  "headers",  "cols",  "rows",  "wrap",  "sortable",  "scope",  "abbr",  "datetime",  "border",  "kind",  "srclang",  "default",  "onafterprint",  "onbeforeprint",  "onbeforeunload",  "onblur",  "onerror",  "onfocus",  "onhashchange",  "onload",  "onmessage",  "onoffline",  "ononline",  "onpagehide",  "onpageshow",  "onpopstate",  "onresize",  "onscroll",  "onstorage",  "onunload",  "onclick",  "radiogroup",  "command",  "open",  "manifest",  "xmlns",  "challenge",  "keytype",  "for",  "itemprop",  "http-equiv",  "content",  "typemustmatch",  "data",  "poster",  "srcset",  "rev",  "nonce", /*******/ "html", /*******/]
            let attributeRegex = try! NSRegularExpression(
                pattern: attributes.joined(separator: "|")
            )
            let attributeMatches = attributeRegex.matches(
                in: text,
                range: NSRange(
                    location: tagMatch.range.location + tagNameMatch.range.length,
                    length: tagMatch.range.length - tagNameMatch.range.length
                )
            )
            for attributeMatch in attributeMatches {
                mutableAttributedString.addAttribute(
                    .foregroundColor,
                    value: HTMLSyntaxHighlighter.attributeNameColor,
                    range: attributeMatch.range
                )
            }
            let valueRegex = try! NSRegularExpression(
                pattern: "=(\".*?\")|=([^ ]+)",
                options: .dotMatchesLineSeparators
            )
            let valueMatches = valueRegex.matches(in: text, range: tagMatch.range)
            for valueMatch in valueMatches {
                mutableAttributedString.addAttribute(
                    .foregroundColor,
                    value: HTMLSyntaxHighlighter.attributeValueColor,
                    range: valueMatch.range(at: 1)
                )
                //print(NSString(string: text).substring(with: valueMatch.range))
            }
            let commentRegex = try! NSRegularExpression(pattern: "<!--.*?-->", options: .dotMatchesLineSeparators)
            let commentMatches = commentRegex.matches(in: text, range: highlightRange)
            for commentMatch in commentMatches {
                mutableAttributedString.addAttribute(.foregroundColor, value: HTMLSyntaxHighlighter.commentColor, range: commentMatch.range)
            }
        }
        let styleRegex = try! NSRegularExpression(pattern: "<style.*?>.+?</style>", options: .dotMatchesLineSeparators)
        let styleMatches = styleRegex.matches(in: text, range: highlightRange)
        for styleMatch in styleMatches {
            CSSSyntaxHighlighter.highlight(mutableAttributedString, range: styleMatch.range)
        }
    }
    
}

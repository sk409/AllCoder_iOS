import Foundation
import UIKit

struct HTMLSyntaxHighlighter {
    
    static func highlight(_ mutableAttributedString: NSMutableAttributedString) {
        let text = mutableAttributedString.string
        let tagRegex = try! NSRegularExpression(
            pattern: "<.+?>",
            options: .dotMatchesLineSeparators
        )
        let tagMatches = tagRegex.matches(in: text, range: text.fullRange)
        for tagMatch in tagMatches {
            let tagNameRegex = try! NSRegularExpression(pattern: "</?([^ >]+)")
            guard let tagNameMatch = tagNameRegex.firstMatch(in: text, range: tagMatch.range)
            else {
                continue
            }
            mutableAttributedString.addAttribute(
                .foregroundColor,
                value: UIColor(red: 78/255, green: 138/255, blue: 187/255, alpha: 1),
                range: tagNameMatch.range(at: 1)
            )
            let attributes = ["accesskey",  "class",  "contenteditable",  "contextmenu",  "dir",  "draggable",  "dropzone",  "hidden",  "id",  "lang",  "spellcheck",  "style",  "tabindex",  "title",  "translate", "width",  "height",  "src",  "name",  "srcdoc",  "sandbox",  "seamless",  "alt",  "crossorigin",  "usemap",  "ismap",  "href",  "target",  "rel",  "media",  "hreflang",  "coords",  "shape",  "type",  "preload",  "autoplay",  "mediagroup",  "loop",  "muted",  "controls",  "cite",  "autofocus",  "disabled",  "form",  "formaction",  "formenctype",  "formmethod",  "formnovalidate",  "formtarget",  "value",  "readonly",  "accept-charset",  "action",  "autocomplete",  "enctype",  "method",  "novalidate",  "span",  "icon",  "label",  "checked",  "size",  "list",  "required",  "multiple",  "maxlength",  "pattern",  "placeholder",  "dirname",  "accept",  "max",  "min",  "step",  "sizes",  "high",  "low",  "optimum",  "reversed",  "start",  "selected",  "async",  "defer",  "charset",  "scoped",  "colspan",  "rowspan",  "headers",  "cols",  "rows",  "wrap",  "sortable",  "scope",  "abbr",  "datetime",  "border",  "kind",  "srclang",  "default",  "onafterprint",  "onbeforeprint",  "onbeforeunload",  "onblur",  "onerror",  "onfocus",  "onhashchange",  "onload",  "onmessage",  "onoffline",  "ononline",  "onpagehide",  "onpageshow",  "onpopstate",  "onresize",  "onscroll",  "onstorage",  "onunload",  "onclick",  "radiogroup",  "command",  "open",  "manifest",  "xmlns",  "challenge",  "keytype",  "for",  "itemprop",  "http-equiv",  "content",  "typemustmatch",  "data",  "poster",  "srcset",  "rev",  "nonce", ]
            let attributeRegex = try! NSRegularExpression(
                pattern: attributes.joined(separator: "|")
            )
            let attributeMatches = attributeRegex.matches(in: text, range: tagMatch.range)
            for attributeMatch in attributeMatches {
                mutableAttributedString.addAttribute(
                    .foregroundColor,
                    value: UIColor(red: 150/255, green: 211/255, blue: 244/255, alpha: 1),
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
                    value: UIColor(red: 206/255, green: 145/255, blue: 120/255, alpha: 1),
                    range: valueMatch.range(at: 1)
                )
            }
        }
    }
    
}

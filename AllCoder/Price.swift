import Foundation

struct Price {
    
    let locale: Locale
    let value: Int
    
    var string: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let formattedString = formatter.string(from: value as NSNumber) else {
            return nil
        }
        switch locale {
        case .japan:
            return "￥" + formattedString
        }
    }
    
    init(locale: Locale, value: Int) {
        self.locale = locale
        self.value = value
    }
    
    
    
}

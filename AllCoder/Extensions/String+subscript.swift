extension String {
    
    subscript(_ i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript(_ range: Range<Int>) -> String {
        return String(self[index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound)])
    }
    
    subscript(_ range: ClosedRange<Int>) -> String {
        return String(self[index(startIndex, offsetBy: range.lowerBound)...index(startIndex, offsetBy: range.upperBound)])
    }
    
    subscript(_ range: PartialRangeFrom<Int>) -> String {
        return String(self[index(startIndex, offsetBy: range.lowerBound)..<endIndex])
    }
    
    subscript(_ range: PartialRangeUpTo<Int>) -> String {
        return String(self[startIndex..<index(startIndex, offsetBy: range.upperBound)])
    }
    
    subscript(_ range: PartialRangeThrough<Int>) -> String {
        return String(self[startIndex...index(startIndex, offsetBy: range.upperBound)])
    }
    
}

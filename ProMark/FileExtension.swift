enum FileExtension: String {
    
    case html
    
    init?(file: File) {
        guard let e = file.name.split(separator: ".").last else {
            return nil
        }
        guard let fileExtension = FileExtension(rawValue: String(e)) else {
            return nil
        }
        self = fileExtension
    }
    
}

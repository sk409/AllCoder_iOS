enum FileExtension: String {
    
    case html
    
    init?(file: File) {
//        print((file.path.split(separator: "/")))
//        print((file.path.split(separator: "/")).last?.split(separator: "."))
        guard let e = (file.path.split(separator: "/")).last?.split(separator: ".").last else {
            return nil
        }
        guard let fileExtension = FileExtension(rawValue: String(e)) else {
            return nil
        }
        self = fileExtension
    }
    
}

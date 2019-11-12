enum FileExtension: String {
    
    case html
    case php
    case blade
    
    init?(file: File) {
//        print((file.path.split(separator: "/")))
//        print((file.path.split(separator: "/")).last?.split(separator: "."))
        guard let baseName = file.path.split(separator: "/").last else {
            return nil
        }
        guard let e = baseName.split(separator: ".").last else {
            return nil
        }
        if e == "php" {
            let split = baseName.split(separator: ".")
            if 2 <= split.count && split[split.count - 2] == "blade" {
                self = .blade
            } else {
                self = .php
            }
        } else {
            guard let fileExtension = FileExtension(rawValue: String(e)) else {
                return nil
            }
            self = fileExtension
        }
    }
    
}

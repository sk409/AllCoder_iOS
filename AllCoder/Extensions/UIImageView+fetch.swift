import UIKit

extension UIImageView {
    
    func fetch(path: String?) {
        if let path = path,
           let data = try? Data(contentsOf: HTTP.defaultOrigin.appendingPathComponent(path))
        {
            image = UIImage(data: data)
        } else {
            image = UIImage(named: "no-image")
        }
    }
    
}

import UIKit

extension UIViewController {
    
    func alert(message: String, handler: (() -> Void)? = nil) {
        alert(title: "", message: message, handler: handler)
    }
    
    func alert(title: String, message: String, handler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            handler?()
        })
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
}

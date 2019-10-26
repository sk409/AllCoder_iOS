import UIKit

class DashboardTabBarController: UITabBarController {
    
//    override var shouldAutorotate: Bool {
//        return true
//    }
//    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return [.portrait, .portraitUpsideDown]
//    }
    
    var user: User? {
        didSet {
            homeViewController.userId = user?.id
            materialSearchViewController.user = user
        }
    }
    
    private let homeViewController = HomeViewController()
    private let materialSearchViewController = MaterialSearchViewController()
    private let messagesViewController = MessagesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        materialSearchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        messagesViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        setViewControllers([homeViewController, materialSearchViewController, messagesViewController], animated: false)
        
    }
    
}

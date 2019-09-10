import UIKit

class DashboardTabBarController: UITabBarController {
    
    var user: User? {
        didSet {
            homeViewController.user = user
            materialSearchViewController.user = user
        }
    }
    
    private let homeViewController = HomeViewController()
    private let materialSearchViewController = MaterialSearchViewController()
    private let messagesViewController = MessagesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        HTTP().async(route: .init(resource: .materials, name: .index, options: [.api])) { response in
//            //print(String(data: response, encoding: .utf8))
//            let jsonDecoder = JSONDecoder()
//            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//            print(try! jsonDecoder.decode([Material].self, from: response))
//        }
        
        
        
        
        homeViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        materialSearchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        messagesViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        setViewControllers([homeViewController, materialSearchViewController, messagesViewController], animated: false)
        
    }
    
}

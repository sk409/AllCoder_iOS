import UIKit

class DashboardTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        HTTP().async(route: .init(resource: .materials, name: .index, options: [.api])) { response in
//            //print(String(data: response, encoding: .utf8))
//            let jsonDecoder = JSONDecoder()
//            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//            print(try! jsonDecoder.decode([Material].self, from: response))
//        }
        
        
        
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        let materialSearchViewController = MaterialSearchViewController()
        materialSearchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        let messagesViewController = MessagesViewController()
        messagesViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        setViewControllers([homeViewController, materialSearchViewController, messagesViewController], animated: false)
        
    }
    
}

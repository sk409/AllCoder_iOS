import Foundation

struct HTTP {
    
    enum Method {
        case post
        case get
        case put
        case delete
    }
    
    struct Route {
        
        enum Resource: String {
            case materials
            case lessons
        }
        
        enum Option: String {
            case api
        }
        
        enum Name: String {
            case store
            case index
            case create
            case destroy
            case show
            case update
            case edit
        }
        
        var path: String?
        let method: Method
        
        init(resource: Resource, name: Name, options: [Option] = [], id: Int? = nil) {
            switch name {
            case .store:
                fallthrough
            case .index:
                path = resource.rawValue
            case .create:
                path = resource.rawValue + "/" + name.rawValue
            case .destroy:
                fallthrough
            case .show:
                fallthrough
            case .update:
                if let id = id {
                    path = resource.rawValue + "/" + String(id)
                }
            case .edit:
                if let id = id {
                    path = resource.rawValue + "/" + String(id) + "/" + name.rawValue
                }
            }
            switch name {
            case .store:
                method = .post
            case .index:
                method = .get
            case .create:
                method = .get
            case .destroy:
                method = .delete
            case .show:
                method = .get
            case .update:
                method = .put
            case .edit:
                method = .get
            }
            guard let path = path else {
                return
            }
            self.path = options.map{ $0.rawValue }.joined(separator: "/") + "/" + path
        }
        
    }
    
    let origin: URL
    
    init(origin: URL = URL(string: "http://localhost:8000")!) {
        self.origin = origin
    }
    
//    func sync(route: Route, parameters: [URLQueryItem] = []) -> Data? {
//        let semaphore = DispatchSemaphore(value: 0)
//        var data: Data?
//        async(route: route, parameters: parameters) { response in
//            defer {
//                semaphore.signal()
//            }
//            data = response
//        }
//        semaphore.wait()
//        return data
//    }
    
    func async(route: Route, parameters: [URLQueryItem] = [], completion: ((Data) -> Void)? = nil) {
        guard let path = route.path else {
            return
        }
        guard var urlComponents = URLComponents(string: origin.appendingPathComponent(path).absoluteString) else {
            return
        }
        urlComponents.queryItems = parameters
        guard let url = urlComponents.url else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
            completion?(data)
        }.resume()
    }
    
    
}
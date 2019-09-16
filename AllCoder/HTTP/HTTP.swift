import Foundation

struct HTTP {
    
    enum Method {
        case post
        case get
        case put
        case delete
    }
    
    struct Route {
        
        enum API: String {
            case register
            case login
        }
        
        enum Resource: String {
            case materials
            case lessons
            case users
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
        
        init(api: API) {
            var path = "api/"
            switch api {
            case .register:
                path += api.rawValue
                method = .post
            case .login:
                path += api.rawValue
                method = .post
            }
            self.path = path
        }
        
        init(resource: Resource, name: Name, id: Int? = nil) {
            var path = "api/"
            switch name {
            case .store:
                fallthrough
            case .index:
                path += resource.rawValue
            case .create:
                path += resource.rawValue + "/" + name.rawValue
            case .destroy:
                fallthrough
            case .show:
                fallthrough
            case .update:
                if let id = id {
                    path += resource.rawValue + "/" + String(id)
                }
            case .edit:
                if let id = id {
                    path += resource.rawValue + "/" + String(id) + "/" + name.rawValue
                }
            }
            self.path = path
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
        }
        
    }
    
    let origin: URL
    
    init(origin: URL = URL(string: "http://localhost:8000")!) {
        self.origin = origin
    }
    
    func sync(route: Route, parameters: [URLQueryItem] = []) -> Data? {
        guard let path = route.path else {
            return nil
        }
        var data: Data?
        let semaphore = DispatchSemaphore(value: 0)
        async(path: path, method: route.method, parameters: parameters) { response in
            defer {
                semaphore.signal()
            }
            data = response
        }
        semaphore.wait()
        return data
    }
    
    func async(path: String, method: Method, parameters: [URLQueryItem] = [], completion: ((Data?) -> Void)? = nil) {
        guard var urlComponents = URLComponents(string: origin.appendingPathComponent(path).absoluteString) else {
            completion?(nil)
            return
        }
        urlComponents.queryItems = parameters
        var request: URLRequest?
        switch method {
        case .post:
            if let url = URL(string: origin.appendingPathComponent(path).absoluteString) {
                request = URLRequest(url: url)
                request?.httpBody = urlComponents.query?.data(using: .utf8)
                request?.httpMethod = "POST"
            }
        case .get:
            fallthrough
        case .put:
            fallthrough
        case .delete:
            if let url = urlComponents.url {
                request = URLRequest(url: url)
            }
        }
        guard let r = request else {
            completion?(nil)
            return
        }
//        print(r.url)
//        print(parameters)
        URLSession.shared.dataTask(with: r) { data, response, error in
            completion?(data)
            }.resume()
    }
    
    func async(route: Route, parameters: [URLQueryItem] = [], completion: ((Data?) -> Void)? = nil) {
        guard let path = route.path else {
            return
        }
        async(path: path, method: route.method, parameters: parameters, completion: completion)
    }
    
    
}

import Foundation

struct HTTP {
    
    enum Method {
        case post
        case get
        case put
        case delete
    }
    
    enum FileUsage: String {
        case userProfileImage
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
    
    static let defaultOrigin = URL(string: "http://localhost:9000")!
    
    let origin: URL
    
    init(origin: URL = HTTP.defaultOrigin) {
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
    
    func upload(_ fileName: String, fileData: Data, fileUsage: FileUsage, completion: ((Data?) -> Void)? = nil) {
        let pathExtension = (fileName as NSString).pathExtension
        let boundary = "----WebKitFormBoundaryZLdHZy8HNaBmUX0d"
        var body = "--\(boundary)\r\n".data(using: .utf8)!
        body += "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
        body += "Content-Type: image/\(pathExtension)\r\n\r\n".data(using: .utf8)!
        body += fileData
        body += "\r\n".data(using: .utf8)!
        body += "--\(boundary)\r\n".data(using: .utf8)!
        body += "Content-Disposition: form-data; name=\"file_usage\"\r\n\r\n".data(using: .utf8)!
        body += "\(fileUsage.rawValue)\r\n".data(using: .utf8)!
        body += "--\(boundary)\r\n".data(using: .utf8)!
        body += "Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!
        switch fileUsage {
        case .userProfileImage:
            if let userId = Auth.shared.user?.id {
                body += String(userId).data(using: .utf8)!
            }
        }
        let url = origin.appendingPathComponent("api").appendingPathComponent("upload")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let urlConfig = URLSessionConfiguration.default
        urlConfig.httpAdditionalHeaders = headers
        let session = URLSession(configuration: urlConfig)
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            completion?(data)
        }
        task.resume()
//        func upload() {
////            let fileName = "menu-button.png"
////            let fileNameWithoutExt = (fileName as NSString).deletingPathExtension
////            //        let ext = (fileName as NSString).pathExtension
////            // UIImageからJPEGに変換してアップロード
////            //let imageData = UIImageJPEGRepresentation(UIImage(named: fileName)!, 1.0)!
////            // 読み込んだJPEGファイルをそのままアップロード
////            let imageData = UIImage(named: fileNameWithoutExt)!.pngData()!
//            //let body = httpBody(imageData, fileName: fileName)
//            let url = URL(string: "http://localhost:8000/api/upload")!
//
//            fileUpload(url, data: body) {(data, response, error) in
//                if let response = response as? HTTPURLResponse, let data: Data = data , error == nil {
//                    if response.statusCode == 200 {
//                        print("Upload done")
//                        print(String(data: data, encoding: .utf8))
//                    } else {
//                        print(response.statusCode)
//                    }
//                }
//            }
//        }
//
//        func httpBody(_ fileAsData: Data, fileName: String) -> Data {
////            var data = "--\(boundary)\r\n".data(using: .utf8)!
////            data += "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
////            data += "Content-Type: image/png\r\n\r\n".data(using: .utf8)!
////            data += fileAsData
////            data += "\r\n".data(using: .utf8)!
////            data += "--\(boundary)\r\n".data(using: .utf8)!
////            data += "Content-Disposition: form-data; name=\"file_usage\"\r\n\r\n".data(using: .utf8)!
////            data += "userProfileImage\r\n".data(using: .utf8)!
////            data += "--\(boundary)\r\n".data(using: .utf8)!
////            data += "Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!
////            data += "1".data(using: .utf8)!
//            //data += "\r\n".data(using: .utf8)!
//            //        data += "--\(boundary)\r\n".data(using: .utf8)!
//            //        data += "\r\n".data(using: .utf8)!
//            //        data += "--\(boundary)--\r\n".data(using: .utf8)!
//            //        data += "Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!
//            //        data += "341".data(using: .utf8)!
//
//            //print(String(data: data, encoding: .utf8))
//
//            return data
//        }
        
//        // リクエストを生成してアップロード
//        func fileUpload(_ url: URL, data: Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            // マルチパートでファイルアップロード
//            let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
//            let urlConfig = URLSessionConfiguration.default
//            urlConfig.httpAdditionalHeaders = headers
//
//            let session = Foundation.URLSession(configuration: urlConfig)
//            let task = session.uploadTask(with: request, from: data, completionHandler: completionHandler)
//            task.resume()
//        }
    }
    
    
}

import Foundation

class Auth {
    
    static let shared = Auth()
    
    private static let userIdKey = "AUTH_USER_ID"
    
    private(set) var user: User?
    
    func register(userName: String, emailAddress: String, password: String, completion: ((Int?) -> Void)? = nil) {
        guard !isLoggedIn() else {
            return
        }
        let parameters = [
            URLQueryItem(name: "name", value: userName),
            URLQueryItem(name: "email", value: emailAddress),
            URLQueryItem(name: "password", value: password),
        ]
        HTTP().async(route: .init(api: .register), parameters: parameters) { response in
            var userId: Int?
            defer {
                completion?(userId)
            }
            guard let response = response else {
                return
            }
            guard let string = String(data: response, encoding: .utf8) else {
                return
            }
            userId = Int(string)
        }
    }
    
    func login(userId: Int) {
        guard !isLoggedIn() else {
            return
        }
        UserDefaults.standard.set(userId, forKey: Auth.userIdKey)
        fetchUser()
    }
    
    func login(emailAddress: String, password: String, completion: ((User?) -> Void)? = nil) {
        let parameters = [
            URLQueryItem(name: "email", value: emailAddress),
            URLQueryItem(name: "password", value: password)
        ]
        HTTP().async(route: .init(api: .login), parameters: parameters) { response in
            defer {
                completion?(self.user)
            }
            guard let response = response else {
                return
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            self.user = try? jsonDecoder.decode(User.self, from: response)
        }
    }
    
    func logout() {
        UserDefaults.standard.set(nil, forKey: Auth.userIdKey)
    }
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.value(forKey: Auth.userIdKey) != nil
    }
    
    private init() {
        let semaphore = DispatchSemaphore(value: 0)
        fetchUser() { _ in
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    private func fetchUser(completion: ((User?) -> Void)? = nil) {
        guard let userId = UserDefaults.standard.value(forKey: Auth.userIdKey) as? Int else {
            completion?(nil)
            return
        }
        let parameters = [
            URLQueryItem(name: "id", value: String(userId))
        ]
        HTTP().async(route: .init(resource: .users, name: .index), parameters: parameters) { response in
            defer {
                completion?(self.user)
            }
            guard let response = response else {
                return
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let users = try? jsonDecoder.decode([User].self, from: response) else {
                return
            }
            guard users.count == 1 else {
                return
            }
            self.user = users.first
        }
    }
    
}

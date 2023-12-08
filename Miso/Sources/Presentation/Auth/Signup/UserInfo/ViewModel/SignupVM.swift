import UIKit
import Moya
import RxSwift
import RxCocoa

class SignupVM {
    let authProvider = MoyaProvider<AuthAPI>()
    var authData: LoginResponse!
    
    static var accessToken = ""
}

extension SignupVM {
    
    func signupCompleted(email: String, password: String, passwordChekck: String) {
        
        authProvider.request(.login(email: email, password: password)) { response in
            
            switch response {
            case .success(let result):
                
                do {
                    self.authData = try result.map(LoginResponse.self)
                    
                    KeychainLocal.shared.deleteAccessToken()
                    
                    KeychainLocal.shared.saveAccessToken(self.authData.accessToken)
                    
                } catch(let err) {
                    print(String(describing: err))
                }
                let statusCode = result.statusCode
                
                switch statusCode{
                case 200..<300:
                    do {
                        let accessToken = try KeychainLocal.shared.fetchAccessToken()
                        print("Access Token: \(accessToken)")
                    } catch {
                        print("Error fetching access token: \(error)")
                    }
                case 400:
                    print("Login failed with status code: \(statusCode)")
                default:
                    print(statusCode)
                }
            case .failure(let err):
                print(String(describing: err))
            }
        }
    }
}


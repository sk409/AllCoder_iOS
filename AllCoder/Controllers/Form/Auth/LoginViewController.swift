import UIKit

class LoginViewController: FormViewController {
    
    private var emailAddressFormControlView: FormControlView?
    private var passwordFormControlView: FormControlView?
    
    private let loginButton = UIButton()
    private let registerButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        emailAddressFormControlView = appendFormControlView(labelText: "メールアドレス")
        emailAddressFormControlView?.textField.keyboardType = .emailAddress
        passwordFormControlView = appendFormControlView(labelText: "パスワード")
        passwordFormControlView?.textField.isSecureTextEntry = true
        loginButton.backgroundColor = .systemBlue
        loginButton.titleLabel?.font = .boldSmall
        loginButton.setTitle("ログイン", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.addTarget(self, action: #selector(onTouchUpInsideLoginButton(_:)), for: .touchUpInside)
        append(view: loginButton, frame: CGRect(
            x: formViewFrame.origin.x,
            y: formViewFrame.maxY + view.bounds.height * 0.05,
            width: formViewFrame.width,
            height: loginButton.sizeThatFits.height * 1.2
        ))
        registerButton.titleLabel?.font = .small
        registerButton.setTitle("アカウント作成", for: .normal)
        registerButton.setTitleColor(loginButton.backgroundColor, for: .normal)
        registerButton.addTarget(self, action: #selector(onTouchUpInsideRegisterButton(_:)), for: .touchUpInside)
        append(view: registerButton, frame: CGRect(
            x: formViewFrame.origin.x,
            y: loginButton.frame.maxY + view.bounds.height * 0.01,
            width: formViewFrame.width,
            height: registerButton.sizeThatFits.height * 1.2
        ))
    }
    
    @objc
    private func onTouchUpInsideLoginButton(_ sender: UIButton) {
        guard let emailAddress = emailAddressFormControlView?.textField.text,
              let password = passwordFormControlView?.textField.text
            else {
                return
        }
        Auth.shared.login(emailAddress: emailAddress, password: password) { user in
            DispatchQueue.main.async {
                guard let user = user else {
                    self.alert(title: "ログインに失敗しました", message: "サーバでエラーが発生しました")
                    return
                }
                self.alert(message: "ログインに成功しました") {
                    let dashboardTabBarViewController = DashboardTabBarController()
                    dashboardTabBarViewController.user = user
                    self.present(dashboardTabBarViewController, animated: true)
                }
            }
        }
    }
    
    @objc
    private func onTouchUpInsideRegisterButton(_ sender: UIButton) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        UIView.transition(with: window, duration: UIView.Animation.Duration.normal, options: [.transitionCurlUp], animations: {
            window.rootViewController = RegisterViewController()
        })
    }
    
    
}

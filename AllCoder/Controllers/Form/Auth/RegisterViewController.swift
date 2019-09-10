import UIKit

class RegisterViewController: FormViewController {
    
    private var userNameFormControlView: FormControlView?
    private var emailAddressFormControlView: FormControlView?
    private var passwordFormControlView: FormControlView?
    private var passwordConfirmationFormControlView: FormControlView?
    
    private let registerButton = UIButton(type: .system)
    private let haveAccountButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        userNameFormControlView = appendFormControlView(labelText: "名前")
        emailAddressFormControlView = appendFormControlView(labelText: "メールアドレス")
        emailAddressFormControlView?.textField.keyboardType = .emailAddress
        passwordFormControlView = appendFormControlView(labelText: "パスワード")
        passwordFormControlView?.textField.isSecureTextEntry = true
        passwordConfirmationFormControlView = appendFormControlView(labelText: "パスワード確認")
        passwordConfirmationFormControlView?.textField.isSecureTextEntry = true
        registerButton.backgroundColor = .systemBlue
        registerButton.titleLabel?.font = .boldSmall
        registerButton.setTitle("登録", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.addTarget(self, action: #selector(onTouchUpInsideRegisterButton(_:)), for: .touchUpInside)
        append(view: registerButton, frame: CGRect(
            x: formViewFrame.origin.x,
            y: formViewFrame.maxY + view.safeAreaLayoutGuide.layoutFrame.height * 0.05,
            width: formViewFrame.width,
            height: registerButton.sizeThatFits.height * 1.2
        ))
        haveAccountButton.titleLabel?.font = .small
        haveAccountButton.setTitle("アカウントをお持ちの方", for: .normal)
        haveAccountButton.setTitleColor(registerButton.backgroundColor, for: .normal)
        haveAccountButton.addTarget(self, action: #selector(onTouchUpInsideHaveAccountButton(_:)), for: .touchUpInside)
        append(view: haveAccountButton, frame: CGRect(
            x: formViewFrame.origin.x,
            y: registerButton.frame.maxY + view.safeAreaLayoutGuide.layoutFrame.height * 0.01,
            width: formViewFrame.width,
            height: haveAccountButton.sizeThatFits.height * 1.2
        ))
    }
    
    @objc
    private func onTouchUpInsideRegisterButton(_ sender: UIButton) {
        var doesEmptyTextFieldExists = false
        let formControlViews = [userNameFormControlView, emailAddressFormControlView, passwordFormControlView, passwordConfirmationFormControlView]
        for formControlView in formControlViews {
            if let isEmpty = formControlView?.textField.text?.isEmpty, isEmpty {
                doesEmptyTextFieldExists = true
                formControlView?.showFeedback(text: "この項目を入力してください", type: .error)
            }
        }
        let alertErrorTitle = "登録に失敗しました"
        guard !doesEmptyTextFieldExists else {
            alert(title: alertErrorTitle, message: "未入力の項目があります")
            return
        }
        guard let userName = userNameFormControlView?.textField.text,
              let emailAddress = emailAddressFormControlView?.textField.text,
              let password = passwordFormControlView?.textField.text,
              let passwordConfirmation = passwordConfirmationFormControlView?.textField.text
            else {
                return
        }
        guard password == passwordConfirmation else {
            alert(title: alertErrorTitle, message: "確認用パスワードが一致していません。")
            return
        }
        Auth.shared.register(userName: userName, emailAddress: emailAddress, password: password) { user in
            DispatchQueue.main.async {
                guard let user = user else {
                    self.alert(title: alertErrorTitle, message: "登録時にエラーが発生しました")
                    return
                }
                self.alert(message: "登録に成功しました") {
                    let dashboardTabBarController = DashboardTabBarController()
                    dashboardTabBarController.user = user
                    self.present(dashboardTabBarController, animated: true)
                }
            }
        }
    }
    
    @objc
    private func onTouchUpInsideHaveAccountButton(_ sender: UIButton) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        UIView.transition(with: window, duration: UIView.Animation.Duration.normal, options: [.transitionCurlDown], animations: {
            window.rootViewController = LoginViewController()
        })
    }
    
    
}


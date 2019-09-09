import UIKit

class HomeViewController: UIViewController {
    
    private let purchasedMaterialsTableView = PurchasedMaterialsTableView()
    private let createdMaterialsTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMaterials()
        setupViews()
    }
    
    private func fetchMaterials() {
        let parameters = [
            URLQueryItem(name: "user_id", value: "1"),
            URLQueryItem(name: "purchased", value: nil),
        ]
        HTTP().async(route: .init(resource: .materials, name: .index, options: [.api]), parameters: parameters) { response in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            DispatchQueue.main.async {
                self.purchasedMaterialsTableView.materials = try! jsonDecoder.decode([Material].self, from: response)
            }
        }
    }
    
    private func setupViews() {
        let tabBarView = TabBarView()
        view.addSubview(tabBarView)
        tabBarView.set(contentViews: ["購入した教材": purchasedMaterialsTableView, "作成した教材": createdMaterialsTableView])
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
//        let profileContainerView = UIView()
//        view.addSubview(scrollView)
//        scrollView.addSubview(profileView)
//        profileView.addSubview(profileContainerView)
//        profileContainerView.addSubview(profileImageView)
//        profileContainerView.addSubview(nameLabel)
//        profileContainerView.addSubview(bioTextView)
//        profileContainerView.addSubview(followingsButton)
//        profileContainerView.addSubview(followersButton)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            ])
//        profileContainerView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            profileContainerView.centerXAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.centerXAnchor),
//            profileContainerView.centerYAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.centerYAnchor),
//            profileContainerView.widthAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
//            profileContainerView.heightAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.9),
//            ])
//        profileImageView.backgroundColor = .orange
//        profileImageView.contentMode = .scaleAspectFit
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            profileImageView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor),
//            profileImageView.topAnchor.constraint(equalTo: profileContainerView.topAnchor),
//            profileImageView.widthAnchor.constraint(equalTo: profileContainerView.widthAnchor, multiplier: 0.4),
//            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
//            ])
    }
    
//    private func layoutViews() {
//        profileView.backgroundColor = .red
//        profileView.frame = CGRect(
//            origin: .zero,
//            size: CGSize(width: view.bounds.width, height: view.bounds.height * 0.4)
//        )
//    }
    
}

fileprivate class ProgressBarView: UIView {
    
    let barContainerView = UIView()
    let barView = UIView()
    let countUpLabel = UILabel()
    
    private var progress: CGFloat = 0
    private var animationDuration: TimeInterval?
    private var animationCompletion: (() -> Void)?
    private var timer: Timer?
    
    private var percentage: Int {
        return Int(floor(progress * 100))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        barContainerView.frame.size.width = bounds.size.width - countUpLabel.bounds.width
        barContainerView.frame.size.height = safeAreaLayoutGuide.layoutFrame.height
        barView.frame.size.height = safeAreaLayoutGuide.layoutFrame.height
        let scaling = {
            self.barView.frame.size.width = (self.bounds.width - self.countUpLabel.bounds.width) * self.progress
        }
        if let animationDuration = animationDuration {
            let precentage = self.percentage
            timer = Timer.scheduledTimer(withTimeInterval: animationDuration / TimeInterval(precentage), repeats: true, block: { _ in
                let _ = self.countUpLabel.text?.removeLast()
                guard let current = Int(self.countUpLabel.text ?? "0") else {
                    return
                }
                if current == precentage {
                    self.countUpLabel.text = String(current) + "%"
                    self.timer?.invalidate()
                } else {
                    self.countUpLabel.text = String(current + 1) + "%"
                }
            })
            UIView.animate(withDuration: animationDuration, animations: {
                scaling()
            }) { _ in
                self.animationCompletion?()
            }
        } else {
            self.countUpLabel.text = String(percentage) + "%"
            scaling()
        }
    }
    
    func set(
        progress: CGFloat,
        animationDuration: TimeInterval? = nil,
        animationCompletion: (() -> Void)? = nil
        ) {
        self.progress = progress
        self.progress = min(1, max(0, self.progress))
        self.animationDuration = animationDuration
        self.animationCompletion = animationCompletion
    }
    
    private func setupViews() {
        addSubview(barContainerView)
        addSubview(countUpLabel)
        barContainerView.addSubview(barView)
        countUpLabel.text = "0%"
        countUpLabel.font = .small
        countUpLabel.textAlignment = .right
        countUpLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countUpLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            countUpLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            countUpLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            countUpLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            ])
    }
    
}

fileprivate class PurchasedMaterialTableViewCell: UITableViewCell {
    
    static let className = "PurchasedMaterialTableViewCell"
    
    var material: Material? {
        didSet {
            guard let material = material else {
                return
            }
            titleLabel.text = material.title
        }
    }
    
    let progressBarView = ProgressBarView()
    
    private let titleLabel = UILabel()
    private let detailsButton = UIButton()
    private let startButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        let containerView = UIView()
        let separatorView = UIView()
        let footerView = UIView()
        let footerLeftView = UIView()
        let footerRightView = UIView()
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(separatorView)
        containerView.addSubview(progressBarView)
        containerView.addSubview(detailsButton)
        containerView.addSubview(startButton)
        containerView.addSubview(footerView)
        footerView.addSubview(footerLeftView)
        footerView.addSubview(footerRightView)
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.8),
            ])
        titleLabel.font = .boldSmall
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
            titleLabel.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
            ])
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            ])
        progressBarView.barView.backgroundColor = .systemGreen
        progressBarView.barContainerView.layer.borderColor = UIColor.black.cgColor
        progressBarView.barContainerView.layer.borderWidth = 1
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBarView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
            progressBarView.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor),
            progressBarView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            progressBarView.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
            ])
        footerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            footerView.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
            ])
        footerLeftView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerLeftView.leadingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.leadingAnchor),
            footerLeftView.trailingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.centerXAnchor),
            footerLeftView.topAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.topAnchor),
            footerLeftView.bottomAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.bottomAnchor),
            ])
        detailsButton.titleLabel?.font = .boldSmall
        detailsButton.backgroundColor = .systemBlue
        detailsButton.setTitle("詳細", for: .normal)
        detailsButton.setTitleColor(.white, for: .normal)
        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailsButton.centerXAnchor.constraint(equalTo: footerLeftView.safeAreaLayoutGuide.centerXAnchor),
            detailsButton.centerYAnchor.constraint(equalTo: footerLeftView.safeAreaLayoutGuide.centerYAnchor),
            detailsButton.widthAnchor.constraint(equalTo: startButton.widthAnchor),
            detailsButton.heightAnchor.constraint(equalTo: startButton.heightAnchor),
            ])
        footerRightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerRightView.leadingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.centerXAnchor),
            footerRightView.trailingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.trailingAnchor),
            footerRightView.topAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.topAnchor),
            footerRightView.bottomAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.bottomAnchor),
            ])
        startButton.backgroundColor = detailsButton.backgroundColor
        startButton.titleLabel?.font = detailsButton.titleLabel?.font
        startButton.setTitle("始める", for: .normal)
        startButton.setTitleColor(detailsButton.titleColor(for: .normal), for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.centerYAnchor),
            startButton.widthAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),
            startButton.heightAnchor.constraint(equalTo: startButton.widthAnchor, multiplier: 0.5),
            ])
    }
    
}

fileprivate class PurchasedMaterialsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var materials = [Material]() {
        didSet {
            reloadData()
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materials.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchasedMaterialTableViewCell.className) as? PurchasedMaterialTableViewCell else {
            return UITableViewCell()
        }
        cell.material = materials[indexPath.row]
        cell.progressBarView.set(progress: 0.76, animationDuration: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    private func setupViews() {
        dataSource = self
        delegate = self
        separatorStyle = .none
        tableFooterView = UIView()
        register(PurchasedMaterialTableViewCell.self, forCellReuseIdentifier: PurchasedMaterialTableViewCell.className)
    }
    
}

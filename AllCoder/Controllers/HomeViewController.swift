import UIKit

class HomeViewController: UIViewController {
    
    var userId: Int?
    
    private var user: User?
    private let purchasedMaterialsTableView = PurchasedMaterialsTableView()
    private let curtainView = CurtainView()
    private let createdMaterialsTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUser()
    }
    
    private func fetchUser() {
        guard let userId = userId else {
            return
        }
        let parameters = [
            URLQueryItem(name: "id", value: String(userId))
        ]
        HTTP().async(route: .init(resource: .users, name: .index), parameters: parameters) { response in
            guard let response = response else {
                return
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            self.user = (try? jsonDecoder.decode([User].self, from: response))?.first
            self.purchasedMaterialsTableView.materials = self.user?.purchasedMaterials
            self.purchasedMaterialsTableView.lessonCompletions = self.user?.lessonCompletions
            DispatchQueue.main.async {
                self.purchasedMaterialsTableView.reloadData()
            }
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        fetchMaterials()
//    }
    
//    private func fetchMaterials() {
//        guard let user = user else {
//            return
//        }
//        let parameters = [
//            URLQueryItem(name: "user_id", value: String(user.id)),
//            URLQueryItem(name: "purchased", value: nil),
//        ]
//        HTTP().async(route: .init(resource: .materials, name: .index), parameters: parameters) { response in
//            guard let response = response else {
//                return
//            }
//            let jsonDecoder = JSONDecoder()
//            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//            DispatchQueue.main.async {
//                self.purchasedMaterialsTableView.materials = try! jsonDecoder.decode([Material].self, from: response)
//            }
//        }
//    }
    
    private func setupViews() {
        let tabBarView = TabBarView()
        view.addSubview(tabBarView)
        view.addSubview(curtainView)
        tabBarView.set(contentViews: ["購入した教材": purchasedMaterialsTableView, "作成した教材": createdMaterialsTableView])
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        purchasedMaterialsTableView.onSelectCell = { material in
            let materialDetailsView = MaterialDetailsView()
            materialDetailsView.material = material
            materialDetailsView.transitionToLessonViewController = { lesson in
                let lessonViewController = LessonViewController()
                lessonViewController.lesson = lesson
                self.present(lessonViewController, animated: true)
            }
            self.curtainView.contentView = materialDetailsView
            //self.curtainView.frame.origin.x = self.view.safeAreaInsets.left
            self.curtainView.frame.origin.y = self.view.safeAreaInsets.top
            self.curtainView.frame.size.width = self.view.safeAreaLayoutGuide.layoutFrame.width
            self.curtainView.frame.size.height = self.view.safeAreaLayoutGuide.layoutFrame.height
            self.curtainView.slideIn()
        }
//        purchasedMaterialsTableView.detailsButtonHandler = { material in
//
//        }
//        purchasedMaterialsTableView.startButtonHandler = { material in
//            guard let lessonCompletions = self.user?.lessonCompletions.filter({ $0.materialId == material.id })
//            else {
//                return
//            }
//            let lessons = material.lessons.sorted { $0.index < $1.index }
//            if let nextLesson = lessons.first(where: { lesson in
//                return !lessonCompletions.contains { $0.lessonId == lesson.id }
//            }) {
//                let lessonViewController = LessonViewController()
//                lessonViewController.lesson = nextLesson
//                self.present(lessonViewController, animated: true)
//            } else {
//
//            }
//        }
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
    
//    let detailsButton = IndexPathButton()
//    let startButton = IndexPathButton()
    
    private let titleLabel = UILabel()
    private let progressLabel = UILabel()
    private let progressBarView = ProgressBarView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setProgress(lessonCompletionCount: Int, lessonCount: Int) {
        guard 0 < lessonCount else {
            return
        }
        progressLabel.text = String(lessonCompletionCount) + "/" + String(lessonCount) + "レッスン"
        progressBarView.set(
            progress: CGFloat(lessonCompletionCount) / CGFloat(lessonCount),
            animationDuration: 1
        )
    }
    
    private func setupViews() {
        let containerView = UIView()
        let separatorView = UIView()
//        let footerView = UIView()
//        let footerLeftView = UIView()
//        let footerRightView = UIView()
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(separatorView)
        containerView.addSubview(progressLabel)
        containerView.addSubview(progressBarView)
//        containerView.addSubview(detailsButton)
//        containerView.addSubview(startButton)
//        containerView.addSubview(footerView)
//        footerView.addSubview(footerLeftView)
//        footerView.addSubview(footerRightView)
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
        progressLabel.font = .small
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: progressBarView.topAnchor),
            progressLabel.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor),
            progressLabel.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
            ])
        progressBarView.barView.backgroundColor = .systemGreen
        progressBarView.barContainerView.layer.borderColor = UIColor.black.cgColor
        progressBarView.barContainerView.layer.borderWidth = 1
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBarView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
            progressBarView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -UIFont.tiny.pointSize),
            progressBarView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            progressBarView.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
            ])
//        footerView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            footerView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
//            footerView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor),
//            footerView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
//            footerView.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
//            ])
//        footerLeftView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            footerLeftView.leadingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.leadingAnchor),
//            footerLeftView.trailingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.centerXAnchor),
//            footerLeftView.topAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.topAnchor),
//            footerLeftView.bottomAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.bottomAnchor),
//            ])
//        detailsButton.titleLabel?.font = .boldSmall
//        detailsButton.backgroundColor = .systemBlue
//        detailsButton.setTitle("詳細", for: .normal)
//        detailsButton.setTitleColor(.white, for: .normal)
//        detailsButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            detailsButton.centerXAnchor.constraint(equalTo: footerLeftView.safeAreaLayoutGuide.centerXAnchor),
//            detailsButton.centerYAnchor.constraint(equalTo: footerLeftView.safeAreaLayoutGuide.centerYAnchor),
//            detailsButton.widthAnchor.constraint(equalTo: startButton.widthAnchor),
//            detailsButton.heightAnchor.constraint(equalTo: startButton.heightAnchor),
//            ])
//        footerRightView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            footerRightView.leadingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.centerXAnchor),
//            footerRightView.trailingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.trailingAnchor),
//            footerRightView.topAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.topAnchor),
//            footerRightView.bottomAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.bottomAnchor),
//            ])
//        startButton.backgroundColor = detailsButton.backgroundColor
//        startButton.titleLabel?.font = detailsButton.titleLabel?.font
//        startButton.setTitle("始める", for: .normal)
//        startButton.setTitleColor(detailsButton.titleColor(for: .normal), for: .normal)
//        startButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            startButton.centerXAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.centerXAnchor),
//            startButton.centerYAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.centerYAnchor),
//            startButton.widthAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),
//            startButton.heightAnchor.constraint(equalTo: startButton.widthAnchor, multiplier: 0.5),
//            ])
    }
    
}



fileprivate class PurchasedMaterialsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var materials: [Material]?
    var lessonCompletions: [LessonCompletion]?
    var onSelectCell: ((Material) -> Void)?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materials?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchasedMaterialTableViewCell.className) as? PurchasedMaterialTableViewCell else {
            return UITableViewCell()
        }
        guard let materials = materials else {
            return UITableViewCell()
        }
        guard let lessonCompletions = lessonCompletions else {
            return UITableViewCell()
        }
        let material = materials[indexPath.row]
        let lessonCount = material.lessons.count
        let lessonCompletionCount = lessonCompletions.filter { $0.materialId == material.id }.count
//        let selectedView = UIView()
//        selectedView.backgroundColor = .clear
//        cell.selectedBackgroundView = selectedView
        cell.material = material
//        cell.detailsButton.indexPath = indexPath
//        cell.detailsButton.addTarget(self, action: #selector(onTouchUpInsideDetailsButton(_:)), for: .touchUpInside)
//        cell.startButton.indexPath = indexPath
//        cell.startButton.addTarget(self, action: #selector(onTouchUpInsideStartButton(_:)), for: .touchUpInside)
        cell.setProgress(lessonCompletionCount: lessonCompletionCount, lessonCount: lessonCount)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        return nil
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let materials = materials else {
            return
        }
        onSelectCell?(materials[indexPath.row])
    }
    
    private func setupViews() {
        dataSource = self
        delegate = self
        separatorStyle = .none
        tableFooterView = UIView()
        register(PurchasedMaterialTableViewCell.self, forCellReuseIdentifier: PurchasedMaterialTableViewCell.className)
    }
    
//    @objc
//    private func onTouchUpInsideDetailsButton(_ sender: IndexPathButton) {
//        guard let materials = materials else {
//            return
//        }
//        guard let indexPath = sender.indexPath else {
//            return
//        }
//        detailsButtonHandler?(materials[indexPath.row])
//    }
//
//    @objc
//    private func onTouchUpInsideStartButton(_ sender: IndexPathButton) {
//        guard let materials = materials else {
//            return
//        }
//        guard let indexPath = sender.indexPath else {
//            return
//        }
//        startButtonHandler?(materials[indexPath.row])
//    }
    
}


fileprivate class MaterialDetailsView: UIView {
    
    private class LessonButton: UIButton {
        var lesson: Lesson?
    }
    
    var material: Material? {
        didSet {
            titleLabel.text = material?.title
            descriptionTextView.text = material?.description
            lessonsAccordionView.reloadData()
        }
    }
    var lessonCompletions: [LessonCompletion]?
    var transitionToLessonViewController: ((Lesson) -> Void)?
    
    private let scrollView = UIScrollView()
    private let headerView = UIView()
    private let separatorView1 = UIView()
    private let bodyView = UIView()
    private let separatorView2 = UIView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let lessonsAccordionView = AccordionView()
    
    
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
        layoutViews()
        lessonsAccordionView.reloadData()
    }
    
    private func setupViews() {
        backgroundColor = .white
        let headerContainerView = UIView()
        addSubview(scrollView)
        scrollView.addSubview(headerView)
        scrollView.addSubview(separatorView1)
        scrollView.addSubview(bodyView)
        scrollView.addSubview(separatorView2)
        scrollView.addSubview(lessonsAccordionView)
        headerView.addSubview(headerContainerView)
        headerContainerView.addSubview(thumbnailImageView)
        headerContainerView.addSubview(titleLabel)
        bodyView.addSubview(descriptionTextView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            ])
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerContainerView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerContainerView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerContainerView.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.8),
            headerContainerView.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.8),
            ])
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.leadingAnchor),
            thumbnailImageView.centerYAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            thumbnailImageView.heightAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.heightAnchor),
            ])
        titleLabel.font = .boldMedium
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: UIFont.tiny.pointSize),
            titleLabel.topAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.topAnchor),
            ])
        separatorView1.backgroundColor = .lightGray
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.font = .small
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextView.leadingAnchor.constraint(equalTo: bodyView.safeAreaLayoutGuide.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: bodyView.safeAreaLayoutGuide.trailingAnchor),
            descriptionTextView.topAnchor.constraint(equalTo: bodyView.safeAreaLayoutGuide.topAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: bodyView.safeAreaLayoutGuide.bottomAnchor),
            ])
        separatorView2.backgroundColor = separatorView1.backgroundColor
        lessonsAccordionView.dataSource = self
        lessonsAccordionView.delegate = self
    }
    
    private func layoutViews() {
        headerView.frame.origin = .zero
        headerView.frame.size.width = scrollView.bounds.width
        headerView.frame.size.height = scrollView.bounds.height * 0.4
        separatorView1.frame.origin.x = 0
        separatorView1.frame.origin.y = headerView.frame.maxY
        separatorView1.frame.size.width = scrollView.bounds.width
        separatorView1.frame.size.height = UIFont.tiny.pointSize * 0.1
        bodyView.frame.origin.x = 0
        bodyView.frame.origin.y = separatorView1.frame.maxY
        bodyView.frame.size.width = scrollView.bounds.width
        bodyView.frame.size.height = scrollView.bounds.height * 0.4
        separatorView2.frame.origin.x = 0
        separatorView2.frame.origin.y = bodyView.frame.maxY
        separatorView2.frame.size.width = scrollView.bounds.width
        separatorView2.frame.size.height = separatorView1.bounds.height
        lessonsAccordionView.frame.origin.x = 0
        lessonsAccordionView.frame.origin.y = bodyView.frame.maxY
        lessonsAccordionView.frame.size.width = scrollView.bounds.width
        lessonsAccordionView.frame.size.height = lessonsAccordionView.height
        scrollView.contentSize.width = scrollView.bounds.width
        scrollView.contentSize.height = lessonsAccordionView.frame.maxY
    }
    
    @objc
    private func onTouchUpInsideLessonButton(_ sender: LessonButton) {
        guard let lesson = sender.lesson else {
            return
        }
        transitionToLessonViewController?(lesson)
    }
    
}

extension MaterialDetailsView: AccordionViewDataSource, AccordionViewDelegate {
    
    
    func accordionViewNumberOfItems(_ accordionView: AccordionView) -> Int {
        return material?.lessons.count ?? 0
    }
    
    func accordionView(_ accordionView: AccordionView, headerViewForItemAt item: Int) -> UIView {
        let containerView = UIView()
        let lessonButton = LessonButton(type: .system)
        containerView.addSubview(lessonButton)
        lessonButton.titleLabel?.font = .boldMedium
        lessonButton.setTitle(material?.lessons[item].title, for: .normal)
        lessonButton.lesson = material?.lessons[item]
        lessonButton.addTarget(self, action: #selector(onTouchUpInsideLessonButton(_:)), for: .touchUpInside)
        lessonButton.translatesAutoresizingMaskIntoConstraints = false
        let fitSize = lessonButton.fitSize
        NSLayoutConstraint.activate([
            lessonButton.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
            lessonButton.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor),
            lessonButton.widthAnchor.constraint(equalToConstant: max(44,fitSize.width * 1.5)),
            lessonButton.heightAnchor.constraint(equalToConstant: max(44, fitSize.height * 1.5) ),
            ])
        return containerView
    }
    
    func accordionView(_ accordionView: AccordionView, bodyViewForItemAt item: Int) -> UIView {
        let descriptionTextView = UITextView()
        descriptionTextView.font = .small
        descriptionTextView.text = material?.lessons[item].description
        return descriptionTextView
    }
    
    func accordionView(_ accordionView: AccordionView, headerViewHeightForItemAt item: Int, headerView: UIView) -> CGFloat {
        return UIFont.tiny.pointSize * 4
    }
    
    func accordionView(_ accordionView: AccordionView, bodyViewHeightForItemAt item: Int, bodyView: UIView) -> CGFloat {
        return bodyView.fitSize.height
    }
    
    func accordionView(_ accordionView: AccordionView, toggleButtonForItemAt item: Int) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "plus-button"), for: .normal)
        return button
    }
    
    func accordionView(_ accordionView: AccordionView, didToggle headerView: UIView, bodyView: UIView, toggleButton: UIButton, open: Bool) {
        toggleButton.setImage(UIImage(named: open ? "minus-button" : "plus-button"), for: .normal)
    }
    
    func accordionView(_ accordionView: AccordionView, toggleButtonPositionIn headerView: UIView, forItemAt item: Int, toggleButton: UIButton) -> CGPoint {
        let headerViewHeight = self.accordionView(accordionView, headerViewHeightForItemAt: item, headerView: headerView)
        let buttonSize = self.accordionView(accordionView, toggleButtonSizeForItemAt: item, toggleButton: toggleButton)
        let originX = accordionView.bounds.width - buttonSize.width - UIFont.tiny.pointSize
        let originY = (headerViewHeight / 2) - (buttonSize.height / 2)
        return CGPoint(x: originX, y: originY)
    }
    
    func accordionView(_ accordionView: AccordionView, toggleButtonSizeForItemAt item: Int, toggleButton: UIButton) -> CGSize {
        let buttonSize = max(44, UIFont.tiny.pointSize)
        return CGSize(width: buttonSize, height: buttonSize)
    }
    
    func accordionView(_ accordionView: AccordionView, DidChangeHeight height: CGFloat) {
        lessonsAccordionView.frame.size.height = height
        scrollView.contentSize.height = lessonsAccordionView.frame.maxY
    }
    
}

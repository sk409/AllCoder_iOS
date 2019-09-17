import Photos
import UIKit

class HomeViewController: UIViewController {
    
    var userId: Int?
    
    private var user: User?
    private var profileViewTrailingConstraint: NSLayoutConstraint?
    private let tabBarView = TabBarView()
    private let purchasedMaterialsTableView = PurchasedMaterialsTableView()
    private let curtainView = CurtainView()
    private let createdMaterialsTableView = UITableView()
    private let profileImageButton = UIButton()
    private let profileView = UserProfileView()
    
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
            var profileImage: UIImage?
            if let profileImagePath = self.user?.profileImagePath,
                let profileImageData = try? Data(contentsOf: HTTP.defaultOrigin.appendingPathComponent(profileImagePath))
            {
                profileImage = UIImage(data: profileImageData)
            } else {
                profileImage = UIImage(named: "no-image")
            }
            DispatchQueue.main.async {
                self.purchasedMaterialsTableView.reloadData()
                self.profileImageButton.setImage(profileImage, for: .normal)
                self.profileView.profileImageView.image = profileImage
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
        view.addSubview(tabBarView)
        view.addSubview(curtainView)
        view.addSubview(profileImageButton)
        view.addSubview(profileView)
        tabBarView.set(contentViews: ["購入した教材": purchasedMaterialsTableView, "作成した教材": createdMaterialsTableView])
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: profileView.trailingAnchor),
            tabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBarView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
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
            self.curtainView.frame.origin.y = self.view.safeAreaInsets.top
            self.curtainView.frame.size.width = self.view.safeAreaLayoutGuide.layoutFrame.width
            self.curtainView.frame.size.height = self.view.safeAreaLayoutGuide.layoutFrame.height
            self.curtainView.slideIn()
        }
        let profileImageButtonSize = max(44, UIFont.tiny.pointSize * 2)
        profileImageButton.contentMode = .scaleAspectFill
        profileImageButton.clipsToBounds = true
        profileImageButton.layer.cornerRadius = profileImageButtonSize / 2
        profileImageButton.addTarget(self, action: #selector(onTouchUpInsideProfileImageButton(_:)), for: .touchUpInside)
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIFont.tiny.pointSize),
            profileImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIFont.tiny.pointSize),
            profileImageButton.widthAnchor.constraint(equalToConstant: profileImageButtonSize),
            profileImageButton.heightAnchor.constraint(equalTo: profileImageButton.widthAnchor),
            ])
        profileView.onTapProfileImageView = {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            let alertController = UIAlertController(title: nil, message: "ソースを選択してください", preferredStyle: .actionSheet)
            let presentImagePirckerController: (UIImagePickerController.SourceType) -> Void = { sourceType in
                guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                    return
                }
                imagePickerController.sourceType = sourceType
                self.present(imagePickerController, animated: true)
            }
            alertController.addAction(UIAlertAction(title: "カメラ", style: .default) { _ in
                presentImagePirckerController(.camera)
            })
            alertController.addAction(UIAlertAction(title: "ライブラリ", style: .default) { _ in
                presentImagePirckerController(.photoLibrary)
            })
            alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            self.present(alertController, animated: true)
        }
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileViewTrailingConstraint = profileView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        NSLayoutConstraint.activate([
            profileViewTrailingConstraint!,
            profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            profileView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            ])
    }
    
    private func hideProfileView(
        animationDuration: TimeInterval = UIView.Animation.Duration.fast,
        completion: ((Bool) -> Void)? = nil
    ) {
        profileViewTrailingConstraint?.constant = 0
        tabBarView.removeBlackout(duration: animationDuration)
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }) { finished in
            completion?(finished)
        }
    }
    
    @objc
    private func onTouchUpInsideProfileImageButton(_ sender: UIButton) {
        guard let constant = profileViewTrailingConstraint?.constant,
              constant == 0
        else {
            return
        }
        let animationDuration = UIView.Animation.Duration.fast
        profileViewTrailingConstraint?.constant = profileView.bounds.width
        let blackoutView = tabBarView.addBlackout(duration: animationDuration)
        blackoutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapBlackoutView(_:))))
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func onTapBlackoutView(_ sender: UITapGestureRecognizer) {
        let animationDuration = UIView.Animation.Duration.fast
        profileViewTrailingConstraint?.constant = 0
        tabBarView.removeBlackout(duration: animationDuration)
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
}


extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.pngData()
//            ,
//              let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset,
//              let fileName = PHAssetResource.assetResources(for: asset).first?.originalFilename
        else {
            return
        }
        //print(imageData)
        //profileImageButton.setima
        HTTP().upload("TTTTT.png", fileData: imageData, fileUsage: .userProfileImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
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
//        headerView.frame.size = bounds.size
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerContainerView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerContainerView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerContainerView.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.8),
            headerContainerView.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.8),
            ])
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.image = UIImage(named: "no-image")
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.leadingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.topAnchor),
            thumbnailImageView.widthAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            thumbnailImageView.heightAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.heightAnchor),
            ])
        titleLabel.font = .boldSmall
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: UIFont.tiny.pointSize),
//            titleLabel.trailingAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.trailingAnchor),
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
        lessonButton.titleLabel?.font = .boldTiny
        lessonButton.setTitle(material?.lessons[item].title, for: .normal)
        lessonButton.lesson = material?.lessons[item]
        lessonButton.addTarget(self, action: #selector(onTouchUpInsideLessonButton(_:)), for: .touchUpInside)
        lessonButton.translatesAutoresizingMaskIntoConstraints = false
        let fitSize = lessonButton.fitSize
        NSLayoutConstraint.activate([
            lessonButton.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
            lessonButton.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor),
            lessonButton.widthAnchor.constraint(equalToConstant: max(44,fitSize.width * 1.5)),
            lessonButton.heightAnchor.constraint(equalToConstant: max(44, fitSize.height * 1.5)),
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


fileprivate class UserProfileView: UIView {
    
    var onTapProfileImageView: (() -> Void)?
    
    let profileImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        let headerView = UIView()
        addSubview(headerView)
        headerView.addSubview(profileImageView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
            ])
        let profileImageViewSize = max(44, UIFont.tiny.pointSize * 3)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageViewSize / 2
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapProfileImageView(_:))))
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: UIFont.tiny.pointSize),
            profileImageView.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: UIFont.tiny.pointSize),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize),
            ])
    }
    
    @objc
    private func onTapProfileImageView(_ sender: UITapGestureRecognizer) {
        onTapProfileImageView?()
    }
    
}

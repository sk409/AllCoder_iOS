import KRProgressHUD
import UIKit

class MaterialSearchViewController: UIViewController {
    
    var user: User?
    
    //private var materialPurchaseViewLeadingConstraint: NSLayoutConstraint?
    //private let panGestureRecognizer = UIPanGestureRecognizer()
    private let curtainView = CurtainView()
    private let materialPurchaseView = MaterialPurchaseView()
    private let materialsScrollView = MaterialsScrollView()
    private let materialPurchaseConfirmationAlertView = MaterialPurchaseConfirmationAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMaterials()
        setupViews()
        //setupGestureRecognizers()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        let headerView = UIView()
        view.addSubview(headerView)
        view.addSubview(materialsScrollView)
        curtainView.hiddenView = view
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            ])
        materialsScrollView.insets = UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)
        materialsScrollView.interitemSpacing = 16
        materialsScrollView.lineSpacing = 16
        materialsScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            materialsScrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            materialsScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            materialsScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            materialsScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            ])
        curtainView.contentView = materialPurchaseView
        curtainView.panGestureRecognizer.delegate = self
        materialPurchaseView.purchaseButton.addTarget(self, action: #selector(onTouchUpInsidePurchaseButton(_:)), for: .touchUpInside)
//        materialPurchaseView.translatesAutoresizingMaskIntoConstraints = false
//        materialPurchaseViewLeadingConstraint = materialPurchaseView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.bounds.width)
//        NSLayoutConstraint.activate([
//            materialPurchaseViewLeadingConstraint!,
//            materialPurchaseView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            materialPurchaseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            materialPurchaseView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
//            ])
        let materialPurchaseConfirmationAlertViewWidth = UIScreen.main.bounds.width * 0.8
        let materialPurchaseConfirmationAlertViewHeight = materialPurchaseConfirmationAlertViewWidth * 1.41421356
        materialPurchaseConfirmationAlertView.frame.size = CGSize(
            width: materialPurchaseConfirmationAlertViewWidth,
            height: materialPurchaseConfirmationAlertViewHeight
        )
        materialPurchaseConfirmationAlertView.frame.origin.y = UIScreen.main.bounds.height
        materialPurchaseConfirmationAlertView.center.x = UIScreen.main.bounds.width * 0.5
        materialPurchaseConfirmationAlertView.cancelButton.addTarget(self, action: #selector(onTouchUpInsidePurchaseCancelButton(_:)), for: .touchUpInside)
        materialPurchaseConfirmationAlertView.downloadButton.addTarget(self, action: #selector(onTouchUpInsideDownloadMaterialButton(_:)), for: .touchUpInside)
    }
    
    private func fetchMaterials() {
        let http = HTTP()
        http.async(route: .init(resource: .materials, name: .index)) { response in
            guard let response = response else {
                return
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let materials = try? jsonDecoder.decode([Material].self, from: response) else {
                return
            }
            DispatchQueue.main.async {
                self.materialsScrollView.materials = materials
                self.materialsScrollView.materialCardViews.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapMaterialCardView(_:))))}
            }
        }
    }
    
    @objc
    private func onTapMaterialCardView(_ sender: UITapGestureRecognizer) {
        guard let materialCardView = sender.view as? MaterialCardView else {
            return
        }
        //view.addGestureRecognizer(panGestureRecognizer)
        materialPurchaseView.material = materialCardView.material
        curtainView.slideIn()
//        materialPurchaseViewLeadingConstraint?.constant = 0
//        UIView.Animation.fast {
//            self.view.layoutIfNeeded()
//        }
    }
    
    @objc
    private func onTouchUpInsidePurchaseButton(_ sender: UIButton) {
        _ = addBlackout()
        view.addSubview(materialPurchaseConfirmationAlertView)
        materialPurchaseConfirmationAlertView.material = materialPurchaseView.material
        materialPurchaseConfirmationAlertView.show()
    }
    
    @objc
    private func onTouchUpInsidePurchaseCancelButton(_ sender: UIButton) {
        removeBlackout()
        materialPurchaseConfirmationAlertView.hide() {
            self.materialPurchaseConfirmationAlertView.removeFromSuperview()
        }
    }
    
    @objc
    private func onTouchUpInsideDownloadMaterialButton(_ sender: UIButton) {
        guard let material = materialPurchaseConfirmationAlertView.material,
              let user = user
            else {
            return
        }
        let parameters = [
            URLQueryItem(name: "user_id", value: String(user.id)),
            URLQueryItem(name: "material_id", value: String(material.id))
        ]
        KRProgressHUD.show(withMessage: "Downloading...")
        HTTP().async(path: "api/materials/purchase", method: .post, parameters: parameters) { response in
            KRProgressHUD.dismiss()
            DispatchQueue.main.async {
                self.tabBarController?.selectedIndex = 0
            }
        }
//        let parameters = [
//            URLQueryItem(name: "id", value: String(material.id)),
//        ]
//        HTTP().async(route: .init(resource: .materials, name: .index, options: [.api]), parameters: parameters) { response in
//            let jsonDecoder = JSONDecoder()
//            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//            let material = try! jsonDecoder.decode(Material.self, from: response)
//
//        }
    }
    
//    @objc
//    private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
//        guard let materialPurchaseViewLeadingConstraint = materialPurchaseViewLeadingConstraint else {
//            return
//        }
//        let hideMaterialPurchaseView = {
//            materialPurchaseViewLeadingConstraint.constant = self.view.bounds.width
//            self.view.removeGestureRecognizer(self.panGestureRecognizer)
//            UIView.Animation.fast {
//                self.view.layoutIfNeeded()
//            }
//        }
//        let constant = materialPurchaseViewLeadingConstraint.constant
//        if sender.state == .changed {
//            let velocity = panGestureRecognizer.velocity(in: view)
//            if 3000 <= velocity.x {
//                hideMaterialPurchaseView()
//            } else {
//                materialPurchaseViewLeadingConstraint.constant = min(view.bounds.width, max(0, constant + (velocity.x * 0.015)))
//            }
//        } else if sender.state == .ended {
//            if (view.bounds.width * 0.5) < constant {
//                hideMaterialPurchaseView()
//            } else {
//                materialPurchaseViewLeadingConstraint.constant = 0
//                UIView.Animation.fast {
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
//    }
    
}

extension MaterialSearchViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === curtainView.panGestureRecognizer else {
            return false
        }
        let velocity = curtainView.panGestureRecognizer.velocity(in: view)
        return materialPurchaseView.tabBarView.contentCollectionView.contentOffset.x == 0 &&
               velocity.y < velocity.x
    }
    
}

fileprivate class MaterialsScrollView: UIScrollView {
    
    var insets = UIEdgeInsets.zero
    var interitemSpacing: CGFloat = 0
    var lineSpacing: CGFloat = 0
    
    var materialCardViews = [MaterialCardView]()
    
    var materials = [Material]() {
        didSet {
            materialCardViews.removeAll(keepingCapacity: true)
            var pointer = CGPoint(x: insets.left, y: insets.top)
            let rowCount = 3
            let columnCount = Int(ceil(CGFloat(materials.count) / CGFloat(rowCount)))
            let cardWidth = bounds.width * 0.9
            let cardHeight = (bounds.height - lineSpacing * CGFloat(rowCount - 1) - insets.top - insets.bottom) / CGFloat(rowCount)
            let cardSize = CGSize(width: cardWidth, height: cardHeight)
            for (index, material) in materials.enumerated() {
                let materialCardView = MaterialCardView()
                addSubview(materialCardView)
                materialCardViews.append(materialCardView)
                materialCardView.material = material
                materialCardView.frame = CGRect(origin: pointer, size: cardSize)
                if (index + 1).isMultiple(of: columnCount) {
                    pointer.x = insets.left
                    pointer.y += (cardHeight + lineSpacing)
                } else {
                    pointer.x += (cardWidth + interitemSpacing)
                }
            }
            contentSize = CGSize(width: cardWidth * CGFloat(columnCount) + interitemSpacing * CGFloat(columnCount - 1) + insets.left + insets.right, height: bounds.size.height)
        }
    }
    
}

fileprivate class MaterialCardView: UIView {
    
    var material: Material? {
        didSet {
            guard let material = material else {
                return
            }
            thumbnailImageView.fetch(path: material.thumbnailImagePath)
            //print(thumbnailImageView.image)
            titleLabel.text = material.title
            priceLabel.text = Price(locale: .japan, value: material.price).string
            numberOfLessonsLabel.text = "全" + String(material.lessons.count) + "レッスン"
        }
    }
    
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let userNameLabel = UILabel()
    private let numberOfLessonsLabel = UILabel()
    private let priceLabel = UILabel()
    private let separatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        let leftView = UIView()
        let rightView = UIView()
        addSubview(leftView)
        addSubview(rightView)
        addSubview(separatorView)
        leftView.addSubview(thumbnailImageView)
        rightView.addSubview(titleLabel)
        rightView.addSubview(userNameLabel)
        rightView.addSubview(numberOfLessonsLabel)
        rightView.addSubview(priceLabel)
        leftView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            leftView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            leftView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            ])
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: leftView.safeAreaLayoutGuide.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: leftView.safeAreaLayoutGuide.trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: leftView.safeAreaLayoutGuide.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: leftView.safeAreaLayoutGuide.bottomAnchor),
            ])
        rightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
            rightView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            rightView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            rightView.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            ])
        titleLabel.font = .boldSmall
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: rightView.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: rightView.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: rightView.safeAreaLayoutGuide.topAnchor),
            titleLabel.heightAnchor.constraint(equalTo: rightView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4),
            ])
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            separatorView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            separatorView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            ])
    }
    
}

fileprivate class MaterialPurchaseView: UIView {
    
    var material: Material? {
        didSet {
            guard let material = material else {
                return
            }
            headerLabel.text = material.title
            materialMediaView.material = material
            priceLabel.text = Price(locale: .japan, value: material.price).string
        }
    }
    
    let purchaseButton = UIButton()
    let tabBarView = TabBarView()
    
    private let headerLabel = UILabel()
    private let separatorView = UIView()
    private let materialMediaView = MaterialMediaView()
    private let priceLabel = UILabel()
    
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
        let footerView = UIView()
        let footerLeftView = UIView()
        let footerRightView = UIView()
        addSubview(headerLabel)
        addSubview(tabBarView)
        addSubview(separatorView)
        addSubview(footerView)
        footerView.addSubview(footerLeftView)
        footerView.addSubview(footerRightView)
        footerLeftView.addSubview(priceLabel)
        footerRightView.addSubview(purchaseButton)
        headerLabel.font = .medium
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.1)
            ])
        tabBarView.contentCollectionView.bounces = false
        tabBarView.set(contentViews: ["レッスン": UIView(), "詳細": materialMediaView])
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tabBarView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            tabBarView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.75)
            ])
        separatorView.backgroundColor = .darkGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: tabBarView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            ])
        footerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            footerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            ])
        footerLeftView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerLeftView.leadingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.leadingAnchor),
            footerLeftView.trailingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.centerXAnchor),
            footerLeftView.topAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.topAnchor),
            footerLeftView.bottomAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.bottomAnchor),
            ])
        priceLabel.font = .medium
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.centerXAnchor.constraint(equalTo: footerLeftView.safeAreaLayoutGuide.centerXAnchor),
            priceLabel.centerYAnchor.constraint(equalTo: footerLeftView.safeAreaLayoutGuide.centerYAnchor),
            priceLabel.widthAnchor.constraint(equalTo: footerLeftView.heightAnchor, multiplier: 2),
            priceLabel.heightAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.6),
            priceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            ])
        footerRightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerRightView.leadingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.centerXAnchor),
            footerRightView.trailingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.trailingAnchor),
            footerRightView.topAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.topAnchor),
            footerRightView.bottomAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.bottomAnchor),
            ])
        purchaseButton.backgroundColor = .appOrange
        purchaseButton.titleLabel?.font = .boldSmall
        purchaseButton.setTitle("購入", for: .normal)
        purchaseButton.setTitleColor(.white, for: .normal)
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            purchaseButton.centerXAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.centerXAnchor),
            purchaseButton.centerYAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.centerYAnchor),
            purchaseButton.widthAnchor.constraint(equalTo: footerRightView.widthAnchor, multiplier: 0.6),
            purchaseButton.heightAnchor.constraint(equalTo: priceLabel.heightAnchor),
            ])
    }
    
}

//
//fileprivate class MaterialDetailsView: UIView {
//
//    var material: Material? {
//        didSet {
//            guard let material = material else {
//                return
//            }
//            titleLabel.text = material.title
//            lessonsTableView.lessons = material.lessons
//            materialMediaView.material = material
//        }
//    }
//
//    let contentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        return layout
//    }())
//
//
//    private var tabUnderLineViewLeadingConstraint: NSLayoutConstraint?
//    private let lessonsTableView = LessonsTableView()
//    private let materialMediaView = MaterialMediaView()
//    private let titleLabel = UILabel()
//    private let lessonsTabButton = UIButton(type: .system)
//    private let mediaTabButton = UIButton(type: .system)
//    private let tabBarView = UIView()
//    private let tabsStackView = UIStackView()
//    private let tabUnderLineView = UIView()
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupViews()
//    }
//
//    private func setupViews() {
//        backgroundColor = .white
//        addSubview(titleLabel)
//        addSubview(tabBarView)
//        addSubview(contentCollectionView)
//        tabBarView.addSubview(tabsStackView)
//        tabBarView.addSubview(tabUnderLineView)
//        titleLabel.font = .boldMedium
//        titleLabel.textAlignment = .center
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
//            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//            titleLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.1)
//            ])
//        lessonsTabButton.titleLabel?.font = .medium
//        lessonsTabButton.setTitle("レッスン", for: .normal)
//        lessonsTabButton.setTitleColor(.white, for: .normal)
//        lessonsTabButton.addTarget(self, action: #selector(onLessonsTabButtonTouchUpInside(_:)), for: .touchUpInside)
//        mediaTabButton.titleLabel?.font = .medium
//        mediaTabButton.setTitle("詳細", for: .normal)
//        mediaTabButton.setTitleColor(.white, for: .normal)
//        mediaTabButton.addTarget(self, action: #selector(onMediaTabButtonTouchUpInside(_:)), for: .touchUpInside)
//        tabBarView.backgroundColor = .systemBlue
//        tabBarView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tabBarView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
//            tabBarView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
//            tabBarView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
//            tabBarView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.1)
//            ])
//        tabsStackView.addArrangedSubview(lessonsTabButton)
//        tabsStackView.addArrangedSubview(mediaTabButton)
//        tabsStackView.distribution = .fillEqually
//        tabsStackView.axis = .horizontal
//        tabsStackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tabsStackView.leadingAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.leadingAnchor),
//            tabsStackView.trailingAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.trailingAnchor),
//            tabsStackView.topAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.topAnchor),
//            tabsStackView.bottomAnchor.constraint(equalTo: tabUnderLineView.topAnchor),
//            ])
//        tabUnderLineView.backgroundColor = .lightGray
//        tabUnderLineView.translatesAutoresizingMaskIntoConstraints = false
//        tabUnderLineViewLeadingConstraint = tabUnderLineView.leadingAnchor.constraint(equalTo: tabsStackView.leadingAnchor)
//        NSLayoutConstraint.activate([
//            tabUnderLineViewLeadingConstraint!,
//            tabUnderLineView.bottomAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.bottomAnchor),
//            tabUnderLineView.widthAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.widthAnchor, multiplier: CGFloat(1) / CGFloat(tabsStackView.arrangedSubviews.count)),
//            tabUnderLineView.heightAnchor.constraint(equalToConstant: 5)
//            ])
//        contentCollectionView.dataSource = self
//        contentCollectionView.delegate = self
//        contentCollectionView.isPagingEnabled = true
//        contentCollectionView.bounces = false
//        contentCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.id)
//        contentCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            contentCollectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
//            contentCollectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
//            contentCollectionView.topAnchor.constraint(equalTo: tabBarView.bottomAnchor),
//            contentCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
//            ])
//    }
//
//    @objc
//    private func onLessonsTabButtonTouchUpInside(_ sender: UIButton) {
//        contentCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
//    }
//
//    @objc
//    private func onMediaTabButtonTouchUpInside(_ sender: UIButton) {
//        contentCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: true)
//    }
//
//}
//
//extension MaterialDetailsView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        tabUnderLineViewLeadingConstraint?.constant = (scrollView.contentOffset.x / contentCollectionView.bounds.width) * (tabsStackView.bounds.width / CGFloat(tabsStackView.arrangedSubviews.count))
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 2
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.id, for: indexPath)
//        let contentView = indexPath.row == 0 ? lessonsTableView : materialMediaView
//        cell.addSubview(contentView)
//        contentView.frame.size = cell.frame.size
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return contentCollectionView.bounds.size
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//
//}

//fileprivate class LessonsTableView: UITableView {
//
//    var lessons = [Lesson]() {
//        didSet {
//            reloadData()
//        }
//    }
//
//    override func numberOfRows(inSection section: Int) -> Int {
//        return lessons.count
//    }
//
//    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
//        let cell = UITableViewCell()
//        cell.textLabel?.text = lessons[indexPath.row].title
//        return cell
//    }
//
//}

//fileprivate class MaterialCommentView: UIView {
//
//}

fileprivate class MaterialMediaView: UIView {
    
    var material: Material? = nil {
        didSet {
            guard let material = material else {
                return
            }
            thumbnailImageView.fetch(path: material.thumbnailImagePath)
            commentViews.forEach { $0.removeFromSuperview() }
            commentViews.removeAll(keepingCapacity: true)
            titleLabel.text = material.title
            descriptionTextView.text = material.description
            descriptionTextView.frame.size.height = descriptionTextView.sizeThatFits(CGSize(width: CGFloat.infinity, height: .infinity)).height
            //            for comment in material.comments {
            //                let commentViewHeight: CGFloat = 200
            //                let commentView = UIView()
            //                commentsView.addSubview(commentView)
            //                commentViews.append(commentView)
            //
            //            }
        }
    }
    
    private let scrollView = UIScrollView()
    private let profileView = UIView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let separatorView1 = UIView()
    private let descriptionTextView = UITextView()
    private let separatorView2 = UIView()
    private let commentsView = UIView()
    private let commentsViewHeaderLabel = UILabel()
    private var commentViews = [UIView]()
    
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
    }
    
    private func setupViews() {
        backgroundColor = .white
        let profileLeftView = UIView()
        let profileRightView = UIView()
        addSubview(scrollView)
        scrollView.addSubview(profileView)
        scrollView.addSubview(separatorView1)
        scrollView.addSubview(separatorView2)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(commentsView)
        profileView.addSubview(profileLeftView)
        profileView.addSubview(profileRightView)
        profileView.addSubview(titleLabel)
        profileView.addSubview(authorLabel)
        profileLeftView.addSubview(thumbnailImageView)
        commentsView.addSubview(commentsViewHeaderLabel)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            ])
        profileLeftView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileLeftView.leadingAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.leadingAnchor),
            profileLeftView.centerYAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.centerYAnchor),
            profileLeftView.widthAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            profileLeftView.heightAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.8)
            ])
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.trailingAnchor.constraint(equalTo: profileLeftView.trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: profileLeftView.safeAreaLayoutGuide.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: profileLeftView.safeAreaLayoutGuide.bottomAnchor),
            thumbnailImageView.widthAnchor.constraint(equalTo: profileLeftView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            ])
        profileRightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileRightView.leadingAnchor.constraint(equalTo: profileLeftView.trailingAnchor),
            profileRightView.trailingAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.trailingAnchor),
            profileRightView.topAnchor.constraint(equalTo: profileLeftView.topAnchor),
            profileRightView.bottomAnchor.constraint(equalTo: profileLeftView.bottomAnchor),
            ])
        titleLabel.numberOfLines = 0
        titleLabel.font = .boldSmall
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: profileRightView.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: profileRightView.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: profileRightView.safeAreaLayoutGuide.topAnchor),
            ])
        separatorView1.backgroundColor = .lightGray
        descriptionTextView.font = .medium
        descriptionTextView.isSelectable = false
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        separatorView2.backgroundColor = separatorView1.backgroundColor
        commentsViewHeaderLabel.text = "コメント"
        commentsViewHeaderLabel.font = .small
        commentsViewHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentsViewHeaderLabel.leadingAnchor.constraint(equalTo: commentsView.safeAreaLayoutGuide.leadingAnchor),
            commentsViewHeaderLabel.topAnchor.constraint(equalTo: commentsView.safeAreaLayoutGuide.topAnchor, constant: 16),
            ])
    }
    
    private func layoutViews() {
        profileView.frame = CGRect(x: safeAreaInsets.left, y: safeAreaInsets.top, width: safeAreaLayoutGuide.layoutFrame.width, height: safeAreaLayoutGuide.layoutFrame.height * 0.35)
        separatorView1.frame = CGRect(x: safeAreaInsets.left, y: profileView.frame.maxY, width: safeAreaLayoutGuide.layoutFrame.width, height: 1)
        descriptionTextView.frame.origin = CGPoint(x: safeAreaInsets.left, y: separatorView1.frame.maxY)
        descriptionTextView.frame.size.width = safeAreaLayoutGuide.layoutFrame.width
        separatorView2.frame = CGRect(
            x: safeAreaInsets.left,
            y: descriptionTextView.frame.maxY,
            width: safeAreaLayoutGuide.layoutFrame.width,
            height: 1
        )
        commentsView.frame = CGRect(
            x: safeAreaInsets.left,
            y: separatorView2.frame.maxY,
            width: safeAreaLayoutGuide.layoutFrame.width,
            height: 300
        )
        scrollView.contentSize = CGSize(width: bounds.width, height: commentsView.frame.maxY)
    }
    
}


fileprivate class MaterialPurchaseConfirmationAlertView: UIView {
    
    var material: Material? {
        didSet {
            guard let material = material else {
                return
            }
            titleLabel.text = material.title
            priceLabel.text = Price(locale: .japan, value: material.price).string
        }
    }
    
    let downloadButton = UIButton()
    let cancelButton = UIButton()
    
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func show(with duration: TimeInterval = UIView.Animation.Duration.normal, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.center.y = UIScreen.main.bounds.height * 0.5
        }) { _ in
            completion?()
        }
    }
    
    func hide(with duration: TimeInterval = UIView.Animation.Duration.normal, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.frame.origin.y = UIScreen.main.bounds.height
        }) { _ in
            completion?()
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        let headerLabel = UILabel()
        let separatorView = UIView()
        let footerView = UIView()
        let footerLeftView = UIView()
        let footerRightView = UIView()
        addSubview(headerLabel)
        addSubview(separatorView)
        addSubview(titleLabel)
        addSubview(priceLabel)
        addSubview(footerView)
        footerView.addSubview(footerLeftView)
        footerView.addSubview(footerRightView)
        footerLeftView.addSubview(cancelButton)
        footerRightView.addSubview(downloadButton)
        headerLabel.text = "購入しますか?"
        headerLabel.font = .small
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
            ])
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            ])
        titleLabel.font = .boldMedium
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            titleLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.3)
            ])
        priceLabel.font = .boldSmall
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            priceLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.2)
            ])
        footerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor),
            footerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            ])
        footerLeftView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerLeftView.leadingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.leadingAnchor),
            footerLeftView.trailingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.centerXAnchor),
            footerLeftView.topAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.topAnchor),
            footerLeftView.bottomAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.bottomAnchor),
            ])
        cancelButton.backgroundColor = .lightGray
        cancelButton.titleLabel?.font = .boldSmall
        cancelButton.setTitle("キャンセル", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.centerXAnchor.constraint(equalTo: footerLeftView.safeAreaLayoutGuide.centerXAnchor),
            cancelButton.centerYAnchor.constraint(equalTo: footerLeftView.safeAreaLayoutGuide.centerYAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: cancelButton.sizeThatFits(CGSize(width: CGFloat.infinity, height: .infinity)).width),
            cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 0.5),
            cancelButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            ])
        footerRightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerRightView.leadingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.centerXAnchor),
            footerRightView.trailingAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.trailingAnchor),
            footerRightView.topAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.topAnchor),
            footerRightView.bottomAnchor.constraint(equalTo: footerView.safeAreaLayoutGuide.bottomAnchor),
            ])
        downloadButton.backgroundColor = .appOrange
        downloadButton.titleLabel?.font = cancelButton.titleLabel?.font
        downloadButton.setTitle("購入", for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            downloadButton.centerXAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.centerXAnchor),
            downloadButton.centerYAnchor.constraint(equalTo: footerRightView.safeAreaLayoutGuide.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            downloadButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor)
            ])
    }
    
}

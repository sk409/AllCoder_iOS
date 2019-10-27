import UIKit

class TabBarView: UIView {
    
    var selectedTabIndex = 0 {
        didSet {
            contentCollectionView.scrollToItem(at: IndexPath(item: selectedTabIndex, section: 0), at: .left, animated: true)
        }
    }
    
    let tabBarView = UIView()
    let tabUnderLineView = UIView()
    let contentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }())
    
    private(set) var contentViews = [UIView]()
    
    private var tabUnderLineViewLeadingConstraint: NSLayoutConstraint?
    private var tabUnserLineViewWidthConstraint: NSLayoutConstraint?
    private let tabsStackView = UIStackView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func set(contentViews: KeyValuePairs<String, UIView>) {
        guard !contentViews.isEmpty else {
            return
        }
        for (index, view) in contentViews.enumerated() {
            let tabButton = UIButton()
            tabButton.tag = index
            tabButton.setTitle(view.key, for: .normal)
            tabButton.addTarget(self, action: #selector(onTouchUpInsideTabButton(_:)), for: .touchUpInside)
            tabsStackView.addArrangedSubview(tabButton)
            self.contentViews.append(view.value)
        }
        tabUnserLineViewWidthConstraint?.isActive = false
        tabUnserLineViewWidthConstraint = tabUnderLineView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: CGFloat(1) / CGFloat(contentViews.count))
        tabUnserLineViewWidthConstraint?.isActive = true
        contentCollectionView.reloadData()
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(tabBarView)
        addSubview(contentCollectionView)
        tabBarView.addSubview(tabsStackView)
        tabBarView.addSubview(tabUnderLineView)
        tabBarView.backgroundColor = .systemBlue
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tabBarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tabBarView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.1)
            ])
        tabsStackView.distribution = .fillEqually
        tabsStackView.axis = .horizontal
        tabsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabsStackView.leadingAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.leadingAnchor),
            tabsStackView.trailingAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.trailingAnchor),
            tabsStackView.topAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.topAnchor),
            tabsStackView.bottomAnchor.constraint(equalTo: tabUnderLineView.topAnchor),
            ])
        tabUnderLineView.backgroundColor = .lightGray
        tabUnderLineView.translatesAutoresizingMaskIntoConstraints = false
        tabUnderLineViewLeadingConstraint = tabUnderLineView.leadingAnchor.constraint(equalTo: tabsStackView.leadingAnchor)
        tabUnserLineViewWidthConstraint = tabUnderLineView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            tabUnderLineViewLeadingConstraint!,
            tabUnderLineView.bottomAnchor.constraint(equalTo: tabBarView.safeAreaLayoutGuide.bottomAnchor),
            tabUnserLineViewWidthConstraint!,
            tabUnderLineView.heightAnchor.constraint(equalToConstant: 5)
            ])
        contentCollectionView.dataSource = self
        contentCollectionView.delegate = self
        contentCollectionView.isPagingEnabled = true
        contentCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.id)
        contentCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentCollectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentCollectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            contentCollectionView.topAnchor.constraint(equalTo: tabBarView.bottomAnchor),
            contentCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            ])
    }
    
    @objc
    private func onTouchUpInsideTabButton(_ sender: UIButton) {
        selectedTabIndex = sender.tag
    }
    
}



extension TabBarView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tabUnderLineViewLeadingConstraint?.constant = (scrollView.contentOffset.x / contentCollectionView.bounds.width) * (tabsStackView.bounds.width / CGFloat(tabsStackView.arrangedSubviews.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentViews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.id, for: indexPath)
        let contentView = contentViews[indexPath.row]
        cell.addSubview(contentView)
        contentView.frame.size = cell.frame.size
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return contentCollectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}

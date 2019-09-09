//import UIKit
//
//class LessonsView: UIView {
//    
//    var lessons = [Lesson]() {
//        didSet {
//            tableView.reloadData()
//        }
//    }
//    
//    let tableView = UITableView()
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
//        addSubview(tableView)
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.tableFooterView = UIView()
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
//            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
//            ])
//    }
//    
//}
//
//extension LessonsView: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return lessons.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        cell.textLabel?.text = lessons[indexPath.row].title
//        return cell
//    }
//}

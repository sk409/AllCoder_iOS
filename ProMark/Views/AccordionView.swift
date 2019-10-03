import UIKit

protocol AccordionViewDataSource {
    
    func accordionViewNumberOfItems(_ accordionView: AccordionView) -> Int
    
}

protocol AccordionViewDelegate {
    
    func accordionView(_ accordionView: AccordionView, headerViewForItemAt item: Int) -> UIView
    func accordionView(_ accordionView: AccordionView, bodyViewForItemAt item: Int) -> UIView
    func accordionView(_ accordionView: AccordionView, headerViewHeightForItemAt item: Int, headerView: UIView) -> CGFloat
    func accordionView(_ accordionView: AccordionView, bodyViewHeightForItemAt item: Int, bodyView: UIView) -> CGFloat
    func accordionView(_ accordionView: AccordionView, toggleButtonForItemAt item: Int) -> UIButton
    func accordionView(_ accordionView: AccordionView, toggleButtonPositionIn headerView: UIView, forItemAt item: Int, toggleButton: UIButton) -> CGPoint
    func accordionView(_ accordionView: AccordionView, toggleButtonSizeForItemAt item: Int, toggleButton: UIButton) -> CGSize
    func accordionView(_ accordionView: AccordionView, isOpenItemAt item: Int) -> Bool
    func accordionView(_ accordionView: AccordionView, willToggle headerView: UIView, bodyView: UIView, toggleButton: UIButton, open: Bool)
    func accordionView(_ accordionView: AccordionView, didToggle headerView: UIView, bodyView: UIView, toggleButton: UIButton, open: Bool)
    func accordionView(_ accordionView: AccordionView, WillChangeHeight height: CGFloat, trigerToggleButton: UIButton?, headerView: UIView?, bodyView: UIView?)
    func accordionView(_ accordionView: AccordionView, DidChangeHeight height: CGFloat, trigerToggleButton: UIButton?, headerView: UIView?, bodyView: UIView?)
    func accordionViewtoggleAnimationDuration(_ accordionView: AccordionView) -> TimeInterval
    
}

extension AccordionViewDelegate {
    
    func accordionView(_ accordionView: AccordionView, willToggle headerView: UIView, bodyView: UIView, toggleButton: UIButton, open: Bool) {
        
    }
    
    func accordionView(_ accordionView: AccordionView, didToggle headerView: UIView, bodyView: UIView, toggleButton: UIButton, open: Bool) {
        
    }
    
    func accordionView(_ accordionView: AccordionView, isOpenItemAt item: Int) -> Bool {
        return false
    }
    
    func accordionView(_ accordionView: AccordionView, WillChangeHeight height: CGFloat, trigerToggleButton: UIButton?, headerView: UIView?, bodyView: UIView?)
    {
        
    }
    
    func accordionView(_ accordionView: AccordionView, DidChangeHeight height: CGFloat, trigerToggleButton: UIButton?, headerView: UIView?, bodyView: UIView?)
    {
        
    }
    
    func accordionViewtoggleAnimationDuration(_ accordionView: AccordionView) -> TimeInterval {
        return 0.5
    }
    
}

class AccordionView: UIView {
    
    var dataSource: AccordionViewDataSource?
    var delegate: AccordionViewDelegate?
    
    private(set) var height: CGFloat = 0
    
    private var headerViews = [UIView]()
    private var bodyViews = [UIView]()
    private var bodyViewHeightConstraints = [NSLayoutConstraint]()
    
    
    func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        guard let delegate = delegate else {
            return
        }
        subviews.forEach { $0.removeFromSuperview() }
        headerViews.removeAll(keepingCapacity: true)
        bodyViews.removeAll(keepingCapacity: true)
        bodyViewHeightConstraints.removeAll(keepingCapacity: true)
        let numberOfItems = dataSource.accordionViewNumberOfItems(self)
        delegate.accordionView(self, WillChangeHeight: height, trigerToggleButton: nil, headerView: nil, bodyView: nil)
        height = 0
        for itemIndex in 0..<numberOfItems {
            let headerView = delegate.accordionView(self, headerViewForItemAt: itemIndex)
            let toggleButton = delegate.accordionView(self, toggleButtonForItemAt: itemIndex)
            let bodyView = delegate.accordionView(self, bodyViewForItemAt: itemIndex)
            addSubview(headerView)
            addSubview(toggleButton)
            addSubview(bodyView)
            headerViews.append(headerView)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            let headerViewTopAnchor = bodyViews.last == nil ? safeAreaLayoutGuide.topAnchor  : bodyViews.last!.bottomAnchor
            let headerViewHegiht = delegate.accordionView(self, headerViewHeightForItemAt: itemIndex, headerView: headerView)
            height += headerViewHegiht
            NSLayoutConstraint.activate([
                headerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                headerView.topAnchor.constraint(equalTo: headerViewTopAnchor),
                headerView.heightAnchor.constraint(equalToConstant: headerViewHegiht),
                ])
            let toggleButtonPosition = delegate.accordionView(self, toggleButtonPositionIn: headerView, forItemAt: itemIndex, toggleButton: toggleButton)
            let toggleButtonSize = delegate.accordionView(self, toggleButtonSizeForItemAt: itemIndex, toggleButton: toggleButton)
            toggleButton.tag = itemIndex
            toggleButton.addTarget(self, action: #selector(onTouchUpInsideToggleButton(_:)), for: .touchUpInside)
            toggleButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                toggleButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: toggleButtonPosition.x),
                toggleButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: toggleButtonPosition.y),
                toggleButton.widthAnchor.constraint(equalToConstant: toggleButtonSize.width),
                toggleButton.heightAnchor.constraint(equalToConstant: toggleButtonSize.height),
                ])
            bodyViews.append(bodyView)
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            let bodyViewHeight = delegate.accordionView(self, isOpenItemAt: itemIndex) ? delegate.accordionView(self, bodyViewHeightForItemAt: itemIndex, bodyView: bodyView) :
                0
            height += bodyViewHeight
            let bodyViewHeightConstraint = bodyView.heightAnchor.constraint(equalToConstant: bodyViewHeight)
            bodyViewHeightConstraints.append(bodyViewHeightConstraint)
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                bodyView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                bodyView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                bodyViewHeightConstraint,
                ])
        }
        delegate.accordionView(self, DidChangeHeight: height, trigerToggleButton: nil, headerView: nil, bodyView: nil)
    }
    
    @objc
    private func onTouchUpInsideToggleButton(_ sender: UIButton) {
        guard sender.tag < bodyViewHeightConstraints.count else {
            return
        }
        guard let delegate = delegate else {
            return
        }
        let animationDuration = delegate.accordionViewtoggleAnimationDuration(self)
        let headerView = headerViews[sender.tag]
        let bodyView = bodyViews[sender.tag]
        let bodyViewHeightConstraint = bodyViewHeightConstraints[sender.tag]
        let expectedHeight = delegate.accordionView(self, bodyViewHeightForItemAt: sender.tag, bodyView: bodyView)
        let open = (0 == bodyViewHeightConstraint.constant)
        let fromHeight = open ?
            0 :
            expectedHeight
        let toHeight = open ?
                     expectedHeight :
                     0
        bodyViewHeightConstraint.constant = toHeight
        delegate.accordionView(self, willToggle: headerView, bodyView: bodyView, toggleButton: sender, open: open)
        delegate.accordionView(self, WillChangeHeight: height, trigerToggleButton: sender, headerView: headerView, bodyView: bodyView)
        UIView.animate(withDuration: animationDuration, animations: {
            self.layoutIfNeeded()
        }) { _ in
            delegate.accordionView(self, didToggle: headerView, bodyView: bodyView, toggleButton: sender, open: open)
            self.height += (toHeight - fromHeight)
            delegate.accordionView(self, DidChangeHeight: self.height, trigerToggleButton: sender, headerView: headerView, bodyView: bodyView)
        }
    }
    
}

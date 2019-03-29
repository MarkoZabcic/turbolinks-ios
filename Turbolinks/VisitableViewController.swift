import UIKit

open class VisitableViewController: UIViewController, Visitable {
    open weak var visitableDelegate: VisitableDelegate?
    
    open var visitableURL: URL!
    
    public convenience init(url: URL) {
        self.init()
        self.visitableURL = url
    }
    
    // MARK: Visitable View
    
    open private(set) lazy var visitableView: VisitableView! = {
        let view = VisitableView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Changed constraint setup
    fileprivate func installVisitableView() {
        view.addSubview(visitableView)
        addVisitableViewConstraints()
        addWebViewConstraints()
        addHiddenScrollViewConstraints()
    }
    
    // MARK: Visitable
    
    open func visitableDidRender() {
        self.title = visitableView.webView?.title
    }
    
    // MARK: View Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        installVisitableView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visitableDelegate?.visitableViewWillAppear(self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visitableDelegate?.visitableViewDidAppear(self)
    }
    
    /*
     If the visitableView is a child of the main view, and anchored to its top and bottom, then it's
     unlikely you will need to customize the layout. But more complicated view hierarchies and layout
     may require explicit control over the contentInset. Below is an example of setting the contentInset
     to the layout guides.
     
     public override func viewDidLayoutSubviews() {
     super.viewDidLayoutSubviews()
     visitableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
     }
     */
}

/*
 The constraint setup method in this extension are now used in place of old methods in VisitableView.swift that were not
 Safe Area aware. Constraints for all subviews are now setup in VisitableViewController instead of VisitableView so we can
 access top and bottom layout guides.
*/
extension VisitableViewController {
    private func addVisitableViewConstraints() {
        self.visitableView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        self.visitableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.visitableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.visitableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func addWebViewConstraints() {
        self.visitableView.webView?.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        self.visitableView.webView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.visitableView.webView?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.visitableView.webView?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    private func addHiddenScrollViewConstraints() {
        self.visitableView.hiddenScrollView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        self.visitableView.hiddenScrollView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
        self.visitableView.hiddenScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.visitableView.hiddenScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
}

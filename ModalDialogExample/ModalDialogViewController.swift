//
//  ModalDialogViewController.swift
//
//  Created by Tarun Mathur on 03/09/21.
//

import UIKit
import MaterialComponents
import RxSwift
import RxCocoa

class ModalDialogViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    private var container = MDCCard(frame: CGRect(x: 100, y: 200, width: 200, height: 200))
    private var stackViewContainer = UIStackView()
    private var buttonStack: UIStackView?
    private var simpleMessage: UILabel?
    private var completionHandler: (() -> Void)?
    
    public let publishUpdateMessageSimple = BehaviorRelay<String>(value: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    init(title: String, hasSimpleMessage:Bool = false, shouldDismissOnTap: Bool = false, shouldShowIndeterminateProgress: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.addBackdrop()
        self.addCardContainer()
        self.addStackView()
        self.addTitleToStack(title: title)
        shouldShowIndeterminateProgress ? self.addIndeterminateCircularProgress() : nil
        hasSimpleMessage ? self.addSimpleMessageToStack(title: "") : nil
        shouldDismissOnTap ? self.dismissOnTap() : nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func dismissOnTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissModal(){
        self.dismissSelf()
    }
    
    private func addBackdrop(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    private func addCardContainer(){
        self.container.backgroundColor = .white
        self.container.cornerRadius = 8
        self.container.setShadowColor(.black, for: .normal)
        self.container.setShadowElevation(ShadowElevation(4), for: .normal)
        self.view.addSubview(self.container)
        self.container.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "container": self.container
        ]
        var allConstraints: [NSLayoutConstraint] = []
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-32-[container]-32-|",
            metrics: nil,
            views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[container]",
            metrics: nil,
            views: views)
        let centerConstaint = [NSLayoutConstraint(item: self.container, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)]
        allConstraints += horizontalConstraints
        allConstraints += verticalConstraints
        allConstraints += centerConstaint
        NSLayoutConstraint.activate(allConstraints)
    }
    
    private func addStackView(){
        self.stackViewContainer.axis = .vertical
        self.stackViewContainer.spacing = 10
        self.stackViewContainer.distribution = .fill
        self.stackViewContainer.alignment = .fill
        self.container.addSubview(self.stackViewContainer)
        self.stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "stackViewContainer": self.stackViewContainer
        ]
        var allConstraints: [NSLayoutConstraint] = []
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-32-[stackViewContainer]-32-|",
            metrics: nil,
            views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-32-[stackViewContainer]-32-|",
            metrics: nil,
            views: views)
        allConstraints += horizontalConstraints
        allConstraints += verticalConstraints
        NSLayoutConstraint.activate(allConstraints)
        
    }
    
    private func addTitleToStack(title: String){
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 26)
        titleLabel.textColor = .darkGray
        titleLabel.text = title
        titleLabel.textAlignment = .center
        self.stackViewContainer.addArrangedSubview(titleLabel)
    }
    
    private func addIndeterminateCircularProgress(){
        let circularProgress = MDCActivityIndicator()
        circularProgress.indicatorMode = .indeterminate
        circularProgress.cycleColors = [.blue]
        circularProgress.radius = 60
        circularProgress.strokeWidth = 8
        circularProgress.startAnimating()
        self.stackViewContainer.addArrangedSubview(circularProgress)
        circularProgress.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = [
            "circularProgress": circularProgress
        ]
        var allConstraints: [NSLayoutConstraint] = []
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[circularProgress(==130)]",
            metrics: nil,
            views: views)
        allConstraints += verticalConstraints
        NSLayoutConstraint.activate(allConstraints)
    }
    
    private func addSimpleMessageToStack(title: String){
        self.simpleMessage = UILabel()
        self.simpleMessage?.numberOfLines = 10
        self.simpleMessage?.font = .systemFont(ofSize: 15)
        self.simpleMessage?.textColor = .darkGray
        self.simpleMessage?.text = title
        self.simpleMessage?.textAlignment = .left
        self.stackViewContainer.addArrangedSubview(self.simpleMessage!)
        
        self.publishUpdateMessageSimple
            .subscribe { (message: String) in
                self.simpleMessage?.text = message
            }.disposed(by: self.disposeBag)
    }
    
    private func addButtonToButtonStack(button: MDCButton){
        if self.buttonStack == nil{
            self.buttonStack = UIStackView()
            self.buttonStack?.axis = .horizontal
            self.buttonStack?.distribution = .fill
            self.buttonStack?.spacing = 12
            self.buttonStack?.alignment = .trailing
            self.stackViewContainer.addArrangedSubview(self.buttonStack!)
        }
        self.buttonStack?.addArrangedSubview(button)
    }
    
    //MARK:- Exposed functions
    
    public func primaryButton(_ title: String, clickHandler: @escaping ()->Void){
        let button = MDCButton()
        button.applyTextTheme(withScheme: ApplicationScheme.shared.buttonPrimaryTheme)
        button.setTitle(title, for: .normal)
        button.rx.tap.bind{
            clickHandler()
        }.disposed(by: self.disposeBag)
        self.addButtonToButtonStack(button: button)
    }
    
    public func secondaryButton(_ title: String, clickHandler: @escaping ()->Void){
        let button = MDCButton()
        button.applyTextTheme(withScheme: ApplicationScheme.shared.buttonPrimaryTheme)
        button.setTitle(title, for: .normal)
        button.rx.tap.bind{
            clickHandler()
        }.disposed(by: self.disposeBag)
        self.addButtonToButtonStack(button: button)
    }
    
    public func dismissSelf(){
        self.dismiss(animated: true) {
            if let handler = self.completionHandler{
                handler()
            }
        }
    }
    
}

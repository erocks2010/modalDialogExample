//
//  ViewController.swift
//  ModalDialogExample
//
//  Created by Tarun Mathur on 09/09/21.
//

import UIKit
import MaterialComponents
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    private var disposeBag = DisposeBag()
    @IBOutlet weak var button: MDCButton!
    @IBOutlet weak var button2: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.button.applyContainedTheme(withScheme: ApplicationScheme.shared.buttonPrimaryTheme)
        self.button.rx.tap.bind{
            let dialog = ModalDialogViewController(title: "Simple Dialog", hasSimpleMessage: true, shouldDismissOnTap: true, shouldShowIndeterminateProgress: true)
            self.present(dialog, animated: true, completion: nil)
            Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(10)
                .subscribe{ (counter: Int) in
                    dialog.publishUpdateMessageSimple.accept("Updated Message \(counter)")
                }.disposed(by: self.disposeBag)
        }.disposed(by: self.disposeBag)
        
        
        self.button2.applyContainedTheme(withScheme: ApplicationScheme.shared.buttonPrimaryTheme)
        self.button2.rx.tap.bind{
            let dialog = ModalDialogViewController(title: "Simple Dialog with Action Buttons", hasSimpleMessage: true, shouldDismissOnTap: false, shouldShowIndeterminateProgress: true)
            dialog.primaryButton("DISMISS") {
                dialog.dismiss(animated: true, completion: nil)
            }
            dialog.secondaryButton("CANCEL") {
                dialog.dismiss(animated: true, completion: nil)
            }
            self.present(dialog, animated: true, completion: nil)
            Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).take(10)
                .subscribe{ (counter: Int) in
                    dialog.publishUpdateMessageSimple.accept("Updated Message \(counter)")
                }.disposed(by: self.disposeBag)
            
        }.disposed(by: self.disposeBag)
    }


}


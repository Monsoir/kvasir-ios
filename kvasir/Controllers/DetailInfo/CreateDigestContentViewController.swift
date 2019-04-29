//
//  CreateDigestContentViewController.swift
//  kvasir
//
//  Created by Monsoir on 4/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesome_swift
import RealmSwift

private let DefaultTab = 0

class CreateDigestContentViewController<Digest: RealmWordDigest>: UIViewController {
    
    private var digest: Digest
    
    private lazy var constraintDict = [String: Constraint]()
    private lazy var basicInfoVC = WordDigestInfoViewController(digest: self.digest, creating: true)
    private lazy var contentVC = TextEditViewController(digest: self.digest)
    private lazy var vcs = [self.basicInfoVC, self.contentVC]
    private var currentVC: UIViewController? {
        get {
            return self.children.first
        }
    }

    private lazy var segement: UISegmentedControl = {
        let view = UISegmentedControl(items: ["基本信息", "\(Digest.toHuman())内容"])
        view.addTarget(self, action: #selector(actionChangeSegement(sender:)), for: .valueChanged)
        view.selectedSegmentIndex = DefaultTab
        return view
    }()
    
    init(digest: Digest) {
        self.digest = digest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
    }
    
    @objc func actionChangeSegement(sender: UISegmentedControl) {
        switchTabTo(sender.selectedSegmentIndex)
    }
    
    @objc func actionSubmit() {
        let formValues = basicInfoVC.getFormValues()
        
        var contentValues: [String: Any]!
        do {
            contentValues = try contentVC.getValues()
        } catch let error as KvasirError {
            switch error {
            case .contentEmpty:
                Bartendar.handleSimpleAlert(title: "提示", message: "内容不能为空", on: self)
            }
            return
        } catch {
            return
        }
        
        let content = contentValues["content"] as! String
        
        digest.content = content
        digest.pageIndex = formValues["pageIndex"] as? Int ?? -1
        
        saveDigest(otherInfo: ["bookId": formValues["bookId"] ?? ""]) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "提示", message: "内容不能为空", defaultActionButtonTitle: "确定", tintColor: .black)
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

private extension CreateDigestContentViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.titleView = segement
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: { [weak self] in
            let btn = simpleButtonWithButtonFromAwesomefont(name: .check, fontSize: 22)
            btn.addTarget(self, action: #selector(actionSubmit), for: .touchUpInside)
            return btn
        }())
    }
    
    func setupSubviews() {
        let childVC = vcs[DefaultTab]
        addChildViewController(childVC, toContainerView: view)
        var constraint: Constraint!
        childVC.view.snp.makeConstraints({ (make) in
            constraint = make.edges.equalToSuperview().constraint
        })
        constraintDict[childVC.toMachine()] = constraint
    }
    
    func switchTabTo(_ index: Int) {
        if let beforeVC = currentVC {
            beforeVC.removeViewAndControllerFromParentViewController()
            constraintDict[beforeVC.toMachine()]?.deactivate()
        }
        
        let toVC = vcs[index]
        addChildViewController(toVC, toContainerView: view)
        if let constraint = constraintDict[toVC.toMachine()] {
            constraint.activate()
        } else {
            var constraint: Constraint!
            toVC.view.snp.makeConstraints { (make) in
                constraint = make.edges.equalToSuperview().constraint
            }
            constraintDict[toVC.toMachine()] = constraint
        }
    }
    
    func saveDigest(otherInfo: [String: Any]?, completion: @escaping RealmSaveCompletion) {
        digest.save(with: otherInfo?["bookId"] as? String) { (success) in
            completion(success)
        }
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let strongSelf = self else { return }
//            autoreleasepool(invoking: { () -> Void in
//                do {
//                    let realm = try Realm()
//
//                    var book: RealmBook?
//                    if let bookId = otherInfo?["bookId"] as? String, !bookId.isEmpty {
//                        book = realm.object(ofType: RealmBook.self, forPrimaryKey: bookId)
//                    }
//
//                    try realm.write {
//                        realm.add(strongSelf.digest)
//                        if let book = book {
//                            strongSelf.digest.book = book
//                            if Digest.self === RealmSentence.self {
//                                book.sentences.append(strongSelf.digest as! RealmSentence)
//                            } else {
//                                book.paragraphs.append(strongSelf.digest as! RealmParagraph)
//                            }
//                        }
//                    }
//                    completion(true)
//                } catch {
//                    completion(false)
//                }
//            })
//        }
    }
}

private extension UIViewController {
    func toMachine() -> String {
        return "\(self.self)"
    }
}

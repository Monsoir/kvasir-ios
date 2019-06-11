//
//  EurekaKeyValueRow.swift
//  kvasir
//
//  Created by Monsoir on 4/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Eureka
import SnapKit
import RealmSwift

final class EurekaLabelValueRow<creator: RealmCreator>: OptionsRow<PushSelectorCell<EurekaLabelValueModel>>, PresenterRowType, RowType {
    public typealias PresenterRow = CreatorCanidateListViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return CreatorCanidateListViewController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        
        displayValueFor = {
            guard let model = $0 else { return "" }
            return model.label
        }
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

class CreatorCanidateListViewController: UnifiedViewController, TypedRowControllerType, UITableViewDelegate, UITableViewDataSource {
    
    public var row: RowOf<EurekaLabelValueModel>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    private var results: Results<RealmCreator>?
    private var realmNotificationToken: NotificationToken?
    
    private lazy var tableView: UITableView = { [unowned self] in
        let view = UITableView(frame: CGRect.zero, style: .plain)
        view.rowHeight = CGFloat(50)
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier())
        view.tableFooterView = UIView()
        return view
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "选择"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        fetchData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        realmNotificationToken?.invalidate()
    }
    
    private func fetchData() {
        let repository = RealmCreatorRepository.shared
        repository.queryAllSortingByUpdatedAtDesc { [weak self] (success, results) in
            guard success, let strongSelf = self else {
                return
            }
            
            strongSelf.results = results
            strongSelf.realmNotificationToken = results?.observe({ (changes) in
                switch changes {
                case .initial: fallthrough
                case .update:
                    strongSelf.tableView.reloadData()
                case .error:
                    Bartendar.handleSorryAlert(on: self?.navigationController)
                }
            })
        }
    }
    
    private func setupRealmNotification() {
        realmNotificationToken = results?.observe({ [weak self] (changes) in
            switch changes {
            case .initial: fallthrough
            case .update:
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .error:
                break
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier(), for: indexPath)
        guard let creator = results?[indexPath.row] else { return cell }
        
        cell.textLabel?.text = creator.name
        cell.detailTextLabel?.text = creator.localeName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let creator = results?[indexPath.row] else { return }
        
        row.value = EurekaLabelValueModel(label: creator.name, value: creator.id, info: ["localeName": creator.localeName])
        onDismissCallback?(self)
    }
}

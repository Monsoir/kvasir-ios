//
//  IAPViewController.swift
//  kvasir
//
//  Created by Monsoir on 6/12/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import TORoundedButton
import SnapKit
import SwifterSwift
import StoreKit
import PKHUD

class IAPViewController: UIViewController, Configurable {
    private var navigationTitle: String {
        return configuration["title"] as? String ?? "内购项目"
    }
    
    private var configuration: Configurable.Configuration
    
    private var btnOCR300: RoundedButton?
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        endObservingTransactionQueue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        
        startObservingTransactionQueue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let productList = readLocalPurchaseConfiguration() {
            let ids = Set<String>(productList.map { $0["id"] ?? "" })
            requestPurchasableProduct(ids)
        }
    }
}

extension IAPViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // 暂时只有一个商品，简化处理
        guard response.products.count > 0,
            response.invalidProductIdentifiers.count <= 0,
            let purchasingProduct = response.products.first else {
                MainQueue.async {
                    HUD.flash(.labeledError(title: "没有可购买的商品", subtitle: nil), onView: nil, delay: 1.5, completion: nil)
                    return
                }
            return
        }
        
        MainQueue.async { HUD.hide() }
        
        let ocr300Payment = SKMutablePayment(product: purchasingProduct)
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = purchasingProduct.priceLocale
        if let priceString = formatter.string(from: purchasingProduct.price) {
            MainQueue.async {
                self.btnOCR300?.text = "\(purchasingProduct.localizedTitle) \(priceString)"
                self.btnOCR300?.isEnabled = true
                self.btnOCR300?.alpha = 1.0
                self.btnOCR300?.setNeedsLayout()
                self.btnOCR300?.layoutIfNeeded()
                self.btnOCR300?.tappedHandler = { [weak self] in
                    guard let self = self else { return }
                    self.purchaseProduct(ocr300Payment)
                }
            }
        }
    }
}

extension IAPViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: transactionPurchasing(transaction)
            case .purchased: transactionPurchased(transaction)
            case .failed: transactionFailed(transaction)
            case .restored: transactionRestore(transaction)
            case .deferred: transactionDeferred(transaction)
            }
        }
    }
    
    private func transactionPurchasing(_ transaction: SKPaymentTransaction) {
        HUD.show(.labeledProgress(title: "正在处理中", subtitle: nil))
    }
    
    private func transactionPurchased(_ transaction: SKPaymentTransaction) {
        HUD.flash(.labeledSuccess(title: "购买成功", subtitle: nil), onView: nil, delay: 1.5, completion: nil)
    }
    
    private func transactionFailed(_ transaction: SKPaymentTransaction) {
        HUD.flash(.labeledError(title: "购买失败", subtitle: nil), onView: nil, delay: 1.5, completion: nil)
    }
    
    private func transactionRestore(_ transaction: SKPaymentTransaction) {
        HUD.flash(.labeledSuccess(title: "恢复成功", subtitle: nil), onView: nil, delay: 1.5, completion: nil)
    }
    
    private func transactionDeferred(_ transaction: SKPaymentTransaction) {
        Bartendar.handleTipAlert(message: "交易延期", on: nil)
    }
}

private extension IAPViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        title = navigationTitle
    }
    
    func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        
        let button = RoundedButton(text: "300 次文字识别使用")
        button.tintColor = Color(hexString: ThemeConst.appleBlue)
        button.backgroundColor = .clear
        button.alpha = 0.3
        button.isEnabled = false
        
        let lbRemark: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.text = "一次购买后，就有 300 次使用文字识别的机会\n\n免去手动输入的麻烦"
            label.font = UIFont.systemFont(ofSize: 12)
            return label
        }()
        
        view.addSubview(button)
        view.addSubview(lbRemark)
        
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        lbRemark.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalTo(button)
            make.top.equalTo(button.snp.bottom).offset(10)
        }
        
        btnOCR300 = button
    }
    
    func startObservingTransactionQueue() {
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
    }
    
    func endObservingTransactionQueue() {
        SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
    }
    
    func readLocalPurchaseConfiguration() -> [[String: String]]? {
        guard let filePath = Bundle.main.url(forResource: "iap", withExtension: "plist") else { return nil }
        guard let productList = NSArray(contentsOf: filePath) as? [[String:String]] else { return nil }
        return productList
    }
    
    
    /// 查询 iTunes Connect 后台配置的内购商品
    ///
    /// - Parameter productId: 后台配置的某个内购商品的 id
    func requestPurchasableProduct(_ productIds: Set<String>) {
        guard SKPaymentQueue.canMakePayments() else {
            Bartendar.handleTipAlert(message: "账户无法购买商品", on: nil)
            return
        }
        
        HUD.show(.progress)
        let request = SKProductsRequest(productIdentifiers: productIds)
        
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(_ payment: SKPayment) {
        SKPaymentQueue.default().add(payment)
    }
}

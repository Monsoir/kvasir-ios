//
//  KvasirSearchControllerWrapper.swift
//  kvasir
//
//  Created by Monsoir on 6/6/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

class KvasirSearchControllerWrapper: NSObject, Configurable {
    private(set) var searchController: UISearchController
    private(set) var resultViewController: DigestSearchResultViewController
    private var configuration: Configurable.Configuration
    
//    private static let resultViewController: DigestSearchResultViewController = {
//        let resultVC = DigestSearchResultViewController(configuration: [:])
//        return resultVC
//    }()
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
        self.resultViewController = DigestSearchResultViewController(configuration: configuration)
        self.searchController = UISearchController(searchResultsController: self.resultViewController)
//        self.searchController = UISearchController(searchResultsController: type(of: self).resultViewController)
        super.init()
        
        // - 对嵌在 navigation bar 中的 search bar, 可能有不能隐藏底部分割线的 bug:
        //   https://forums.developer.apple.com/thread/86828
        //   后面嵌在 table header view 中曲线救国
        //        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.scopeButtonTitles = [RealmWordDigest.Category.sentence.toHuman, RealmWordDigest.Category.paragraph.toHuman]
        
        let searchBar = searchController.searchBar
        searchBar.barTintColor = Color(hexString: ThemeConst.secondaryBackgroundColor) // 改变所搜结果可视时，search bar 的背景色
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "搜索"
        let whiteImage = Color(hexString: ThemeConst.secondaryBackgroundColor)?.msr.asImage
        searchBar.scopeBarBackgroundImage = whiteImage
        searchBar.backgroundImage = whiteImage
        searchBar.setValue("取消", forKey:"_cancelButtonText") // 改变取消按钮的文字
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
}

extension KvasirSearchControllerWrapper {
    func setConfiguration(configuration: Configurable.Configuration) {
//        type(of: self).resultViewController.configuration = configuration
        resultViewController.configuration = configuration
    }
}

extension KvasirSearchControllerWrapper: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let types: [SearchType] = [.sentence, .paragraph]
//        type(of: self).resultViewController.reloadData(of: types[searchBar.selectedScopeButtonIndex], keyword: searchBar.text ?? "")
        resultViewController.reloadData(of: types[searchBar.selectedScopeButtonIndex], keyword: searchBar.text ?? "")
    }
}

extension KvasirSearchControllerWrapper: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        (searchController.searchResultsController as? DigestSearchResultViewController)?.restore()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        (searchController.searchResultsController as? DigestSearchResultViewController)?.restore(exit: true)
    }
}

extension KvasirSearchControllerWrapper: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        
        let searchBar = searchController.searchBar
        let types: [SearchType] = [.sentence, .paragraph]
        (searchController.searchResultsController as? DigestSearchResultViewController)?.reloadData(of: types[searchBar.selectedScopeButtonIndex], keyword: searchBar.text ?? "")
    }
}

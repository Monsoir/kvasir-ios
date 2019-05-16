//
//  BookProxySessionManagerEx.swift
//  kvasir
//
//  Created by Monsoir on 5/16/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import PKHUD
import Alamofire

extension SessionManager {
    
    /// 处理请求返回的结果
    /// 当请求出错时，同一处理；请求成功时，返回数据
    ///
    /// - Parameter response: 请求返回的响应
    /// - Returns: 请求成功时的数据
    func handleResponse(_ response: DataResponse<Any>) -> [String: Any]? {
        debugPrint(response)
        
        switch response.result {
        case .success(let value):
            let value = value as! [String: Any]
            guard let success = value["success"] as? Bool, success else {
                MainQueue.async {
                    HUD.flash(.labeledError(title: "抱歉", subtitle: value["message"] as? String ?? "查询出问题了"), onView: nil, delay: 1.5, completion: nil)
                }
                return nil
            }
            // success
            return value["data"] as? [String: Any] ?? [:]
        case .failure(let error):
            guard let code = response.response?.statusCode else {
                MainQueue.async {
                    HUD.flash(.labeledError(title: "未知出错", subtitle: nil), onView: nil, delay: 1.5, completion: nil)
                }
                return nil
            }
            switch code {
            case 404:
                MainQueue.async {
                    HUD.flash(.labeledError(title: "请求地址出错", subtitle: nil), onView: nil, delay: 1.5, completion: nil)
                }
            case 500:
                MainQueue.async {
                    HUD.flash(.labeledError(title: "服务出错 500", subtitle: nil), onView: nil, delay: 1.5, completion: nil)
                }
            default:
                Bartendar.handleSorryAlert(message: error.localizedDescription, on: nil)
            }
        }
        return nil
    }
}

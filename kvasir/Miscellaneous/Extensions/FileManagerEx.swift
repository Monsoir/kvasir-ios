//
//  FileManagerEx.swift
//  kvasir
//
//  Created by Monsoir on 6/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension FileManager: MsrCompatible {}
extension MsrWrapper where Base: FileManager {
    /// 创建一个文件夹，若文件夹存在，则跳过
    ///
    /// - Parameter url: 新文件夹的路径
    /// - Returns: true 若成功创建或文件夹已存在，false 若文件夹创建不成功，同名文件已存在，或创建文件夹时出错
    func createDirectoryIfNotExist(_ url: URL) -> Bool {
        let manager = FileManager.default
        
        var isDir: ObjCBool = true
        if manager.fileExists(atPath: url.absoluteString, isDirectory: &isDir) {
            // file exists
            if isDir.boolValue {
                // file exists and file is a directory
                debugPrint("destination exists and is a file")
                return true
            } else {
                // file exists but file is not a directory
                debugPrint("destination directory exists")
                return false
            }
        }
        
        // file not exists
        do {
            try manager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
}

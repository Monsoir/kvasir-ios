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
        var isDir: ObjCBool = true
        if base.fileExists(atPath: url.absoluteString, isDirectory: &isDir) {
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
            try base.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
    /// 清空某个文件夹
    /// - 清空策略：删除原来的文件，再创建
    ///
    /// - Parameter directory: 待清空的文件夹
    /// - Returns: true 清空成功，否则 false
    func restoreDirectory(directory: URL) -> Bool {
        var isDir: ObjCBool = false
        if base.fileExists(atPath: directory.droppedScheme()!.absoluteString, isDirectory: &isDir) {
            // 文件夹存在，删了
            do {
                try base.removeItem(at: directory)
                try base.createDirectory(atPath: directory.droppedScheme()!.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return false
            }
            return true
        } else {
            // 文件夹不存在，创建就是了
            do {
                try base.createDirectory(atPath: directory.droppedScheme()!.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return false
            }
            
            return true
        }
    }
}

//
//  FileHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 12..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

final class FileHelper {
    private static let tempFileDirectoryName = "tmp"
    
    static var fileManager: NSFileManager {
        return NSFileManager.defaultManager()
    }
    static var tempFileDirectory:NSURL {
        createTempFileDirectory()
        return fileNSURLByName(tempFileDirectoryName)
    }
    static var tempFileDirectoryPath:String {
        return tempFileDirectory.path!
    }
    static var documentsURL: NSURL {
        return fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    }
    
    final class func createTempFileDirectory() {
        createDirectoryByName(tempFileDirectoryName)
    }
    
    final class func clearTempFileDirectory() {
        clearDirectory(tempFileDirectoryName)
    }
    
    private final class func createDirectoryByName(dirName: String) {
        if !fileExistsAtPath(dirName) {
            // TODO: pragma clang diagnostic ignored에 대응되는 Swift의 기능이 생기면 변경 필요.
            let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(filePathByName(dirName),
                withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    private final class func clearDirectory(dirName: String) {
        if fileExistsAtPath(dirName) {
            let enumerator = fileManager.enumeratorAtPath(filePathByName(dirName))
            while let fileName = enumerator?.nextObject() as? String {
                let filePath = filePathByName(fileName, inDirectory: dirName)
                // TODO: pragma clang diagnostic ignored에 대응되는 Swift의 기능이 생기면 변경 필요.
                let _ = try? fileManager.removeItemAtPath(filePath)
            }
        }
    }
    
    // MARK: - Basic operations
    
    private final class func fileExistsAtPath(fileName: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(filePathByName(fileName))
    }
    
    private final class func filePathByName(fileName: String, inDirectory dirName: String? = nil) -> String {
        return fileNSURLByName(dirName).URLByAppendingPathComponent(fileName).path!
    }
    
    private final class func filePathByName(fileName: String) -> String {
        return fileNSURLByName(fileName).path!
    }
    
    private final class func fileNSURLByName(fileName: String?) -> NSURL {
        return fileName != nil ? documentsURL.URLByAppendingPathComponent(fileName!) : documentsURL
    }
}

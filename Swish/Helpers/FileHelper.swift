//
//  FileHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 10. 12..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

protocol Directory {
    var name: String? { get }
}

final class Documents: Directory {
    var name: String? {
        return nil
    }
}

enum SubDirectory: Directory {
    case Photos, Temp
    
    var name: String? {
        switch self {
        case Temp:
            return "photos_tmp"
        case Photos:
            return "photos"
        }
    }
}

final class FileHelper {
    private static let documents = Documents()
    
    static var fileManager: NSFileManager {
        return NSFileManager.defaultManager()
    }
    static var tempFileDirectory: NSURL {
        return fileNSURLByName(SubDirectory.Temp)
    }
    static var tempFileDirectoryPath: String {
        return tempFileDirectory.path!
    }
    static var photosDirectory: NSURL {
        return fileNSURLByName(SubDirectory.Photos)
    }
    static var documentsURL: NSURL {
        return fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    }
    static var documentsPath: String {
        return documentsURL.path!
    }
    
    final class func filePathWithName(fileName: String, inDirectory directory: Directory? = documents) -> String {
        if let _ = directory?.name {
            return filePathByName(fileName, inDirectory: directory!)
        } else {
            return filePathByName(fileName)
        }
    }
    
    final class func createPhotosDirectory() {
        createDirectoryByName(subDirectory: .Photos)
    }
    
    final class func createTempFileDirectory() {
        createDirectoryByName(subDirectory: .Temp)
    }
    
    final class func clearTempFileDirectory() {
        clearDirectory(subDirectory: .Temp)
    }
    
    final class func fileExists(fileName: String, inDirectory directory: Directory) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(filePathByName(fileName, inDirectory: directory))
    }
    
    private final class func createDirectoryByName(subDirectory directory: SubDirectory) {
        let dirName = directory.name!
        if !fileExistsAtPath(dirName) {
            // TODO: pragma clang diagnostic ignored에 대응되는 Swift의 기능이 생기면 변경 필요.
            let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(filePathByName(dirName),
                withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    // TODO: 재귀적으로 돌면서 하위 디렉토리도 지울 수 있게 수정하기
    private final class func clearDirectory(subDirectory directory: SubDirectory) {
        let dirName = directory.name!
        if fileExistsAtPath(dirName) {
            let enumerator = fileManager.enumeratorAtPath(filePathByName(dirName))
            while let fileName = enumerator?.nextObject() as? String {
                let filePath = filePathByName(fileName, inDirectory: directory)
                // TODO: pragma clang diagnostic ignored에 대응되는 Swift의 기능이 생기면 변경 필요.
                let _ = try? fileManager.removeItemAtPath(filePath)
            }
        }
    }
    
    // MARK: - Basic operations
    
    private final class func fileExistsAtPath(fileName: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(filePathByName(fileName))
    }
    
    private final class func filePathByName(fileName: String, inDirectory directory: Directory) -> String {
        return fileNSURLByName(directory.name).URLByAppendingPathComponent(fileName).path!
    }
    
    private final class func filePathByName(fileName: String) -> String {
        return fileNSURLByName(fileName).path!
    }
    
    private final class func fileNSURLByName(directory: Directory) -> NSURL {
        return fileNSURLByName(directory.name)
    }
    
    private final class func fileNSURLByName(fileName: String?) -> NSURL {
        return fileName != nil ? documentsURL.URLByAppendingPathComponent(fileName!) : documentsURL
    }
}

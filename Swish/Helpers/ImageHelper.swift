//
//  ImageHelper.swift
//  Swish
//
//  Created by 정동현 on 2015. 9. 23..
//  Copyright © 2015년 Yooii Studios Co., LTD. All rights reserved.
//

import Foundation
import UIKit

final class ImageHelper {
    enum Format { case PNG }
    
    private static let tempImageFileNamePrefix = "tmp"
    
    static var tempImagePaths: [String] {
        var index = 0
        var paths = [String]()
        while true {
            let tempImageFileName = "\(tempImageFileNamePrefix)\(index++)"
            if !FileHelper.fileExists(tempImageFileName, inDirectory: SubDirectory.TempPhotos) {
                break
            }
            paths.append(tempImageFileName)
        }
        
        return paths
    }
    
    static var tempImages: [UIImage] {
        var images = [UIImage]()
        for tempImagePath in tempImagePaths {
            let tmpFilePath = FileHelper.filePathWithName(tempImagePath, inDirectory: SubDirectory.TempPhotos)
            if let image = UIImage(contentsOfFile: tmpFilePath) {
                images.append(image)
            }
        }
        
        return images
    }
    
    final class func base64EncodedStringWith(image: UIImage) -> String! {
        return UIImagePNGRepresentation(image)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    final class func saveImage(image: UIImage) -> String {
        FileHelper.createPhotosDirectory()
        
        let fileName = "\(NSDate().timeIntervalSince1970)"
        let imagePath = FileHelper.filePathWithName(fileName, inDirectory: SubDirectory.Photos)
        saveImage(image, intoPath: imagePath)
        
        return fileName
    }
    
    final class func moveTempImageToPhotosDirectory(imageName: String) -> String {
        let imagePath = FileHelper.filePathWithName(imageName, inDirectory: SubDirectory.TempPhotos)
        return saveImage(UIImage(contentsOfFile: imagePath)!)
    }
    
    final class func clearAndSaveTempImage(image: UIImage) {
        clearAndSaveTempImages([image])
    }
    
    final class func clearAndSaveTempImages(images: [UIImage]) -> [String] {
        FileHelper.createTempPhotosFileDirectory()
        FileHelper.clearTempPhotosFileDirectory()
        var index = 0
        var fileNames = [String]()
        for image in images {
            let tmpFileName = "\(tempImageFileNamePrefix)\(index++)"
            let tmpFilePath = FileHelper.filePathWithName(tmpFileName, inDirectory: SubDirectory.TempPhotos)
            saveImage(image, intoPath: tmpFilePath)
            fileNames.append(tmpFileName)
        }
        
        return fileNames
    }
    
    private class func saveImage(image: UIImage, intoPath path: String, inFormat format: Format = .PNG) {
        switch format {
        case .PNG:
            UIImagePNGRepresentation(image)!.writeToFile(path, atomically: true)
        }
    }
}

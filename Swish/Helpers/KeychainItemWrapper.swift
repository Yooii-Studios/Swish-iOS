// KeychainItemWrapper.swift
//
// Copyright (c) 2015 Mihai Costea (http://mcostea.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Security

class KeychainItemWrapper {
    
    var genericPasswordQuery = [String: AnyObject]()
    var keychainItemData = [String: AnyObject]()
    
    var values = [String: AnyObject]()
    
    init(identifier: String, accessGroup: String?) {
        self.genericPasswordQuery[kSecClass as String] = kSecClassGenericPassword
        self.genericPasswordQuery[kSecAttrGeneric as String] = identifier
        
        if (accessGroup != nil) {
            if TARGET_IPHONE_SIMULATOR != 1 {
                self.genericPasswordQuery[kSecAttrAccessGroup as String] = accessGroup
            }
        }
        
        self.genericPasswordQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        self.genericPasswordQuery[kSecReturnAttributes as String] = kCFBooleanTrue
        
        let tempQuery = self.genericPasswordQuery as NSDictionary
        var outDict: AnyObject?
        
        let copyMatchingResult = SecItemCopyMatching(tempQuery as CFDictionary, &outDict)
        
        if copyMatchingResult != noErr {
            self.resetKeychain()
            
            self.keychainItemData[kSecAttrGeneric as String] = identifier
            if (accessGroup != nil) {
                if TARGET_IPHONE_SIMULATOR != 1 {
                    self.keychainItemData[kSecAttrAccessGroup as String] = accessGroup
                }
            }
        } else {
            self.keychainItemData = self.secItemDataToDict(outDict as! [String: AnyObject])
        }
    }
    
    subscript(key: String) -> AnyObject? {
        get {
            return self.values[key]
        }
        
        set(newValue) {
            self.values[key] = newValue
            self.writeKeychainData()
        }
    }
    
    func resetKeychain() {
        
        if !self.keychainItemData.isEmpty {
            let tempDict = self.dictToSecItemData(self.keychainItemData)
            var junk = noErr
            junk = SecItemDelete(tempDict as CFDictionary)
        
            assert(junk == noErr || junk == errSecItemNotFound, "Failed to delete current dict")
        }
        
        self.keychainItemData[kSecAttrAccount as String] = ""
        self.keychainItemData[kSecAttrLabel as String] = ""
        self.keychainItemData[kSecAttrDescription as String] = ""
        
        self.keychainItemData[kSecValueData as String] = ""
    }
    
    private func secItemDataToDict(data: [String: AnyObject]) -> [String: AnyObject] {
        var returnDict = [String: AnyObject]()
        for (key, value) in data {
            returnDict[key] = value
        }
        
        returnDict[kSecReturnData as String] = kCFBooleanTrue
        returnDict[kSecClass as String] = kSecClassGenericPassword
        
        var passwordData: AnyObject?
        
        // We could use returnDict like the Apple example but this crashes the app with swift_unknownRelease
        // when we try to access returnDict again
        let queryDict = returnDict
        
        let copyMatchingResult = SecItemCopyMatching(queryDict as CFDictionary, &passwordData)
        
        if copyMatchingResult != noErr {
            assert(false, "No matching item found in keychain")
        } else {
            let retainedValuesData = passwordData! as! NSData
            let val = try! NSJSONSerialization.JSONObjectWithData(retainedValuesData, options: NSJSONReadingOptions()) as! [String: AnyObject]
            
            returnDict.removeValueForKey(kSecReturnData as String)
            returnDict[kSecValueData as String] = val
            
            self.values = val
        }
        
        return returnDict
    }
    
    private func dictToSecItemData(dict: [String: AnyObject]) -> [String: AnyObject] {
        var returnDict = [String: AnyObject]()
        for (key, value) in self.keychainItemData {
            returnDict[key] = value
        }
        
        returnDict[kSecClass as String] = kSecClassGenericPassword
        
        returnDict[kSecValueData as String] = try! NSJSONSerialization.dataWithJSONObject(self.values, options: NSJSONWritingOptions())
        
        return returnDict
    }
    
    private func writeKeychainData() {
        var attributes: AnyObject?
        var updateItem: [String: AnyObject]?
        
        var result: OSStatus?
        
        let copyMatchingResult = SecItemCopyMatching(self.genericPasswordQuery as CFDictionary, &attributes)
        
        if copyMatchingResult != noErr {
            result = SecItemAdd(self.dictToSecItemData(self.keychainItemData), nil)
            assert(result == noErr, "Failed to add keychain item")
        } else {
            updateItem = [String: AnyObject]()
            for (key, value) in attributes! as! [String: AnyObject] {
                updateItem![key] = value
            }
            updateItem![kSecClass as String] = self.genericPasswordQuery[kSecClass as String]
            
            var tempCheck = self.dictToSecItemData(self.keychainItemData)
            tempCheck.removeValueForKey(kSecClass as String)
            
            if TARGET_IPHONE_SIMULATOR == 1 {
                tempCheck.removeValueForKey(kSecAttrAccessGroup as String)
            }
            
            result = SecItemUpdate(updateItem! as CFDictionary, tempCheck as CFDictionary)
            assert(result == noErr, "Failed to update keychain item")
        }
    }
}
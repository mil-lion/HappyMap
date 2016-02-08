//
//  CommonCrypt.swift
//  HappyMap
//
//  Created by Игорь Моренко on 08.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import Foundation

//#import <CommonCrypto/CommonCrypto.h> add to Objective-C Bridge Header File
/*
enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCEnum() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
*/

extension NSDate {
    
    func string(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.stringFromDate(self)
    }
}

extension Int {
    func hexedString() -> String {
        return String(format:"%02x", self)
    }
}

extension NSData {
    func hexedString() -> String {
        var string = String()
        for i in UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(bytes), count: length) {
            string += Int(i).hexedString()
        }
        return string
    }
    
    func MD5() -> NSData {
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
        return NSData(data: result)
    }
    
    func SHA1() -> NSData {
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        CC_SHA1(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
        return NSData(data: result)
    }
}

extension String {
    func MD5() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.MD5().hexedString()
    }
    
    func SHA1() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.SHA1().hexedString()
    }
}

/*
// Swift 2.0, minor warning on Swift 1.2
func md5(string string: String) -> String {
    var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
    if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
        CC_MD5(data.bytes, CC_LONG(data.length), &digest)
    }
    
    var digestHex = ""
    for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
        digestHex += String(format: "%02x", digest[index])
    }
    
    return digestHex
}
//Test:
let digest = md5(string:"Hello")
print("digest: \(digest)")
*/

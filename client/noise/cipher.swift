//
//  cipher.swift
//  noise
//
//  Created by Jae Shin on 8/24/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import Foundation
import CryptoSwift

class Cipher: NSObject {
    
    let key = "secret0key000000" // 16 or 32 bytes (our sharedSecret should be in UInt32
    let iv = "0123456789012345" // 16 or 32 bytes
    
    let str = "in the jungle, the mighty jungle"
    var strToUInt8Array: Array<UInt8> = []
    
    //let message: Array<UInt8> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var encrypted: Array<UInt8> = []
    var decrypted: Array<UInt8> = []
    
    func test() -> Void {
        print(str.utf8)
    }
    
    func encryptMessage() -> Void {
        for codeUnit in str.utf8 {
            strToUInt8Array.append(codeUnit)
        }
        encrypted = try! ChaCha20(key: self.key, iv: self.iv)!.encrypt(strToUInt8Array)
        print("encrypted:", encrypted)
        decryptMessage()
    }
    
    func decryptMessage() -> Void {
        decrypted = try! ChaCha20(key: self.key, iv: self.iv)!.decrypt(encrypted)
        print("decrypted UInt8 Array:", decrypted)
        
        let data = NSData(bytes: decrypted)
        
        // returns Optional, need to unwrap
        let decryptedMessage = String(data: data, encoding: NSUTF8StringEncoding)!
        print("decrypted message is:", decryptedMessage)
    }
    
    // let encrypted: Array<UInt8> = ChaCha20(key: key, iv: iv).encrypt(message)
    // let decrypted: Array<UInt8> = ChaCha20(key: key, iv: iv).decrypt(encrypted)
    
}

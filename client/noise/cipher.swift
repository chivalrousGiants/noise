//
//  cipher.swift
//  noise
//
//  Created by Jae Shin on 8/24/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import Foundation
import CryptoSwift
import Locksmith

class Cipher: NSObject {
    
    let key = "secret0key000000" // 16 (128 bit) or 32 bytes (256 bits) (our sharedSecret is in UInt32)
    
    var sharedSecret: String = ""

    let iv = "01234567" // 8 or 16 bytes (TODO: randomize)
    
    let str = "in the jungle, the mighty jungle"
    var strToUInt8Array: Array<UInt8> = []

    var encrypted: Array<UInt8> = []
    var decrypted: Array<UInt8> = []
    
    func test() -> Void {
        print(str.utf8)
    }
    
    func encryptMessage() -> Void {
        //print("cipher locksmith", Locksmith.loadDataForUserAccount("noise:1")!)
        //print("cipher locksmith 2", Locksmith.loadDataForUserAccount("noise:1")!["sharedSecret"]!)
        
        sharedSecret = String(Locksmith.loadDataForUserAccount("noise:1")!["sharedSecret"]!)
        
        strToUInt8Array = [UInt8](str.utf8)
        
        encrypted = try! ChaCha20(key: self.sharedSecret, iv: self.iv)!.encrypt(strToUInt8Array)
        print("encrypted:", encrypted)
        decryptMessage()
    }
    
    func decryptMessage() -> Void {
        decrypted = try! ChaCha20(key: self.sharedSecret, iv: self.iv)!.decrypt(encrypted)
        print("decrypted UInt8 Array:", decrypted)
        
        let data = NSData(bytes: decrypted)
        
        // returns Optional, need to unwrap
        let decryptedMessage = String(data: data, encoding: NSUTF8StringEncoding)!
        print("decrypted message is:", decryptedMessage)
    }
    
    // let encrypted: Array<UInt8> = ChaCha20(key: key, iv: iv).encrypt(message)
    // let decrypted: Array<UInt8> = ChaCha20(key: key, iv: iv).decrypt(encrypted)
    
}

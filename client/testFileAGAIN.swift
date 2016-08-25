//
//  testFileAGAIN.swift
//  noise
//
//  Created by Hannah Brannan on 8/24/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//
//
//import Foundation
//import RealmSwift
//import CryptoSwift
//import Locksmith
//
//class test: UIViewController {
//    let realm = try! Realm()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        letThemEatCake()
//
//    }
//    
//    func letThemEatCake () {
//        ///make a realm message
//        var message = realm.objects(Message)[0]["body"]
//        print("message is")
//        ///make na iv w arc4random
//        var initializationVector = String(arc4random())
//        //get sharedsecret from keychain
//        //this prbly has to be a certain byte size/rate
//        var key = String(Locksmith.loadDataForUserAccount("noise:4"))
//        
//        let encrypted: Array<UInt8> = ChaCha20!(key: key, iv: initializationVector).encrypt(message)
//        let decrypted: Array<UInt8> = ChaCha20!(key: key, iv: initializationVector).decrypt(encrypted)
//        print("decrypted mssg is ", decrypted)
//    }
//    
//}
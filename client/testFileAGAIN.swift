//
//  testFileAGAIN.swift
//  noise
//
//  Created by Hannah Brannan on 8/24/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//
//
import Foundation
import RealmSwift
import CryptoSwift
import Locksmith


class test: UIViewController {
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
//        letThemEatCake()
        generateRandomPrime()

    }
    
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
////        let encrypted: Array<UInt8> = ChaCha20!(key: key, iv: initializationVector).encrypt(message)
////        let decrypted: Array<UInt8> = ChaCha20!(key: key, iv: initializationVector).decrypt(encrypted)
////        print("decrypted mssg is ", decrypted)
//    }
    func printPrime (val: AnyObject){
        print(val)
    }
    
    

    func generateRandomPrime() {

        let bigNum = BN_new()
        let prime = BN_generate_prime(bigNum,16,0,nil,nil,nil,nil)
        print(String(prime))
    }
    
}




/* NOTES OF DEATH!!
 UnsafeMutablePointer<bignum_st>
 UnsafeMutablePointer<BIGNUM>
 Int32??
 //expected argument type UnsafeMutablePointer<BIGNUM>  aka UnsafeMutablePointer<bignum_st>
 
 BN_generate_prime(NULL, bits, safe, NULL, NULL, prime_status, NULL)
 --Swift hass no NULL equivalent. nil does not pass param specifications.
 */


//If you're dynamically allocating a BIGNUM object, OpenSSL provides a function that allocates and initializes in one fell swoop:


//let BIGNUM* prime = BN_new();
//
//  KeyUtility.swift
//  noise
//
//  Created by Hannah Brannan on 8/17/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import Foundation
import Locksmith

extension Int {
    
    func generateRandomPrime () -> UnsafeMutablePointer<bignum_st> {
        let bigNum = BN_new()
        let prime = BN_generate_prime(bigNum,16,0,nil,nil,nil,nil)
       //print("PRIME INFO as unsafeMutablePointer--16 bits", prime, prime.dynamicType)
        return prime
    }
    
    func gCreate () -> UInt32 {
        let g = UnsafePointer<UInt32>(generateRandomPrime()).memory
       // print("g is", g)
        return g
    }
    func pCreate () -> UInt32 {
        return UnsafePointer<UInt32>(generateRandomPrime()).memory
    }
    func aAliceCreate ( ) -> UInt32 {
        return UnsafePointer<UInt32>(generateRandomPrime()).memory
    }
    func bBobCreate () -> UInt32 {
        return UnsafePointer<UInt32>(generateRandomPrime()).memory
    }
    func eCreate (g: UInt32, mySecret: UInt32, p: UInt32) -> UInt32 {
        return (g^mySecret) % p
    }
    func computeSecret (foreignE: UInt32, mySecret: UInt32, p:UInt32) -> UInt32 {
        return (foreignE^mySecret) % p
    }
    
    func alicify (userID:AnyObject, friendID:AnyObject) -> Dictionary<String,AnyObject> {
        //compute DHX numbers
        let g_Alice = 666.gCreate()
        let p_Alice = 666.pCreate()
        let a_Alice = 666.aAliceCreate()
        let E_Alice = 666.eCreate(g_Alice, mySecret: a_Alice, p: p_Alice)
        
        //build Alice
        var Alice : [String:AnyObject] = [:]
        Alice["userID"] = userID
        Alice["g"] = String(g_Alice)
        Alice["p"] = String(p_Alice)
        Alice["E"] = String(E_Alice)
        Alice["friendID"] = friendID
    
    
        //pass dhX vals that Alice needs to access later into her keychain
        var AliceKeys : [String:AnyObject] = [:]
        AliceKeys["a_Alice"] = String(a_Alice)
        AliceKeys["p"] = String(p_Alice)
        AliceKeys["E"] = String(E_Alice)
        AliceKeys["friendID"] = friendID
        
        aliceKeyChainPt1(AliceKeys)
 
        
        //2) encrypt values
        print("Alice in alicify \(Alice)")
        return Alice
    }
    func bobify (userID:AnyObject, friendID:AnyObject, E_Alice:AnyObject, p:AnyObject, g:AnyObject) -> Dictionary<String,AnyObject> {
        //compute DHX numbers
        let b_Bob = 666.bBobCreate()
        let g_computational = UInt32(g as! String)
        let E_Alice_computational = UInt32(E_Alice as! String)
        let p_computational = UInt32(p as! String)
        let E_Bob = 666.eCreate(g_computational!, mySecret: b_Bob, p: p_computational!)
        let sharedSecret = 666.computeSecret(E_Alice_computational!, mySecret: b_Bob, p: p_computational!)
        //print("sharedSecret izzzzz \(sharedSecret)")
        
        //pass values to handle encryption into keychain
        var BobKeys : [String:AnyObject] = [:]
        BobKeys["E"] = String(E_Bob)
        BobKeys["sharedSecret"] = String(sharedSecret)
        BobKeys["friendID"] = friendID
        bobKeyChain(BobKeys)

        
        //pass values to handle diffie hellman key exchange to Redis
        var Bob : [String:AnyObject] = [:]
        Bob["userID"] = userID
        Bob["E"] = String(E_Bob) //encrypt?
        Bob["friendID"] = friendID
        //Bob["p"] = p //encrypt?

        return Bob
    }
    func aliceKeyChainPt1 (alice: Dictionary<String,AnyObject>) -> Void {
        //TODO: create alice user account i keychain
        //store bobKeys in keychain : need privateSecret*, E, p
        do {
            try Locksmith.updateData(alice, forUserAccount: "noise:\(alice["friendID"])")
        } catch {
           //print("could not save alice data in keychain")
        }
        //let dictionary = Locksmith.loadDataForUserAccount("noise:\(alice["friendID"])")
        //print("Alice pt1:\(alice["friendID"]) dictionary is \(dictionary)")
    }
    

    func aliceKeyChainPt2 (alice: Dictionary<String,AnyObject>) -> Void {
        //add or overwrite alice keys in keychain : need E, sharedSecret
        do {
            try Locksmith.updateData(alice, forUserAccount: "noise:\(alice["friendID"])")
        } catch {
           // print("could not amend alice data in keychain")
        }
        let dictionary = Locksmith.loadDataForUserAccount("noise:\(alice["friendID"])")
        //print("Alice pt2:\(alice["friendID"]) dictionary is \(dictionary)")
    }
    
    func bobKeyChain (bob: Dictionary<String,AnyObject>) -> Void {
        //store bobKeys in keychain : need E, sharedSecret
        do {
            try Locksmith.updateData(bob, forUserAccount: "noise:\(bob["friendID"])")
        } catch {
          //  print ("could not save bob data in keychain")
        }
        let dictionary = Locksmith.loadDataForUserAccount("noise:\(bob["friendID"])")
        //print("BobKeyChain dictionary is \(dictionary)")
    }
    
}
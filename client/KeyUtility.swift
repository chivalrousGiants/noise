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
    func gCreate () -> UInt32 {
        return arc4random()
    }
    func pCreate () -> UInt32 {
        return arc4random()
    }
    func aAliceCreate ( ) -> UInt32{
        return arc4random()
    }
    func bBobCreate () -> UInt32 {
        return arc4random()
    }
    func eCreate (g: UInt32, mySecret: UInt32, p: UInt32) -> UInt32 {
        return (g^mySecret) % p
    }
    func computeSecret (foreignE: UInt32, mySecret: UInt32, p:UInt32) -> UInt32 {
        return (foreignE^mySecret) % p
    }
    func alicify (username:AnyObject, friendname:AnyObject) -> Dictionary<String,AnyObject> {
        //compute DHX numbers
        let g_Alice = 666.gCreate()
        let p_Alice = 666.pCreate()
        let a_Alice = 666.aAliceCreate()
        let E_Alice = 666.eCreate(g_Alice, mySecret: a_Alice, p: p_Alice)
        
        //build Alice
        var Alice : [String:AnyObject] = [:]
        Alice["username"] = username
        Alice["g"] = String(g_Alice)
        Alice["p"] = String(p_Alice)
        Alice["E"] = String(E_Alice)
        Alice["friendname"] = friendname
        
        //pass dhX vals that Alice needs to access later into her keychain
        var AliceKeys : [String:AnyObject] = [:]
        AliceKeys["a_Alice"] = String(a_Alice)
        AliceKeys["p"] = String(p_Alice)
        AliceKeys["E"] = String(E_Alice)
        aliceKeyChainPt1(AliceKeys)
        
        //2) encrypt values
        
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
        print("sharedSecret izzzzz \(sharedSecret)")
        
        //pass values to handle encryption into keychain
        var BobKeys : [String:AnyObject] = [:]
        BobKeys["E"] = String(E_Bob)
        BobKeys["sharedSecret"] = String(sharedSecret)
        bobKeyChain(BobKeys)

        
        //pass values to handle diffie hellman key exchange to Redis
        var Bob : [String:AnyObject] = [:]
        Bob["userID"] = userID
        Bob["E"] = String(E_Bob) //encrypt?
        Bob["friendID"] = friendID
        Bob["p"] = p //encrypt?

        return Bob
    }
    func aliceKeyChainPt1 (alice: Dictionary<String,AnyObject>) -> Void {
        //TODO: create alice user account i keychain
        //store bobKeys in keychain : need privateSecret*, E, p
        do {
            try Locksmith.saveData(alice, forUserAccount: "Alice_noise1")
        } catch {
           print("could not save alice data in keychain")
        }
        let dictionary = Locksmith.loadDataForUserAccount("Alice_noise1")
        print("Alice pt1 dictionary is \(dictionary)")
        print("Alice pt1 aAlice is \(dictionary!["a_Alice"])")
    }
    func aliceKeyChainPt2 (alice: Dictionary<String,AnyObject>) -> Void {
        //add or overwrite alice keys in keychain : need E, sharedSecret
        do {
            try Locksmith.saveData(alice, forUserAccount: "Alice_noise2")
        } catch {
            print("could not amend alice data in keychain")
        }
        let dictionary = Locksmith.loadDataForUserAccount("Alice_noise2")
        print("Alice pt2 dictionary is \(dictionary)")
        print("Alice pt2 sharedSecret is \(dictionary!["sharedSecret"])")
    }
    func bobKeyChain (bob: Dictionary<String,AnyObject>) -> Void {
        //TODO: create bob user account in keychain
        //store bobKeys in keychain : need E, sharedSecret
        do {
            try Locksmith.saveData(bob, forUserAccount: "Bob_noise")
        } catch {
            print ("could not save bob data in keychain")
        }
        let dictionary = Locksmith.loadDataForUserAccount("Bob_noise")
        print("Bob dictionary is \(dictionary)")
    }
    
}
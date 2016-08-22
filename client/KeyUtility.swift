//
//  KeyUtility.swift
//  noise
//
//  Created by Hannah Brannan on 8/17/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import Foundation

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
        
        //TODO: pass computed value directly into
        //1) keychain
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
        
        //TODO: pass computed value directly into
        //1) keychain
        //2) encrypt values
        
        //Bob the builder
        var Bob : [String:AnyObject] = [:]
        Bob["userID"] = userID
        Bob["E"] = String(E_Bob)
        Bob["friendID"] = friendID
        Bob["p"] = p 

        return Bob
    }
}
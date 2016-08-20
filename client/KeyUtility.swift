//
//  KeyUtility.swift
//  noise
//
//  Created by Hannah Brannan on 8/17/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import Foundation

//TODO: revisit, extend security featuers of p,g,a,b generation
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
        let g_Alice = 666.gCreate()                    //TODO: explore: information loss from uint to string?
        let p_Alice = 666.pCreate()
        let a_Alice = 666.aAliceCreate()
        let E_Alice = 666.eCreate(g_Alice, mySecret: a_Alice, p: p_Alice)
        
        //TODO:insert a_Alice, p_alice, E_Alice into user keychain
        
        //create an Alice obj that we will pass through sockets to the server
        //TODO: layer cryptoSwift encryption over secret and pubKey
        var Alice : [String:AnyObject] = [:]
        Alice["username"] = username
        Alice["g"] = String(g_Alice)
        Alice["p"] = String(p_Alice)
        Alice["E"] = String(E_Alice)
        Alice["friendname"] = friendname
        
        return Alice
    }
    func bobify (userID:AnyObject, friendID:AnyObject, E_Alice:String, p:String, g:String) -> Dictionary<String,AnyObject> {
        //compute DHX numbers
        let b_Bob = 666.bBobCreate()
        let g_computational = UInt32(g)
        let E_Alice_computational = UInt32(E_Alice)
        let p_computational = UInt32(p)
        
        let E_Bob = 666.eCreate(g_computational!, mySecret: b_Bob, p: p_computational!)
        let sharedSecret = 666.computeSecret(E_Alice_computational!, mySecret: b_Bob, p: p_computational!)
        print(sharedSecret)
        //TODO:insert b_Bob, E_Bob, sharedSecret into keychain
        
        //create a Bob obj that we will pass through sockets to the server
        //TODO: layer cryptoSwift encryption over secret and pubKey
        var Bob : [String:AnyObject] = [:]
        Bob["userID"] = userID
        Bob["E"] = String(E_Bob)
        Bob["friendname"] = friendID
        
        return Bob
    }
}
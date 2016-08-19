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
   /* func alicify (username:String, friendName:String) -> Dictionary<String,String> {
        //TODO: move functionality into here once you have testable product
        return ["test", "test"]
    }
    //func bobify (username:String, friendName:String) -> Dictionary<String,String> {
        //TODO: move functionality into here once you have testable product
    }
    //TODO: layer cryptoSwift encryption over secret and pubKey
 */
}
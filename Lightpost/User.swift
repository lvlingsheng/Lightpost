//
//  User.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/14.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit

var _currrentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLogoutNotification = "userDidLogoutNotification"
let userDidLoginNotification = "userDidLoginNotification"

class User: NSObject {
    var name:String?
    var screenname:String?
    var profileImageURL:String?
    var profilelargeImageURL:String?
    var tagline:String?
    var dictionary:NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary=dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageURL = dictionary["profile_image_url_https"] as? String
        profilelargeImageURL = profileImageURL!.stringByReplacingOccurrencesOfString("normal", withString: "bigger", options: NSStringCompareOptions.LiteralSearch, range: nil)

        tagline = dictionary["description"] as? String
    }
    
    
    func logout(){
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User? {
        get {
        if _currrentUser == nil {
        //logged out or just boot up
            let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
            if data != nil {
                let dictionary: NSDictionary?
                do {
                    try dictionary = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                    _currrentUser = User(dictionary: dictionary!)
                } catch {
                    print(error)
                }
            }
        }
            return _currrentUser
        }
        
        
        set(user) {
            _currrentUser = user
            //User need to implement NSCoding; but, JSON also serialized by default
            if let _ = _currrentUser {
                var data: NSData?
                do {
                    try data = NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: .PrettyPrinted)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch {
                    print(error)
                }
            }
        }
    }

}

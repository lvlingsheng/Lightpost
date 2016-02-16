//
//  User.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/14.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit

class User: NSObject {
    var name:String?
    var screenname:String?
    var profileImageURL:String?
    var tagline:String?
    var dictionary:NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary=dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageURL = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
        
    }
}

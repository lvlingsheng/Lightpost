//
//  ViewController.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/13.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ViewController: UIViewController {

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: AnyObject) {
//        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "Lightpostlls://oauth"), scope: nil, success: (requestToken:BDBOAuth1Credential!) -> Void in print("Got the request token"))!, failure: ((error: NSError!) -> Void in print("failed to get request token"))!
        
        TwitterClient.sharedInstance.loginWithCompletion(){
            (user:User?, error: NSError?) in
            if user != nil {
            
            }else{
            
            }
        }

    }

}


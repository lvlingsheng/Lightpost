//
//  composeViewController.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/25.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit

class composeViewController: UIViewController,UITextViewDelegate {


    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var wordRemain: UILabel!
    
    var talkto:Tweet!
    var maxword = 140
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.becomeFirstResponder()
        // Do any additional setup after loading the view.
        if talkto != nil {
            wordRemain.text = "\(maxword - textView.text.characters.count)"
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView,
        shouldChangeTextInRange range: NSRange,
        replacementText text: String) -> Bool{
            return textView.text.characters.count + (text.characters.count - range.length) <= maxword
    }
    
    func textViewDidChange(textView: UITextView) {
        let charCount = textView.text.characters.count
        print(charCount)
        if charCount > 0 {
            wordRemain.text = "\(maxword - charCount)"
        } else {
            wordRemain.text = "\(maxword)"
        }
        
    }
    
    @IBAction func onSend(sender: AnyObject) {
        var params = [String : AnyObject]()
        params["status"] = textView.text
        
        if talkto != nil {
            params["in_reply_to_status_id"] = talkto!.id!
        }
        
        TwitterClient.sharedInstance.tweetWithParams(params as NSDictionary) { (tweet, error) -> () in
            NSNotificationCenter.defaultCenter().postNotificationName("newTweet", object: nil, userInfo: ["new_tweet" : tweet!])
        }
        
//        self.dismissViewControllerAnimated(true) { () -> Void in
//            print("dismiss from tweet")
//        }
        
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

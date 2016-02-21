//
//  TweetsCell.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/19.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit

class TweetsCell: UITableViewCell {

    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var RetweetNumber: UILabel!
    @IBOutlet weak var FavNumber: UILabel!
    @IBOutlet weak var TweetTime: UILabel!
    @IBOutlet weak var UserTweets: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    var didRetweet = false
    var didTouchFavourite = false
    var tweetId: Int!
    var original_tweet_id:Int!
    var retweet_id: Int!
    var original_tweet: NSDictionary!
    var tweet: Tweet! {
        didSet {
            tweetId = tweet.id
            
            let tempurlstring = tweet.user?.profilelargeImageURL
            //print(tempurlstring)
            let avatarURL = NSURL(string: tempurlstring!)
            print(avatarURL)
            self.userAvatar.setImageWithURL(avatarURL!)
            self.userAvatar.layer.cornerRadius=25
            self.userAvatar.layer.masksToBounds=true
            self.userName.text = tweet.user?.name
            self.UserTweets.text = tweet.text
            self.didRetweet=tweet.didretweeted!
            self.didTouchFavourite = tweet.didfav!
            if(didTouchFavourite == true){
                self.favButton.setImage(UIImage(named: "like-action-on-red"), forState: .Normal)
            }else{
                self.favButton.setImage(UIImage(named: "like-action-off"), forState: .Normal)
            }
            if(didRetweet == true){
                self.retweetButton.setImage(UIImage(named: "retweet-action-on-green"), forState: .Normal)
            }else{
                self.retweetButton.setImage(UIImage(named: "retweet-action_default"), forState: .Normal)
            }
            
            
            let data = "\((tweet.createAt)!)"

            let filtered = data.stringByReplacingOccurrencesOfString(" +0000", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            self.TweetTime.text = filtered
            
            
            //print("RetweetNumber \(tweets![indexPath.row].RetweetNumber)")
            self.RetweetNumber.text = String(tweet.RetweetNumber!)
            //print("favourite \(tweets![indexPath.row].favNumber)")
            self.FavNumber.text = String(tweet.favNumber!)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stackView.arrangedSubviews.last?.hidden = true
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        UIView.animateWithDuration(0.5,
//            delay: 0,
//            usingSpringWithDamping: 1,
//            initialSpringVelocity: 1,
//            options: UIViewAnimationOptions.CurveEaseIn,
//            animations: { () -> Void in
//                self.stackView.arrangedSubviews.last?.hidden = !selected
//            },
//            completion: nil)
//        print("changed+\(selected)")
//        // Configure the view for the selected state
//    }
    
    func changeCellStatus(selected: Bool){
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                self.stackView.arrangedSubviews.last?.hidden = !selected
            },
            completion: nil)
    }
    
    @IBAction func onRetweets(sender: AnyObject) {
        if !didRetweet {
            //perform retweet logics
            TwitterClient.sharedInstance.retweetStatus(tweetId) { error in
                self.tweet.RetweetNumber! += 1
                self.retweetButton.setImage(UIImage(named: "retweet-action-on-green"), forState: .Normal)
                self.RetweetNumber.text = "\(self.tweet.RetweetNumber!)"
                self.didRetweet = true
            }
        } else {
            // step 1
            if(didRetweet==false){
                print("Haved retweeted yet")
            }
            // you cannot unretweet a tweet that has not retweeted
            else if (tweet.retweetedstatus == nil){
                original_tweet_id = tweet.id
            }else{ // tweet was itself a retweet
                original_tweet_id = tweet.retweetedstatus!["id"] as! Int
                //print(tweet.retweetedstatus)
                //print(original_tweet_id)
            }
            
            // step 2
            
            TwitterClient.sharedInstance.showStatus(original_tweet_id!, completion: { (status, error) -> () in
                self.original_tweet = status
                print(self.original_tweet["current_user_retweet"]!["id"])
                self.retweet_id = self.original_tweet["current_user_retweet"]!["id"] as! Int
                print(self.retweet_id)
                
                TwitterClient.sharedInstance.unretweetStatus(self.retweet_id, completion: { (error) -> () in
                    self.tweet.RetweetNumber! -= 1
                    self.retweetButton.setImage(UIImage(named: "retweet-action_default"), forState: .Normal)
                    self.RetweetNumber.text = "\(self.tweet.RetweetNumber!)"
                    self.didRetweet = false
                })
            })
            
            //let retweet_id = full_tweet.current_user_retweet.id_str
            
            // step 3
            //POST("https://api.twitter.com/1.1/statuses/destroy/" + retweet_id + ".json")
            
            
            //un retweet, if successful, decrement
            

        }
    }
    @IBAction func onFav(sender: AnyObject) {
        if !didTouchFavourite {
            //call favourite
            TwitterClient.sharedInstance.favoriteStatus(tweetId) { errror in
                self.didTouchFavourite = true
                self.tweet.favNumber! += 1
                self.favButton.setImage(UIImage(named: "like-action-on-red"), forState: .Normal)
                self.FavNumber.text = "\(self.tweet.favNumber!)"
            }
        } else {
            //call unfavouriteStatus
            TwitterClient.sharedInstance.unfavoriteStatus(tweetId) { error in
                self.didTouchFavourite = false
                self.tweet.favNumber! -= 1
                self.favButton.setImage(UIImage(named: "like-action-off"), forState: .Normal)
                self.FavNumber.text = "\(self.tweet.favNumber!)"
            }
        }

    }

}

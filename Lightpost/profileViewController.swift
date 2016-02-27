//
//  profileViewController.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/26.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

class profileViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var UserIDLabel: UILabel!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var avatarImage:UIImageView!
    @IBOutlet var header:UIView!
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var headerImageView:UIImageView!
    @IBOutlet var headerBlurImageView:UIImageView!
    var blurredHeaderImageView:UIImageView?
    
    var user:User!
    var backimage:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        print(user.name)
        print(user.numFollowers)
//        if user.profileBackgroundUrl != nil {
//            let url = NSURL(string: user.profileBackgroundUrl!)
//            let imageData = NSData(contentsOfURL: url!)
//            headerImageView.image = UIImage(data: imageData!)
//            
////            let backgroundurl = NSURL(string: user.profileBackgroundUrl!)!
////            print(backgroundurl)
////            headerImageView.setImageWithURL(backgroundurl)
//        } else {
//            let bgColor = UIColorFromRGB("0xFF\(headerImageView.backgroundColor)")
//            headerImageView.backgroundColor = bgColor
//        }


        
        // Header - Blurred Image
        
        UserNameLabel.text = user.name
        headerLabel.text = user.name
        UserIDLabel.text = "@\(user.screenname!)"
        avatarImage.setImageWithURL(NSURL(string: user.profilelargeImageURL!)!)
        avatarImage.layer.cornerRadius = 10.0
        avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImage.layer.borderWidth = 3.0
        discriptionLabel.text=user.tagline
        followerLabel.text="\(user.numFollowers!)"
        followingLabel.text="\(user.numFollowing!)"

    }
    

    
    override func viewDidAppear(animated: Bool) {
        
        // Header - Image

        //profileDescription.text = user.tagline
        //numFollowing.text = String(user.numFollowing!)
        //numFollowers.text = String(user.numFollowers!)
        //numTweets.text = String(user.numTweets!)

        
        let url = NSURL(string: user.profileBackgroundUrl!)
        let imageData = NSData(contentsOfURL: url!)
        headerImageView = UIImageView(frame: header.bounds)
        headerImageView?.image = UIImage(data: imageData!)
        backimage = UIImage(data: imageData!)!
        headerImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        headerBlurImageView = UIImageView(frame: header.bounds)
        
        headerBlurImageView?.image = UIImage(named: "header_bg")!.blurredImageWithRadius(10, iterations: 20, tintColor: UIColor.clearColor())
        headerBlurImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBlurImageView?.alpha = 0.0
        header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        header.clipsToBounds = true
    }
    
    func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor {
        let scanner = NSScanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            header.layer.transform = headerTransform
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if avatarImage.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                }
                
            }else {
                if avatarImage.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        
        header.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            print("dismiss profile")    
        }
    }

//    @IBAction func shamelessActionThatBringsYouToMyTwitterProfile() {
//        
//        if !UIApplication.sharedApplication().openURL(NSURL(string:"twitter://user?screen_name=bitwaker")!){
//            UIApplication.sharedApplication().openURL(NSURL(string:"https://twitter.com/bitwaker")!)
//        }
//    }
}

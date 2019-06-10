//
//  SharePhotoController.swift
//  InstagramFireBase
//
//  Created by macOS on 3/18/19.
//  Copyright © 2019 macOS. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(240, 240, 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupImageAndTextViews()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        
        // Try the following two anchors and observe the change if any
        //containerView.anchor(top: view.topAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 100)
        //containerView.anchor(top: topLayoutGuide.bottomAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 100)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 100)
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor, left: containerView.leftAnchor, right: nil, paddingTop: 8, paddingBottom: -8, paddingLeft: 8, paddingRight: 0, width: 84, height: 0)
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor, left: imageView.rightAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 4, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc fileprivate func handleShare() {
        guard let caption = textView.text, caption.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        navigationItem.rightBarButtonItem?.isEnabled = false
        let filename = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", error)
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                
                if let error = error {
                    print("Failed to get post image download url:", error)
                    return
                }
                let imageUrl = url!.absoluteString
                
                print("Successfully uploaded post image:")
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            })
        }
    }

    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")

    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String: Any]
        ref.updateChildValues(values) { (error, ref) in
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB:", error)
                return
            }
            print("Success")
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//
//  NewPostController.swift
//  Table
//
//  Created by Henri El Daher on 11/6/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class NewPostController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //need to add ability to post links, pictures, videos

    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    let container = CKContainer.default()
    var givenName: String?
    var familyName: String?
    var userName: String?
    var userRecordID: CKRecordID?
    var user: CKRecord?
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserName()
        
        postContent.layer.borderWidth = 1.0
        postContent.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0).cgColor
        postContent.becomeFirstResponder()
        
        picker.delegate = self
        
        //postImage = nil
    }
    
    //note to self: will need to handle user denying permission, and let know necessay to use app
    func getUserName() {
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            if error != nil {
                print("permission error")
            } else {
                self.container.fetchUserRecordID { (recordId, error) in
                    if error != nil {
                        print("handle error")
                    } else {
                        self.container.discoverUserIdentity(withUserRecordID: recordId!, completionHandler: { (userInfo, error) in
                            if error != nil {
                                print("handle other error")
                            } else {
                                self.givenName = userInfo?.nameComponents?.givenName
                                self.familyName = userInfo?.nameComponents?.familyName
                                self.userName = (userInfo?.nameComponents?.givenName)! + " " + (userInfo?.nameComponents?.familyName)! as String
                                self.userRecordID = userInfo!.userRecordID
                            }
                        })
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.postImage.image = image
            addImageButton.isHidden = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickGroups" {
            if postContent.text != "" || (postImage.image != nil) {
                //will want to make done button un-tapable until this is not empty
                let controller = segue.destination as! PickGroupsController
                controller.user = user
                controller.postContent = postContent.text
                controller.postImage = postImage
            } else {
                return
            }
        }
    }
    
    /*
    @IBAction func done(_ sender: Any) {
        
        /*
        if postContent.text != "" {
            let newPost = CKRecord(recordType: "Post")
            newPost["content"] = postContent.text as NSString
            
            let author = user
            if let author = author {
                let reference = CKReference(recordID: author.recordID, action: CKReferenceAction.deleteSelf)
                
                newPost["poster"] = reference
                
                //should handle if CKError.notAuthenticated.raw value to tell user to login to icloud
                let db = CKContainer.default().publicCloudDatabase

                db.save(newPost, completionHandler: { (record, error) in
                    
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("post saved")
                    }
                })
            }
            
        }
        
        // don't need this now that segue-ing to group picking controller
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        */
 
        
    }
    */
    
    
    
}












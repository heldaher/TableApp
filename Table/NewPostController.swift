//
//  NewPostController.swift
//  Table
//
//  Created by Henri El Daher on 11/6/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class NewPostController: UIViewController {

    @IBOutlet weak var postContent: UITextView!
    
    let container = CKContainer.default()
    var givenName: String?
    var familyName: String?
    var userName: String?
    var userRecordID: CKRecordID?
    
    var user: CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserName()
        
        postContent.layer.borderWidth = 1.0
        postContent.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0).cgColor
        postContent.becomeFirstResponder()
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
    
    @IBAction func done(_ sender: Any) {
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
        
        /* don't need this now that segue-ing to group picking controller
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        */
        
    }
    
    
}












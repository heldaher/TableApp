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
                        //self.userRecordID = recordId

                        self.container.discoverUserIdentity(withUserRecordID: recordId!, completionHandler: { (userInfo, error) in
                            if error != nil {
                                print("handle other error")
                            } else {
                                self.givenName = userInfo?.nameComponents?.givenName
                                self.familyName = userInfo?.nameComponents?.familyName
                                self.userName = (userInfo?.nameComponents?.givenName)! + " " + (userInfo?.nameComponents?.familyName)! as String
                                
                                self.userRecordID = userInfo!.userRecordID
                                
                                //print("CK User Name: " + self.userName!)
                                //print("\(self.givenName)")
                                //print("\(self.familyName)")
                                //print("\(self.userName)")
                            }
                        })
                    }
                }
            }
        }
    }

    /* no longer necessary with navigation controller back button added
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    */
    
    @IBAction func done(_ sender: Any) {
        if postContent.text != "" {
            let newPost = CKRecord(recordType: "Post")
            newPost["content"] = postContent.text as NSString
            
            //1am 11/11 change
            let author = user
            
            //let author = CKRecord(recordType: "User")
            //author["name"] = self.userName! as NSString
            
            //here maybe instead of creating a new parent i want to fetch the existing user
            //i.e. maybe pass the current user through a segue?
            //so want a 'user' variable that is a ckrecord passed to this controller
            //so need to go to timeline controller to create a prepare for segue that passes user
            //and need to have a user type ckrecord
            //let author = user
            
            //let reference = CKReference(record: newAuthor, action: CKReferenceAction.none)
            
            if let author = author {
                let reference = CKReference(recordID: author.recordID, action: CKReferenceAction.deleteSelf)
                
                newPost["poster"] = reference
                
                //should handle if CKError.notAuthenticated.raw value to tell user to login to icloud
                let db = CKContainer.default().publicCloudDatabase
                
                /*
                db.save(author, completionHandler: { (record, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("author saved")
                    }
                })
                */
                
                
                db.save(newPost, completionHandler: { (record, error) in
                    
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("post saved")
                    }
                })
            }
            
        }
        
        //reference work - trying to make a reference to another object
        //first need to create another object though
        //perhaps create an author object
        //can do this in code
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    
}



//newAuthor["recordID"] = self.userRecordID! as CKReference

//options:
//1) see if I can add a field to the 'user'

//here I think I want to assing newAuthor["uniqueID"] = self.CKUserIdentity
//(or whatever I call it when I create an instnce variable and assign value in getUserName

/*
 if let userRecordID = userRecordID as? CKRecordID {
 print("great")
 }
 */

//newAuthor[""] = self.userRecordID!

/*
 let newAuthor = CKRecord(recordType: "Author")
 newAuthor["name"] = "Steve" as NSString
 */

/*
 let newAuthorRecordID = CKRecordID(recordName: "115")
 let newAuthor = CKRecord(recordType: "Author", recordID: newAuthorRecordID)
 newAuthor["name"] = "Woz" as NSString
 */













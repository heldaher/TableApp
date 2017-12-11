//
//  PickGroupsController.swift
//  Table
//
//  Created by Henri El Daher on 11/21/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class PickGroupsController: UIViewController {
    
    //then need to add ability to add images - prof pic and images in posts
    //then basics of aesthetics (very minimal, just make sure works on different size phones, 1-2 days of styling)
    //the done with first draft!
    
    let container = CKContainer.default()
    var groups = [CKRecord]()
    var selectedGroups = [CKRecord]()
    var user: CKRecord?
    var postContent: String?
    var userGroups = [CKRecord]()
    var postImage: UIImageView?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGroups()
    }
    
    func fetchGroups() {
        groups = [CKRecord]()
        
        let query = CKQuery(recordType: "Group", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let groups = results {
                self.groups = groups
                self.fetchUserGroups()
                
                /*
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                */
            }
        }
    }
    
    ///12/5
    func fetchUserGroups() {
        userGroups = [CKRecord]()
        let groupReferences = user!["groups"]! as! NSArray
        for group in groupReferences {
            let reference = group as! CKReference
            for alsoGroup in groups {
                if reference.recordID.recordName == alsoGroup.recordID.recordName {
                    self.userGroups.append(alsoGroup)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setSearchedGroupsToUnchecked() {
        let db = container.publicCloudDatabase
        for group in selectedGroups {
            db.fetch(withRecordID: group.recordID, completionHandler: { (record, error) in
                if let group = record, error == nil {
                    print("got group")
                    group["checked"] = "false" as NSString
                    db.save(group, completionHandler: { (record, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("group checked set to false")
                        }
                    })
                }
            })
        }
    }
    
    deinit {
        print("deinited")
        setSearchedGroupsToUnchecked()
    }
    
    @IBAction func done(_ sender: Any) {
        if selectedGroups.count != 0 {
            let db = container.publicCloudDatabase
            let newPost = CKRecord(recordType: "Post")
            newPost["content"] = postContent! as NSString
            
            //new 12/9 code
            if let postImage = postImage {
                if let image = postImage.image {
                    
                    let data = UIImagePNGRepresentation(image)
                    let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
                    do {
                        try data!.write(to: url!, options: [])
                    } catch let e as NSError {
                        print("Error! \(e)")
                        return
                    }
                    newPost["photo"] = CKAsset(fileURL: url!)
                }
            }
            
            //post belongs to a user; post also needs to belong to groups (perhaps multiple)
            //post belonging to many groups is like user belonging to many groups
            //so use code from create groups but replace user with post
            //need to decide whether to put this into the user saving block or outside
            //but will want to make a refernece to each seleceted group (for group in selectedGroups)
            //then for each group make a reference and save to the user
            //i think will want to loop through first, then once complete loop save post
            //post will have one reference to the user who posted it, and list of references to groups shared with
            
            //put more simply, need to have post have a reference list array
            //add default value to existing posts?
            
            for group in selectedGroups {
                let reference = CKReference(recordID: group.recordID, action: .none)
                
                if newPost["groups"] != nil {
                    //way to do this is 1) fetch array, 2) store in new (mutable?) array, 3) newArray.append(newReference), 4) set old array = new array
                    //1
                    let groupsList = newPost["groups"] as! NSArray
                    //2
                    var groupsListArray = groupsList as Array
                    //3
                    groupsListArray.append(reference)
                    //4
                    newPost["groups"] = groupsListArray as NSArray
                    
                    //now save post
                    db.save(newPost, completionHandler: { (record, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            
                        } else {
                            print("group added to post")
                        }
                    })
                    
                } else {
                    //i.e., if nil, create field with first item in array
                    newPost["groups"] = [reference] as NSArray
                    db.save(newPost, completionHandler: { (record, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("post's first group!")
                        }
                    })
                }
                
            }
            
            
            let author = user
            if let author = author {
                let reference = CKReference(recordID: author.recordID, action: CKReferenceAction.none)
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
        
        //navigationController?.popViewController(animated: true)
        navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}


extension PickGroupsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        let label = cell.viewWithTag(6000) as! UILabel
        
        if userGroups.count == 0 {
            label.text = "(Nothing Found)"
        } else {
            let group = userGroups[indexPath.row]
            label.text = group["name"] as? String
        }
        
        return cell
    }
}

extension PickGroupsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        //not getting changed back to false, need to fix
        if let cell = tableView.cellForRow(at: indexPath) {
            var tappedGroup = userGroups[indexPath.row]
            let label = cell.viewWithTag(6001) as! UILabel
            
            let db = container.publicCloudDatabase
            db.fetch(withRecordID: tappedGroup.recordID, completionHandler: { (record, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    tappedGroup = record!
                    
                    if tappedGroup["checked"] as! String == "false" {
                        print("false")
                        
                        //think i already have record unwrapped from a few lines up ('tappedGroup')
                        //so probably don't need below
                        
                        if let group = record {
                            
                            print("got group")
                            group["checked"] = "true" as NSString
                            
                            db.save(group, completionHandler: { (record, error) in
                                if error != nil {
                                    print(error!.localizedDescription)
                                } else {
                                    print("group updated")
                                    self.selectedGroups.append(group)
                                    DispatchQueue.main.async {
                                        label.isHidden = false
                                    }
                                }
                            })
                        }
                        
                    } else {
                        print("true")
                        if let group = record {
                            print("got group")
                            group["checked"] = "false" as NSString
                            
                            db.save(group, completionHandler: { (record, error) in
                                if error != nil {
                                    print(error!.localizedDescription)
                                } else if let record = record {
                                    print("group updated")
                                    
                                    /*
                                    //appears issue is that below line does not unwrap - seems that record was b/c changed
                                    if let i = self.selectedGroups.index(of: record) {
                                        self.selectedGroups.remove(at: i)
                                    }
                                    */

                                    self.selectedGroups = self.selectedGroups.filter() { $0.recordID.recordName != record.recordID.recordName }
                                    
                                    DispatchQueue.main.async {
                                        label.isHidden = true
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}





//
//  MyGroupsController.swift
//  Table
//
//  Created by Henri El Daher on 11/16/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class MyGroupsController: UITableViewController {
    
    //need to decide whether to click on group name, or see "X members" and click on that (leaning towards latter)
    //also need to check about deleting group reference from user's groups field if group is deleted

    let container = CKContainer.default()
    var groups = [CKRecord]()
    var users = [CKRecord]()
    
    var userRecordID: CKRecordID?
    var userName: String?
    var user: CKRecord?
    var userGroups = [CKRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        //fetchGroups()
    }
    
    // ALL TO GET CURRENT USER - need to refactor later
    
    func fetchUsers() {
        users = [CKRecord]()
        
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
            if let users = results {
                self.users = users
                self.getUserName()
            }
        }
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
                        self.userRecordID = recordId
                        self.container.discoverUserIdentity(withUserRecordID: recordId!, completionHandler: { (userInfo, error) in
                            if error != nil {
                                print("handle other error")
                            } else {
                                self.userName = (userInfo?.nameComponents?.givenName)! + " " + (userInfo?.nameComponents?.familyName)! as String
                                self.getUser()
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    func getUser() {
        
        for user in users {
            if user["CKID"]! as! String == userRecordID!.recordName {
                self.user = user
                fetchGroups()
                return
            } else {
                print("don't got it")
            }
        }

    }
    
    // END OF GETTING CURRENT USER
    
    
    func fetchGroups() {
        groups = [CKRecord]()
        
        let query = CKQuery(recordType: "Group", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
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
    

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("\(groups.count)")
        return userGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupNameCell", for: indexPath)
        let groupNameLabel = cell.viewWithTag(3001) as! UILabel
        let membersButton = cell.viewWithTag(3002) as! UIButton
        
        let group = userGroups[indexPath.row]
        if let groupName = group["name"] as? String {
            
            users = [CKRecord]()
            
            let db = container.publicCloudDatabase
            let reference = CKReference(recordID: group.recordID, action: .none)
            let predicate = NSPredicate(format: "%K CONTAINS %@", "groups", reference)
            let query = CKQuery(recordType: "User", predicate: predicate)
            
            db.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
                if error != nil {
                    print (error!.localizedDescription)
                } else {
                    if let users = results {
                        
                        self.users = users
                        
                        DispatchQueue.main.async {
                            groupNameLabel.text = groupName
                            membersButton.setTitle("\(self.users.count) Members", for: .normal)
                            
                        }
                    }
                }

            })
            
        }

        return cell
    }
    
    /* don't need this
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        
        performSegue(withIdentifier: "ShowGroupDetail", sender: group)
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowGroupDetail" {
            let controller = segue.destination as! GroupDetailController
            if let groupIndex = tableView.indexPathForSelectedRow?.row {
                controller.group = self.userGroups[groupIndex]
            }
        }
        
        if segue.identifier == "ShowMemberDetail" {
            let controller = segue.destination as! GroupMembersController
            //how to get indexPathForSelectedRow?
            let point = tableView.convert(CGPoint.zero, from: sender as! UIButton)
            guard let indexPath = tableView.indexPathForRow(at: point) else {
                fatalError("can't find point in tableView")
            }

            controller.group = self.userGroups[indexPath.row]
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

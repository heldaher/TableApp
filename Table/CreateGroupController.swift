//
//  CreateGroupController.swift
//  Table
//
//  Created by Henri El Daher on 11/11/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class CreateGroupController: UIViewController {
    
    //Should have checked users pop to top of array? instead of listing them below table?
    //above might 1) look better and 2) be clearer about how far down the table goes (to the end of the phone)
    
    let container = CKContainer.default()
    var group: CKRecord?
    //var searchResults = [String]()
    var users = [CKRecord]()
    var selectedUsers = [CKRecord]()
    var hasSearched = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
    }
    
    func fetchUsers() {
        users = [CKRecord]()
        
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
            if let users = results {
                self.users = users
            }
        }
    }
    
    /* not necessary after embedding in navigation controller
    @IBAction func close(_ sender: Any) {
        setSearchedUsersToUnchecked()
        dismiss(animated: true, completion: nil)
    }
    */
    
    //want to change to CKReferences - helpful Apple lets you know this
    //actually, maybe group shouldn't know about its members? But just users (children) should know about its parent
    //so would have a user["groups"] = [CKReference]()?
    @IBAction func done(_ sender: Any) {
        
        if groupName.text! != "" {
            let db = container.publicCloudDatabase
            
            let newGroup = CKRecord(recordType: "Group")
            newGroup["name"] = groupName.text! as NSString
            
            
            //need to have user["groups"] = [CKReference] as NSArray, how?
            //want to append reference to existing reference array (or create if doesn't already exist)
            //if doesn't exist, create by = [reference]
            
            
            db.save(newGroup, completionHandler: { (record, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("group saved")
                    for user in self.selectedUsers {
                        if user["checked"] as! String == "true" {
                            print("some users have checked value")
                            
                            //Set back checked value to false
                            user["checked"] = "false" as NSString
                            
                            //users.append(user)
                            //newGroup["users"]!.append(user)    doesn't compile - no append method
                            //self.selectedUsers.append(user)
                            let reference = CKReference(recordID: newGroup.recordID, action: .none)
                            
                            //user["groups"] = reference
                            if user["groups"] != nil {
                                //already exists, so append to array
                                //user["groups"] as! NSArray
                                //user["groups"].append(reference)
                                
                                //way to do this is 1) fetch array, 2) store in new (mutable?) array, 3) newArray.append(newReference), 4) set old array = new array
                                //1
                                let groupsList = user["groups"] as! NSArray
                                //2
                                var groupsListArray = groupsList as Array
                                //3
                                groupsListArray.append(reference)
                                //4
                                user["groups"] = groupsListArray as NSArray
                                
                                //now save user
                                db.save(user, completionHandler: { (record, error) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                    } else {
                                        print("group added to user")
                                    }
                                })
                                
                            } else {
                                //i.e., if nil, create field with first item in array
                                user["groups"] = [reference] as NSArray
                                db.save(user, completionHandler: { (record, error) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                    } else {
                                        print("user's first group!")
                                    }
                                })
                            }
                            
                        }
                    }
                }
            })
        
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //11/14 - want to add code here for when controller is destroyed all users are set back to false for checked
    //b/c when load screen want all checked values as false
    //note that if resetting user["checked"] to 0 for each user, will only need to do so for searchResults later
    
    //getting client oplock error updating record (doesn't seem to matter) b/c server record newer/different
    func setSearchedUsersToUnchecked() {
        let db = container.publicCloudDatabase
        for user in selectedUsers {
            
            db.fetch(withRecordID: user.recordID, completionHandler: { (record, error) in
                if let user = record, error == nil {
                    print("got user")
                    //maybe change to user["checked"] as! String = "false"??
                    user["checked"] = "false" as NSString
                    
                    db.save(user, completionHandler: { (record, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("user checked set to false")
                        }
                    })
                }
            })
        }
    }
    
    
    deinit {
        print("deinited")
        setSearchedUsersToUnchecked()
    }
    
}

extension CreateGroupController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        //searchResults = []
        
        /*
        for i in 0...2 {
            searchResults.append(String(format: "Fake Result %d for '%@'", i, searchBar.text!))
        }
        */
        
        hasSearched = true
        tableView.reloadData()
    }
}

extension CreateGroupController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if users.count == 0 {
            return 1
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReturnedUserCell", for: indexPath)
        let label = cell.viewWithTag(2000) as! UILabel
      
        
        if users.count == 0 {
            label.text = "(Nothing Found)"
        } else {
            let user = users[indexPath.row]
            label.text = user["name"] as? String
        }
        
        return cell
    }
    
}

extension CreateGroupController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        if let cell = tableView.cellForRow(at: indexPath) {
            var tappedUser = users[indexPath.row]
            let label = cell.viewWithTag(2001) as! UILabel
            
            //problem - need to change "checked" value in if else block, but 'immutable'
            //new problem - appears to change only when app is shut down and relauched - why not immediately?
            //because not refetching so value stays the same
            
            //need to scroll to see more users
            //include fetch code to fetch just the updated user
            let db = container.publicCloudDatabase
            db.fetch(withRecordID: tappedUser.recordID, completionHandler: { (record, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    tappedUser = record!
                    
                    if tappedUser["checked"] as! String == "false" {
                        print("false")
                        //tappedUser["checked"] = "true"
                        
                        //note sure why need this code again, gonna try commenting out 11/16
                        //issue i think is that user is modified but users array not and out of synch
                        //maybe answer is to create a new array called selectedUsers, add new user to that array
                 
                            if let user = record {
             
                                print("got user")
                                user["checked"] = "true" as NSString
                                
                                db.save(user, completionHandler: { (record, error) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                    } else {
                                        print("user updated")
                                        self.selectedUsers.append(user)
                                        DispatchQueue.main.async {
                                            //label.text! = "√"
                                            label.isHidden = false
                                        }
                                    }
                                })
                            }
                     
                    } else {
                        print("true")
                        
                    
                            if let user = record {
                                print("got user")
                                user["checked"] = "false" as NSString
                                
                                db.save(user, completionHandler: { (record, error) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                    } else {
                                        print("user updated")
                                        //self.selectedUsers.remove(at: int)
                                        //need to figure out which index the user is at
                                        //is there a method that tells you index of value in table?
                                        if let i = self.selectedUsers.index(of: record!) {
                                            self.selectedUsers.remove(at: i)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            //label.text! = ""
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
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if users.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}


//want to start with each user having value of not selected
//assume I should do this by add field newUser["selected"]
//which would be set to false and changed to true when selected
//then when row with user is selected, will change to true, whill unhide check
//then all users with mark of true will be included in new group
//as an array of users (so group will have an array field with all users)
//? - will there be a way to know that user belongs to a group?
//? - maybe each user should have a 'groups' field that is an array of groups
//and it would get appended to when a user selected...

//maybe user shouldn't accept group invitation but just be added to one?
//with opportunity to mute thread added later
//so this would mean less work - less coding, screens
//I think I'll do this
//reference or array?

//...so when a user is selected, boolean (though may be a string) is toggled
//need to set all back to false before exit method
//save newGroup
//with newGroup["users"] = [selectedUsers] as NSArray
//so will need to do a for in loop before toggling back to false where, when done is pressed:
//if user["isSelected"] = true { selectedUsers.append(user) }

//then when do timeline can say:
//do I want to loop thrugh every group and if user is in it then add group.posts to timeline sorted chron.?
//sounds problematic in that user model does not know on its own what group(s) it belongs to
//alternative is?
//have user have a user["groups"] field = NSArray of group objects
//once have this field stored in table then

//...will need to modify existing records by adding users to groups (at a later date?)

//then can loop through groups.posts of each user, store it in relevantPosts array, and sort and display
//so question here is how do I get this user["groups"] field?
//I guess when newGroup created, append to user.groups a new objects

//big question here though is: is this whole architecture wrong?
//shouldn't I be creating a reference? perhaps array of reference ids?
//note that child has a reference to the id of parent
//need to check one to one vs one to many differences - but I think store array of reference ids

//so next steps are:
//delete existing users and create new users (will have to create different users) that have:
//1) additional field of user["isSelected"] = false as NSString
//2) additional field of user["groups"] = [(reference id to a group)]
//i.e., array of CKReferences that will originally be empty

//then, add code to allow a selection option on the create group user row
//that when selected toggles value

//then when press done:
//newGroup is created
//has a name field
//has a users field - that is created by looping through users and when isSelected is true adding user to array
//then after adding to array isSelected field for that user is toggled back to false (already done)
//(note that group invitations is not currently in existence)
//(this would get very annoying if app grows and find self bombarded by posts from unwanted groups)
//(can revisit this later but for getting going ok to not have invitation functionality added)
//then newGroup (with name and array of member users) is saved

//basically now have to save group["users"] field
//create it by looping through user in users and when user["checked"] = "true", append to group["users"] array
//then save group



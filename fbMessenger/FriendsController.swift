//
//  FriendesController.swift
//  fbMessenger
//
//  Created by Chiang Chuan on 7/19/16.
//  Copyright © 2016 Chiang Chuan. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController{
    
    func clearData(){
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext{
            
            do{
                let entityNames = ["Friend", "Message"]
                
                for entityName in entityNames{
                    let fatchRequest = NSFetchRequest(entityName: entityName)
                    
                    let objects = try(context.executeFetchRequest(fatchRequest) as? [NSManagedObject])
                    
                    for object in objects! {
                        context.deleteObject(object)
                    }
                }
                
                
                try(context.save())
                
                
            }catch let err{
                print(err)
            }
        }
    }
    
    func setupData(){
        
        clearData()
        
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext{
            
            let mark = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
            mark.name = "Mark Zuckerbarg"
            mark.profileImageName = "zuckprofile"
            
            let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
            message.friend = mark
            message.text = "Hellow, I'm Mark, Nice to meet you..."
            message.date = NSDate()
            
            
            let steve = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
            steve.name = "Steve Jobs"
            steve.profileImageName = "steve_profile"
            
            
            createMessageWithText("God morning...", friend: steve, minutesAgo: 3, context: context)
            createMessageWithText("Hello, how are you?", friend: steve, minutesAgo: 2, context: context)
            createMessageWithText("Are you interested in buying an Apple device?", friend: steve, minutesAgo: 1, context: context)
            
            let bill = NSEntityDescription.insertNewObjectForEntityForName("Friend", inManagedObjectContext: context) as! Friend
            bill.name = "Bill Gates"
            bill.profileImageName = "bill_gates_profile"
            createMessageWithText("You're fired", friend: bill, minutesAgo: 5, context: context)
            
            
            
            do{
                try(context.save())
            }catch let err{
                print(err)
            }
            
//            messages = [message, messagesteve]

        }
        
        
        loadData()
    }
    
    private func createMessageWithText(text: String, friend: Friend,minutesAgo: Double, context: NSManagedObjectContext){
        let message =  NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate().dateByAddingTimeInterval(-minutesAgo * 60)
    }
    
    
    
    func loadData(){
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext{
            
            if let friends = fetchFriends(){
                
                messages = [Message]()
                
                for friend in friends {
                    print(friend.name)
                    
                    let fetchRequest = NSFetchRequest(entityName: "Message")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                    fetchRequest.fetchLimit = 1
                    
                    do{
                        let fetchedMessages = try(context.executeFetchRequest(fetchRequest)) as? [Message]
                        messages?.appendContentsOf(fetchedMessages!)
                    }catch let err{
                        print(err)
                    }
                }
                
                messages = messages?.sort({$0.date?.compare($1.date!) == .OrderedDescending})
            }
        }
    }
    private func fetchFriends() -> [Friend]?{
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext{
            
            let request = NSFetchRequest(entityName: "Friend")
            
            do{
                return try context.executeFetchRequest(request) as? [Friend]
            }catch let err{
                print(err)
            }
        
        }
        
        return nil
    }
    
}







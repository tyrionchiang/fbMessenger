//
//  Message+CoreDataProperties.swift
//  fbMessenger
//
//  Created by Chiang Chuan on 8/3/16.
//  Copyright © 2016 Chiang Chuan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var date: NSDate?
    @NSManaged var text: String?
    @NSManaged var isSender: NSNumber?
    @NSManaged var friend: Friend?

}

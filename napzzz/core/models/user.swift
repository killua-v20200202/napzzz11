//
//  user.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    
}

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var sleepGoal: Int32
    @NSManaged public var preferredBedtime: Date?
    @NSManaged public var preferredWakeTime: Date?
}

extension User: Identifiable {
    
}

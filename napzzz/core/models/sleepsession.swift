//
//  sleepsession.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation
import CoreData

@objc(SleepSession)
public class SleepSession: NSManagedObject {
    
}

extension SleepSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepSession> {
        return NSFetchRequest<SleepSession>(entityName: "SleepSession")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var quality: Int16
    @NSManaged public var snoringDetected: Bool
    @NSManaged public var teethGrindingDetected: Bool
    @NSManaged public var movementLevel: Int16
    @NSManaged public var audioUsed: String?
    @NSManaged public var notes: String?
}

extension SleepSession: Identifiable {
    
}

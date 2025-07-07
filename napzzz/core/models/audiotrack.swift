//
//  audiotrack.swift
//  napzzz
//
//  Created by Morris Romagnoli on 06/07/2025.
//

import Foundation
import CoreData

@objc(AudioTrack)
public class AudioTrack: NSManagedObject {
    
}

extension AudioTrack {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioTrack> {
        return NSFetchRequest<AudioTrack>(entityName: "AudioTrack")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var category: String?
    @NSManaged public var duration: Int32
    @NSManaged public var fileName: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var playCount: Int32
    @NSManaged public var createdAt: Date?
}

extension AudioTrack: Identifiable {
    
}

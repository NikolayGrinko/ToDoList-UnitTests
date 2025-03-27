//
//  ToDoEntity.swift
//  ToDoListViper+Add_Del+Set
//
//  Created by Николай Гринько on 24.03.2025.
//

import UIKit
import CoreData

@objc(ToDoEntity)
public class ToDoEntity: NSManagedObject {}

extension ToDoEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoEntity> {
        return NSFetchRequest<ToDoEntity>(entityName: "ToDoEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var todo: String
    @NSManaged public var completed: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var userId: Int
}


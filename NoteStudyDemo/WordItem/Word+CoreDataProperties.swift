//
//  Word+CoreDataProperties.swift
//  NoteStudyDemo
//
//  Created by Thảo Nguyên on 29/10/2023.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var id: Date?
    @NSManaged public var kr_language: String?
    @NSManaged public var vn_language: String?

}

extension Word : Identifiable {

}

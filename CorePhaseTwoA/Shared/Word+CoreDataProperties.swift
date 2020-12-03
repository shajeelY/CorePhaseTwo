//
//  Word+CoreDataProperties.swift
//  CorePhaseTwoA
//
//  Created by Shajeel Yahya on 11/30/20.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func createfetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var ent_seq: Int64
    @NSManaged public var k_ele: [String]
    @NSManaged public var r_ele: [String]
    @NSManaged public var sense: [String]

}

extension Word : Identifiable {

}

extension Word {
    func update(with dictionaryKanji: [String: Any]) throws {
        guard let newSeq = dictionaryKanji["ent_seq"] as? Int,
            let newKanji = dictionaryKanji["k_ele"] as? [String],
            let newFuri = dictionaryKanji["r_ele"] as? [String],
            let newDef = dictionaryKanji["sense"] as? [String] else {
                throw QuakeError.missingData
        }

        ent_seq = Int64(newSeq)
        k_ele = newKanji
        r_ele = newFuri
        sense = newDef
        print("\(k_ele[0]) updated")
    }
    
    
}

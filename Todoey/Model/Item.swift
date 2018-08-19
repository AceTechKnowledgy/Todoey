//
//  Item.swift
//  Todoey
//
//  Created by Ace on 15/08/18.
//  Copyright © 2018 Ace. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var itemName: String = ""
    @objc dynamic var isChecked: Bool = false    
    //Creating Relationship that each items may belong to one of the category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

//
//  Category.swift
//  Todoey
//
//  Created by Ace on 15/08/18.
//  Copyright © 2018 Ace. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colorName: String = ""
    
    //Creating Relationship that the each category will have many Items under that
    let items = List<Item>()
}

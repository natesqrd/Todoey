//
//  Category.swift
//  Todoey
//
//  Created by Nathaniel Tucker on 10/8/19.
//  Copyright © 2019 Nathaniel Tucker. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}

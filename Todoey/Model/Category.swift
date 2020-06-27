//
//  Category.swift
//  Todoey
//
//  Created by Wojciech Kudrynski on 26/06/2020.
//  Copyright © 2020 Wojciech Kudrynski. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}

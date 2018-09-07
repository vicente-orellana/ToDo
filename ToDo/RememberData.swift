//
//  RememberData.swift
//  ToDo
//
//  Created by Vicente Orellana on 9/7/18.
//  Copyright © 2018 Vicente Orellana. All rights reserved.
//

import Foundation

struct thingToRemember {
    let thing: String
    let date: Date
}

extension thingToRemember {
    func encode() -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(thing, forKey: "thing")
        archiver.encode(date, forKey: "date")
        archiver.finishEncoding()
        return data as Data
    }
    
    init?(data: Data) {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        defer { unarchiver.finishDecoding() }
        guard let thing = unarchiver.decodeObject(forKey: "thing") as? String else { return nil }
        guard let date = unarchiver.decodeObject(forKey: "date") as? Date else { return nil }
        self.thing = thing
        self.date = date
    }
}

//
//  ToRememberTableViewController.swift
//  ToDo
//
//  Created by Vicente Orellana on 9/4/18.
//  Copyright © 2018 Vicente Orellana. All rights reserved.
//

import UIKit
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

let toRememberNotification = Notification.Name(rawValue: "toRememberUpdate")

class ToRememberTableViewController: UITableViewController {
    let defaults = UserDefaults.standard
    
    var thingsToRemember: [thingToRemember] = [] {
        didSet {
            let rememberData = thingsToRemember.map { $0.encode() }
            defaults.set(rememberData, forKey: "ToRemember")
            tableView.reloadData()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let toRememberObject = defaults.object(forKey: "ToRemember") as? [Data] {
            thingsToRemember = toRememberObject.compactMap { return thingToRemember(data: $0) }
        }
        
        checkCalendarDayDidChange()
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkForNewEntries(notified:)), name: toRememberNotification, object: nil)
    }
    
    func checkCalendarDayDidChange() {
        thingsToRemember.enumerated().reversed().forEach {
            if let diff = Calendar.current.dateComponents([.hour], from: $1.date, to: Date()).hour, diff > 24 {
                thingsToRemember.remove(at: $0)
            }
        }
    }
    
    @objc func checkForNewEntries(notified: Notification) {
        guard let newEntry = notified.userInfo?["newRemember"] as? String else { return }
        thingsToRemember.append(thingToRemember(thing: newEntry, date: Date()))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thingsToRemember.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rememberCell", for: indexPath)
        cell.textLabel?.text = thingsToRemember[indexPath.row].thing
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.thingsToRemember.remove(at: indexPath.row)
        }
        delete.backgroundColor = UIColor(red: 0.72, green: 0.44, blue: 1.00, alpha: 1.0)
        return [delete]
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AddToListViewController else { return }
        destination.textLabel = "Thing to Remember"
        destination.updateClosure = { (result) in
            self.thingsToRemember.append(thingToRemember(thing: result, date: Date()))
        }
    }

}

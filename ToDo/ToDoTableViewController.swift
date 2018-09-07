//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Vicente Orellana on 9/3/18.
//  Copyright © 2018 Vicente Orellana. All rights reserved.
//

import UIKit

class ToDoTableViewController: UITableViewController {
    @IBOutlet weak var dateText: UINavigationItem!
    let defaults = UserDefaults.standard
    var thingsToDo: [String] = [] {
        didSet {
            defaults.set(thingsToDo, forKey: "ToDo")
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelectionDuringEditing = true
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let weekday = getDayOfWeek(date)
        dateText.title = "\(weekday) - \(formatter.string(from: date))"
        
        if defaults.stringArray(forKey: "ToDo") != nil {
            thingsToDo = defaults.stringArray(forKey: "ToDo")!
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(rememberNotification(notified:)), name: toRememberNotification, object: nil)
    }
    
    @objc func rememberNotification(notified: Notification) {
        guard let newEntry = notified.userInfo?["newEntry"] as? String else { return }
        thingsToDo.append(newEntry)
    }
    
    func getDayOfWeek(_ today: Date) -> String {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: today)
        switch weekDay {
        case 0:
            return "Sat"
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        default:
            return "NULL"
        }
    }
    
    @IBAction func viewScheduleBtn(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL(string: "calshow://")!)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thingsToDo.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        cell.textLabel?.text = thingsToDo[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.thingsToDo.remove(at: indexPath.row)
        }
        let add = UITableViewRowAction(style: .default, title: "Add to Calendar") { (action, indexPath) in
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.performSegue(withIdentifier: "addToCalendar", sender: self)
        }
        let postpone = UITableViewRowAction(style: .default, title: "Defer") { (action, indexPath) in
            var sendData = [String: String]()
            sendData["newRemember"] = self.thingsToDo[indexPath.row]
            NotificationCenter.default.post(name: toRememberNotification, object: nil, userInfo: sendData)
            self.thingsToDo.remove(at: indexPath.row)
        }
        delete.backgroundColor = UIColor(red: 0.72, green: 0.44, blue: 1.00, alpha: 1.0)
        add.backgroundColor = UIColor(red: 0.47, green: 0.56, blue: 1.00, alpha: 1.0)
        postpone.backgroundColor = UIColor(red:0.63, green:0.85, blue:0.90, alpha:1.0)
        return [delete, postpone, add]
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addToList" {
            guard let destination = segue.destination as? AddToListViewController else { return }
            destination.updateClosure = { (result) in
                self.thingsToDo.append(result)
            }
        }
        if segue.identifier == "addToCalendar" {
            guard let destination = segue.destination as? AddToCalendarViewController else { return }
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            destination.thingToDo = thingsToDo[indexPath.row]
            destination.updateClosure = { (result) in
                if result == "success" {
                    self.thingsToDo.remove(at: indexPath.row)
                }
            }
        }
    }
}

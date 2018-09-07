//
//  AddToCalendarViewController.swift
//  ToDo
//
//  Created by Vicente Orellana on 9/4/18.
//  Copyright © 2018 Vicente Orellana. All rights reserved.
//

import UIKit
import EventKit

class AddToCalendarViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var toDoTextField: UITextField!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    
    var updateClosure: ToDoUpdateClosure?
    var thingToDo: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toDoTextField.delegate = self
        startDate.setValue(UIColor.white, forKey: "textColor")
        endDate.setValue(UIColor.white, forKey: "textColor")
        toDoTextField.text = thingToDo
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toDoTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveBtn(_ sender: UIBarButtonItem) {
        // Add to do to Calendar
        let store: EKEventStore = EKEventStore()
        
        store.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                let event: EKEvent = EKEvent(eventStore: store)
                
                DispatchQueue.main.sync {
                    event.title = self.toDoTextField.text
                    event.startDate = self.startDate.date
                    event.endDate = self.endDate.date
                    event.calendar = store.defaultCalendarForNewEvents
                    // TODO: Add optional alarm functionality
                    // event.addAlarm(EKAlarm(relativeOffset: ))
                }
                
                do {
                    try store.save(event, span: .thisEvent)
                    self.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.sync {
                        UIApplication.shared.open(URL(string: "calshow://")!)
                        self.updateClosure!("success")
                    }
                } catch let error as NSError {
                    print("Error: \(error)")
                }
            }
        }
    }
}

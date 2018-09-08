//
//  AddToCalendarViewController.swift
//  ToDo
//
//  Created by Vicente Orellana on 9/4/18.
//  Copyright © 2018 Vicente Orellana. All rights reserved.
//

import UIKit
import EventKit

class AddToCalendarViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var toDoTextField: UITextField!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var alertPicker: UIPickerView!
    @IBOutlet weak var alertToggleBtn: UISwitch!
    
    let alertOptions = ["5 minutes before", "10 minutes before", "30 minutes before", "1 hour before"]
    
    var updateClosure: ToDoUpdateClosure?
    var thingToDo: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toDoTextField.delegate = self
        alertPicker.delegate = self
        alertPicker.dataSource = self
        
        startDate.setValue(UIColor.white, forKey: "textColor")
        endDate.setValue(UIColor.white, forKey: "textColor")
        
        toDoTextField.text = thingToDo
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return alertOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return alertOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: alertOptions[row], attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
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
                    // Alert options (based on selection)
                    if self.alertToggleBtn.isOn {
                        let selectedValue = self.alertOptions[self.alertPicker.selectedRow(inComponent: 0)]
                        var offset: TimeInterval!
                        switch selectedValue {
                        case "5 minutes before":
                            offset = -300
                            break
                        case "10 minutes before":
                            offset = -600
                            break
                        case "30 minutes before":
                            offset = -1800
                            break
                        case "1 hour before":
                            offset = -3600
                            break
                        default:
                            offset = 0
                        }
                        event.addAlarm(EKAlarm(relativeOffset: offset))
                    }
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

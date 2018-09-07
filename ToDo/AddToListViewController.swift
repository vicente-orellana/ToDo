//
//  AddToListViewController.swift
//  ToDo
//
//  Created by Vicente Orellana on 9/4/18.
//  Copyright © 2018 Vicente Orellana. All rights reserved.
//

import UIKit

typealias ToDoUpdateClosure = (String) -> Void

class AddToListViewController: UIViewController, UITextFieldDelegate {
    var updateClosure: ToDoUpdateClosure?
    @IBOutlet weak var thingToDoLabel: UILabel!
    @IBOutlet weak var thingToDoTextField: UITextField!
    var textLabel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thingToDoTextField.delegate = self
        if textLabel != nil { thingToDoLabel.text = textLabel }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        thingToDoTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func addBtn(_ sender: UIBarButtonItem) {
        if thingToDoTextField.text == "" {
            thingToDoTextField.layer.borderWidth = 1.0
            thingToDoTextField.layer.borderColor = UIColor.red.cgColor
        } else {
            updateClosure?(thingToDoTextField.text!)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

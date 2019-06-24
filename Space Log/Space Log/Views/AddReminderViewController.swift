//
//  AddReminderViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/22/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var noteTextField: UITextField!
	
	// MARK: Variables
	
	var stringDate: String?
	var note: String?
	var date: Date?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		datePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
		
        // Do any additional setup after loading the view.
		if let setDate = date {
			datePicker.date = setDate
			noteTextField.text = note
		}
		
		var currentDate = Date()
		datePicker.minimumDate = currentDate
		datePicker.backgroundColor = UIColor(red:0.36, green:0.41, blue:0.54, alpha:1.0)
		datePicker.setValue(UIColor.white, forKey: "textColor")
    }
	
	// MARK: Custom functions
	
	func setDate(date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd 'at' hh:mm a"
		let dateString = formatter.string(from: date)
		return dateString
	}
	
	@objc func datePickerChanged(picker: UIDatePicker) {
		stringDate = setDate(date: datePicker.date)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "unwind" {
			let destinationViewController = segue.destination as! DetailViewController
			if let date = stringDate {
				destinationViewController.reminderDate = date
			}
			destinationViewController.reminderNote = noteTextField.text
		}
	}
	
	// MARK: IBActions
	
	@IBAction func confirmButtonPressed(_ sender: UIButton) {
		if noteTextField.text == "" {
			showAlert(title: "Incomplete Entry", message: "Please enter a note for your reminder")
		} else {
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reminderAdded"), object: nil)
			performSegue(withIdentifier: "unwind", sender: Any?.self)
		}
	}
	
	
	@IBAction func cancelButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

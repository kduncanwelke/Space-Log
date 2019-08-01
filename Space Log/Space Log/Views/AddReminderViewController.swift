//
//  AddReminderViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/22/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import UserNotifications

class AddReminderViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var noteTextField: UITextField!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet var tapGesture: UITapGestureRecognizer!
	
	// MARK: Variables
	
	var formatter = DateFormatter()
	var stringDate: String?
	var note: String?
	var date: Date?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

		datePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
	
		formatter.dateFormat = "yyyy-MM-dd 'at' hh:mm a"
		
		tapGesture.isEnabled = false
		
        // Do any additional setup after loading the view.
		if let string = stringDate {
			if let dateToDisplay = getDate(from: string) {
				datePicker.date = dateToDisplay
			}
			noteTextField.text = note
			deleteButton.backgroundColor = .red
			deleteButton.isEnabled = true
		} else {
			deleteButton.backgroundColor = .black
			deleteButton.isEnabled = false
		}
		
		var currentDate = Date()
		datePicker.minimumDate = currentDate
		datePicker.backgroundColor = UIColor(red:0.36, green:0.41, blue:0.54, alpha:1.0)
		datePicker.setValue(UIColor.white, forKey: "textColor")
		
		confirmButton.layer.cornerRadius = CGFloat(15.0)
		confirmButton.clipsToBounds = true
		confirmButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
		
		deleteButton.layer.cornerRadius = CGFloat(15.0)
		deleteButton.clipsToBounds = true
		deleteButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
	
	override func viewDidAppear(_ animated: Bool) {
		// check if notifications are enabled, as this is the first point of use
		UNUserNotificationCenter.current().getNotificationSettings(){ [unowned self] (settings) in
			switch settings.alertSetting {
			case .enabled:
				break
			case .disabled:
				DispatchQueue.main.async {
					self.showSettingsAlert(title: "Notifications disabled", message: "Reminders require access to notification sevices to provide local notifications. These notifications will not be displayed unless settings are adjusted.")
				}
			case .notSupported:
				DispatchQueue.main.async {
					self.showSettingsAlert(title: "Notifications not supported", message: "Notifications will not be displayed, as the service is not available on this device.")
				}
			@unknown default:
				return
			}
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	// MARK: Custom functions
	
	@objc func keyboardWillShow(notification: NSNotification) {
		guard let userInfo = notification.userInfo else { return }
		guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
		let keyboardFrame = keyboardSize.cgRectValue
		
		var aRect: CGRect = self.view.frame
		aRect.size.height -= keyboardFrame.height
		
		var coord = noteTextField.convert(noteTextField.center, to: self.view)
	
		if (!aRect.contains(coord)) {
			var multi = keyboardFrame.height / self.view.frame.height
			var heightToMove = keyboardFrame.height * multi
			print(heightToMove)
			self.view.frame.origin.y -= heightToMove
			print("this")
		} else {
			print("nothing")
		}
		
		tapGesture.isEnabled = true
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		self.view.frame.origin.y = 0
		tapGesture.isEnabled = false
	}
	
	func getDate(from stringDate: String) -> Date? {
		guard let createdDate = formatter.date(from: stringDate) else {
			print("date conversion failed")
			return nil
		}
		return createdDate
	}
	
	func setDate(date: Date) -> String {
		let dateString = formatter.string(from: date)
		return dateString
	}
	
	@objc func datePickerChanged(picker: UIDatePicker) {
		stringDate = setDate(date: datePicker.date)
	}
	
	// MARK: IBActions
	
	@IBAction func tap(_ sender: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	
	
	@IBAction func confirmButtonPressed(_ sender: UIButton) {
		if noteTextField.text == "" {
			showAlert(title: "Incomplete Entry", message: "Please enter a note for your reminder")
		} else {
			performSegue(withIdentifier: "unwind", sender: Any?.self)
		}
	}
	
	@IBAction func deleteButtonPressed(_ sender: UIButton) {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reminderDeleted"), object: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func cancelButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

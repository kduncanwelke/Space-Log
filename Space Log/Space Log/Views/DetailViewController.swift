//
//  DetailViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/19/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
	
	// MARK: Variables
	
	var detailItem: Entry?
	var checkList: [CheckListItem] = []
	var reminderDate: String?
	var reminderNote: String?
	var formatter = DateFormatter()
	
	// MARK: IBOutlets
	
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var editLabel: UILabel!
	@IBOutlet weak var contentTextView: UITextView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var listItemTextField: UITextField!
	@IBOutlet weak var reminderButton: UIButton!
	@IBOutlet weak var reminderText: UILabel!
	

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		formatter.dateFormat = "MM-dd-yyyy"
		
		contentTextView.delegate = self
		titleTextField.delegate = self
		listItemTextField.delegate = self
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableFooterView = UIView(frame: .zero)
		
		configureView()
	}
	
	
	func configureView() {
		// Update the user interface for the detail item.
		
		if let detail = detailItem {
			titleTextField.text = detail.title
			dateLabel.text = detail.date
			contentTextView.text = detail.content
			
			if detail.lastEdited == nil {
				editLabel.text = "N/A"
			} else {
				editLabel.text = detail.lastEdited
			}
			
			if let reminder = detail.reminder {
				reminderButton.setTitle("   Edit?   ", for: .normal)
				reminderDate = reminder.date
				reminderNote = reminder.note
				
				if let date = reminder.date {
					reminderText.text = "Reminder on \(date)"
				}
			}
			
			guard let savedList = detail.list, let listItems = savedList.items else { return }
			checkList = listItems
			tableView.reloadData()
		} else {
			dateLabel.text = setDate()
			editLabel.text = "N/A"
			titleTextField.text = "Enter title . . ."
			contentTextView.text = "Start typing . . ."
			reminderButton.setTitle("Add?", for: .normal)
			reminderText.text = "No reminder"
			editLabel.text = "N/A"
			checkList.removeAll()
			tableView.reloadData()
		}
	}
	
	// MARK: Custom functions
	
	func reminderAdded() {
		reminderButton.setTitle("   Edit?   ", for: .normal)
	
		if let date = reminderDate {
			reminderText.text = "Reminder on \(date)"
		}
	}
	
	func setDate() -> String {
		let currentDate = Date()
		let dateString = formatter.string(from: currentDate)
		return dateString
	}
	
	func getEntryData(entry: Entry) {
		entry.title = titleTextField.text
		entry.date = dateLabel.text
		entry.content = contentTextView.text
		entry.lastEdited = dateLabel.text
	}
	
	func getDate(from stringDate: String) -> Date? {
		guard let createdDate = formatter.date(from: stringDate) else {
			print("date conversion failed")
			return nil
		}
		return createdDate
	}
	
	func save() {
		var managedContext = CoreDataManager.shared.managedObjectContext
		
		guard let currentEntry = detailItem else {
			// if there is no current entry being edited, add a new one
			let newEntry = Entry(context: managedContext)
			
			if checkList.count != 0 {
				var list: List?
				list = List(context: managedContext)
				list?.items = checkList
				
				newEntry.list = list
			}
			
			if let date = reminderDate, let note = reminderNote {
				var reminder: Reminder?
				reminder = Reminder(context: managedContext)
				reminder?.date = date
				reminder?.note = note
				reminder?.id = Date()
				
				newEntry.reminder = reminder
				
				// add notification
				if let reminder = reminder {
					NotificationManager.addTimeBasedNotification(for: reminder)
				}
			}
			
			getEntryData(entry: newEntry)
		
			do {
				try managedContext.save()
				print("saved")
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
			} catch {
				// this should never be displayed but is here to cover the possibility
				showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
			}
			
			return
		}
		
		// otherwise resave current entry that is being edited, overwrite existing list
		if checkList.count != 0 {
			var list: List?
			list = List(context: managedContext)
			list?.items = checkList
			currentEntry.list = list
		}
		
		if let date = reminderDate, let note = reminderNote {
			if let currentReminder = currentEntry.reminder {
				currentReminder.date = date
				currentReminder.note = note
				currentEntry.reminder = currentReminder
				
				// add notification
				NotificationManager.addTimeBasedNotification(for: currentReminder)
			} else {
				var reminder: Reminder?
				reminder = Reminder(context: managedContext)
				reminder?.date = date
				reminder?.note = note
				reminder?.id = Date()
				currentEntry.reminder = reminder
				
				// add notification
				if let reminder = reminder {
					NotificationManager.addTimeBasedNotification(for: reminder)
				}
			}
		}
	
		currentEntry.title = titleTextField.text
		currentEntry.lastEdited = setDate()
		currentEntry.content = contentTextView.text
		
		do {
			try managedContext.save()
			print("saved")
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
		} catch {
			// this should never be displayed but is here to cover the possibility
			showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "addReminder" && detailItem?.reminder != nil {
			let destinationViewController = segue.destination as! AddReminderViewController
			destinationViewController.note = reminderNote
			destinationViewController.stringDate = reminderDate
		}
	}

	// MARK: IBActions
	
	@IBAction func addReminderTapped(_ sender: UIButton) {
		performSegue(withIdentifier: "addReminder", sender: Any?.self)
	}
	
	
	@IBAction func addListItemPressed(_ sender: UIButton) {
		guard let text = listItemTextField.text else { return }
		if text == "Enter title . . ." || text == "" {
			return
		}
		let newItem = CheckListItem(item: text, isComplete: false)
		checkList.append(newItem)
		listItemTextField.text = ""
		tableView.reloadData()
	}
	
	
	@IBAction func saveTapped(_ sender: UIBarButtonItem) {
		if titleTextField.text == "Enter title . . ." {
			showAlert(title: "Incomplete Entry", message: "Please enter a title")
			return
		} else if contentTextView.text == "Start typing . . ." {
			showAlert(title: "Incomplete Entry", message: "Please enter some log content")
			return
		}
		save()
		
		detailItem = nil
		configureView()
		_ = self.navigationController?.popToRootViewController(animated: true)
	}
	
	@IBAction func unwindFromReminder(segue: UIStoryboardSegue) {
		if segue.identifier == "unwind" {
			let sourceViewController = segue.source as! AddReminderViewController
			reminderDate = sourceViewController.stringDate
			reminderNote = sourceViewController.noteTextField.text
			reminderAdded()
		}
	}
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource, CellCheckDelegate {
	func didChangeSelectedState(sender: CheckListTableViewCell, isChecked: Bool) {
		let path = self.tableView.indexPath(for: sender)
		if let selected = path {
			checkList[selected.row].isComplete = isChecked
			print("delegate called")
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return checkList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "checkListCell", for: indexPath) as! CheckListTableViewCell
		
		let object = checkList[indexPath.row]
		cell.cellTitle.text = object.item
		
		if object.isComplete {
			cell.cellCheck.imageView?.image = UIImage(named: "checked")
		} else {
			cell.cellCheck.imageView?.image = UIImage(named: "unchecked")
		}
		
		cell.cellDelegate = self
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			checkList.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
}

extension DetailViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == "Start typing . . ." {
			textView.text = nil
		}
	}
	
	// reassign placeholder if empty
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "Start typing . . ."
		}
	}
}

extension DetailViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField.text == "Enter title . . ." {
			textField.text = nil
		}
	}
	
	// reassign placeholder if empty
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let text = textField.text?.isEmpty else { return }
		if text {
			textField.text = "Enter title . . ."
		} else {
			return
		}
	}
}

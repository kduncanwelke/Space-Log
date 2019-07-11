//
//  DetailViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/19/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	// MARK: Variables
	
	var detailItem: Entry?
	var checkList: [CheckListItem] = []
	var reminderDate: String?
	var reminderNote: String?
	var formatter = DateFormatter()
	var extendedFormatter = DateFormatter()
	var photos: [UIImage] = [UIImage(named: "add")!]
	var imagePicker = UIImagePickerController()
	var filePaths: [String] = []
	var tappedImage: UIImage?
	var currentIndex = 0
	
	// MARK: IBOutlets
	
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var editLabel: UILabel!
	@IBOutlet weak var contentTextView: UITextView!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var listItemTextField: UITextField!
	@IBOutlet weak var reminderButton: UIButton!
	@IBOutlet weak var reminderText: UILabel!
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	@IBOutlet weak var linkTextField: UITextField!
	@IBOutlet weak var goButton: UIButton!
	
	@IBOutlet weak var addToListButton: UIButton!
	

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		NotificationCenter.default.addObserver(self, selector: #selector(reminderDeleted), name: NSNotification.Name(rawValue: "reminderDeleted"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(photoDeleted), name: NSNotification.Name(rawValue: "photoDeleted"), object: nil)
		
		collectionView.dataSource = self
		collectionView.delegate = self
		
		imagePicker.delegate = self
		imagePicker.allowsEditing = false
		imagePicker.sourceType = .photoLibrary
		
		formatter.dateFormat = "MM-dd-yyyy"
		extendedFormatter.dateFormat = "yyyy-MM-dd 'at' hh:mm a"
		
		contentTextView.delegate = self
		titleTextField.delegate = self
		listItemTextField.delegate = self
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableFooterView = UIView(frame: .zero)
		
		reminderButton.layer.cornerRadius = CGFloat(15.0)
		reminderButton.clipsToBounds = true
		reminderButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
		
		addToListButton.layer.cornerRadius = CGFloat(15.0)
		addToListButton.clipsToBounds = true
		addToListButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
		
		configureView()
	}
	
	// MARK: Custom functions
	
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
				
				if let date = reminder.date, let convertedDate = getDate(from: date) {
					if convertedDate < Date() {
						reminderText.text = "This reminder has expired"
					} else {
						reminderText.text = "Reminder on \(date)"
					}
				}
			}
			
			if let photoList = detail.images, let pathsList = photoList.photoPaths {
				for filePath in pathsList {
					let path = DocumentsManager.documentsURL.appendingPathComponent(filePath).path
					if FileManager.default.fileExists(atPath: path) {
						if let contents = UIImage(contentsOfFile: path) {
							photos.append(contents)
							filePaths.append(filePath)
							print("added")
						}
					} else {
						print("not found")
					}
				}
				
				collectionView.reloadData()
			}
			
			if let link = detail.link {
				linkTextField.text = link.url
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
			filePaths.removeAll()
			linkTextField.text = ""
			photos = [UIImage(named: "add")!]
			collectionView.reloadData()
		}
	}
	
	@objc func reminderDeleted() {
		detailItem?.reminder = nil
		reminderDate = nil
		reminderNote = nil
		reminderButton.setTitle("   Add?   ", for: .normal)
		reminderText.text = "No reminder"
	}
	
	@objc func photoDeleted() {
		let imageID = filePaths[currentIndex - 1]
		let imagePath = DocumentsManager.documentsURL.appendingPathComponent(imageID)
		
		if DocumentsManager.fileManager.fileExists(atPath: imagePath.path) {
			do {
				try DocumentsManager.fileManager.removeItem(at: imagePath)
				print("image deleted")
			} catch let error {
				print("failed to delete with error \(error)")
			}
		}
		
		// reduce index by 1 for filepaths as default add image is not included like it is in image list
		filePaths.remove(at: currentIndex - 1)
		photos.remove(at: currentIndex)
		collectionView.reloadData()
	}
	
	func addImage(pickedImage: UIImage) {
		var date = String(Date.timeIntervalSinceReferenceDate)
		var imageID = date.replacingOccurrences(of: ".", with: "-") + ".png"
		
		let filePath = DocumentsManager.documentsURL.appendingPathComponent("\(imageID)")
		
		do {
			if let pngImageData = pickedImage.pngData() {
				try pngImageData.write(to: filePath)
				filePaths.append("\(imageID)")
			}
		} catch {
			print("couldn't write image")
		}
	}
	
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
		guard let createdDate = extendedFormatter.date(from: stringDate) else {
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
			
			if linkTextField.text != "" {
				var link: Link?
				link = Link(context: managedContext)
				link?.url = linkTextField.text
				
				newEntry.link = link
			}
			
			if checkList.count != 0 {
				var list: List?
				list = List(context: managedContext)
				list?.items = checkList
				
				newEntry.list = list
			}
			
			if filePaths.count != 0 {
				var images: Images?
				images = Images(context: managedContext)
				images?.photoPaths = filePaths
				print(filePaths)
				newEntry.images = images
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
		} else {
			currentEntry.list = nil
		}
		
		if filePaths.count != 0 {
			var images: Images?
			images = Images(context: managedContext)
			images?.photoPaths = filePaths
			print(filePaths)
			currentEntry.images = images
		} else {
			currentEntry.images = nil
		}
		
		if linkTextField.text != "" {
			var link: Link?
			link = Link(context: managedContext)
			link?.url = linkTextField.text
			
			currentEntry.link = link
		} else {
			currentEntry.link = nil
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
		if segue.identifier == "addReminder" {
			let destinationViewController = segue.destination as! AddReminderViewController
			destinationViewController.note = reminderNote
			destinationViewController.stringDate = reminderDate
		} else if segue.identifier == "viewPhoto" {
			let destinationViewController = segue.destination as? ImageViewController
			destinationViewController?.image = tappedImage
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
	
	@IBAction func goPressed(_ sender: UIButton) {
		guard let linkText = linkTextField.text else { return }
		
		if let url = URL(string: linkText) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
	@IBAction func saveTapped(_ sender: UIBarButtonItem) {
		if titleTextField.text == "Enter title . . ." {
			showAlert(title: "Incomplete Entry", message: "Please enter a title")
			return
		} else if contentTextView.text == "Start typing . . ." {
			showAlert(title: "Incomplete Entry", message: "Please enter some log content")
			return
		} else if linkTextField.text != nil {
			if let linkText = linkTextField.text, let url = URL(string: linkText) {
				if UIApplication.shared.canOpenURL(url) {
					// do nothing, link is fine
				} else {
					showAlert(title: "Invalid URL", message: "This link could not be verified - please enter a valid URL")
					return
				}
			}
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

extension DetailViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return photos.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
	
		cell.image.image = photos[indexPath.row]
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let tappedCell = collectionView.cellForItem(at:indexPath) as! PhotoCollectionViewCell
		if tappedCell.image.image == UIImage(named: "add") {
			present(imagePicker, animated: true, completion: nil)
		} else {
			tappedImage = tappedCell.image.image
			currentIndex = indexPath.row
			print(currentIndex)
			performSegue(withIdentifier: "viewPhoto", sender: Any?.self)
		}
	}
}

extension DetailViewController {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			photos.append(pickedImage)
			collectionView.reloadData()
			addImage(pickedImage: pickedImage)
		}
		
		dismiss(animated: true, completion: nil)
	}
}

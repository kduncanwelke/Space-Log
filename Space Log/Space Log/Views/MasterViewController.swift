//
//  MasterViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/19/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

	var detailViewController: DetailViewController? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		navigationItem.leftBarButtonItem = editButtonItem
		
		if let split = splitViewController {
			split.preferredDisplayMode = .allVisible
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: "reload"), object: nil)
		
		tableView.tableFooterView = UIView(frame: .zero)
		loadEntries()
	}

	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	// MARK: Custom functions
	
	func loadEntries() {
		var managedContext = CoreDataManager.shared.managedObjectContext
		var fetchRequest = NSFetchRequest<Entry>(entityName: "Entry")
		
		do {
			EntryManager.entries = try managedContext.fetch(fetchRequest)
			print("reminders loaded")
		} catch let error as NSError {
			showAlert(title: "Could not retrieve data", message: "\(error.userInfo)")
		}
		
		tableView.reloadData()
	}
	
	@objc func reload() {
		loadEntries()
	}
	
	func delete(entry: Entry) {
		var managedContext = CoreDataManager.shared.managedObjectContext
		
		managedContext.delete(entry)
		
		do {
			try managedContext.save()
			print("delete successful")
		} catch {
			print("Failed to save")
		}
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
			
		    if let indexPath = tableView.indexPathForSelectedRow {
		        let object = EntryManager.entries[indexPath.row]
				controller.detailItem = object
			}
			
			controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
			controller.navigationItem.leftItemsSupplementBackButton = true
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return EntryManager.entries.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EntryListTableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "entryListCell", for: indexPath) as! EntryListTableViewCell

		let object = EntryManager.entries[indexPath.row]
		cell.cellTitle.text = object.title
		cell.cellContent.text = object.content
		cell.createdDate.text = object.date
		
		cell.editedDate.text = {
			if object.lastEdited != nil {
				return object.lastEdited
			} else {
				return "N/A"
			}
		}()
		
		if object.list != nil {
			cell.hasList.text = "Yes"
		} else {
			cell.hasList.text = "No"
		}
		
		if object.reminder != nil {
			cell.hasReminder.text = "Yes"
		} else {
			cell.hasReminder.text = "No"
		}
		
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			delete(entry: EntryManager.entries[indexPath.row])
			
			EntryManager.entries.remove(at: indexPath.row)
		    tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
		    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}

	@IBAction func addTapped(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: "showDetail", sender: Any?.self)
	}
	
}


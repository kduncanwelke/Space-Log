//
//  MasterViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/19/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class MasterViewController: UITableViewController {
	
	// MARK: Variables
	
	var searchController = UISearchController(searchResultsController: nil)
	var searchResults = [Entry]()

	//var detailViewController: DetailViewController? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		navigationItem.leftBarButtonItem = editButtonItem
		
		// search setup
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		self.definesPresentationContext = true
		searchController.searchBar.placeholder = "Type to search . . ."
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		
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
	
	func clearNotification(id: Date) {
		// remove existing notification
		let notificationCenter = UNUserNotificationCenter.current()
		let identifier = "\(id)"
		notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
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
		if isFilteringBySearch() {
			return searchResults.count
		} else {
			return EntryManager.entries.count
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> EntryListTableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "entryListCell", for: indexPath) as! EntryListTableViewCell
		
		var object: Entry
		
		if isFilteringBySearch() {
			object = searchResults[indexPath.row]
		} else {
			object = EntryManager.entries[indexPath.row]
		}

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
			var entryToDelete: Entry
			
			if isFilteringBySearch() {
				entryToDelete = searchResults[indexPath.row]
			} else {
				entryToDelete = EntryManager.entries[indexPath.row]
			}
			
			if entryToDelete.reminder != nil {
				if let id = entryToDelete.reminder?.id {
					clearNotification(id: id)
				}
			}
			
			delete(entry: entryToDelete)
			
			if isFilteringBySearch() {
				searchResults.remove(at: indexPath.section)
				tableView.deleteRows(at: [indexPath], with: .fade)
			} else {
				EntryManager.entries.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .fade)
			}
		} else if editingStyle == .insert {
		    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}

	@IBAction func addTapped(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: "showDetail", sender: Any?.self)
	}
	
}

// MARK: Extensions

extension MasterViewController: UISearchControllerDelegate, UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let searchText = searchController.searchBar.text else { return }
		filterSearch(searchText)
	}
	
	func searchBarIsEmpty() -> Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	// return search results based on title and entry body text
	func filterSearch(_ searchText: String) {
	
		searchResults = EntryManager.entries.filter({(entry: Entry) -> Bool in
			return entry.title!.lowercased().contains(searchText.lowercased()) || entry.content!.lowercased().contains(searchText.lowercased()) || entry.date!.contains(searchText.lowercased())
		})
		
		tableView.reloadData()
		
		// scroll to top upon showing results
		if searchResults.count != 0 {
			let indexPath = IndexPath(row: 0, section: 0)
			tableView.scrollToRow(at: indexPath, at: .top, animated: true)
		}
	}
	
	func isFilteringBySearch() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBar.endEditing(true)
	}
}
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
	var addTapped = false
	var isDeleting = false

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
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
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
		
		if isDeleting == false {
			tableView.reloadData()
		} else {
			// don't reload table as it breaks delete animation, reset bool
			isDeleting = false
		}
		
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
			
			if addTapped {
				controller.detailItem = nil
				addTapped = false
				
				if tableView.indexPathForSelectedRow != nil {
					tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
				}
			} else if let indexPath = tableView.indexPathForSelectedRow {
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
		
		if object.reminder == nil {
			cell.reminderIndicator.image = UIImage(named: "noreminder")
		} else {
			cell.reminderIndicator.image = UIImage(named: "reminder")
		}
		
		if object.images == nil {
			cell.photoIndicator.image = UIImage(named: "nophoto")
		} else {
			cell.photoIndicator.image = UIImage(named: "photo")
		}
		
		if object.link == nil {
			cell.urlIndicator.image = UIImage(named: "nourl")
		} else {
			cell.urlIndicator.image = UIImage(named: "url")
		}
		
		if object.list == nil {
			cell.listIndicator.image = UIImage(named: "nolist")
		} else {
			cell.listIndicator.image = UIImage(named: "list")
		}
		
		if object.location == nil {
			cell.location.isHidden = true
		} else {
			cell.location.isHidden = false
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
			
			// delete any reminder with its associated notification
			if entryToDelete.reminder != nil {
				if let id = entryToDelete.reminder?.id {
					clearNotification(id: id)
				}
			}
			
			// delete any images that are saved in documents manager
			if entryToDelete.images != nil {
				if let pathsList = entryToDelete.images?.photoPaths {
					for path in pathsList {
						let imageID = path
						let imagePath = DocumentsManager.documentsURL.appendingPathComponent(imageID)
						
						if DocumentsManager.fileManager.fileExists(atPath: imagePath.path) {
							do {
								try DocumentsManager.fileManager.removeItem(at: imagePath)
								print("image deleted")
							} catch let error {
								print("failed to delete with error \(error)")
							}
						}
					}
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
			
			isDeleting = true
			
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
		} else if editingStyle == .insert {
		    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}

	@IBAction func addTapped(_ sender: UIBarButtonItem) {
		addTapped = true
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
			return entry.title?.lowercased().contains(searchText.lowercased()) ?? false || entry.content?.lowercased().contains(searchText.lowercased()) ?? false || entry.date?.contains(searchText.lowercased()) ?? false
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

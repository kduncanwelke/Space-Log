//
//  AddLocationViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 7/12/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddLocationViewController: UIViewController, UITableViewDelegate {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var topLabel: UILabel!
	@IBOutlet weak var addLocationButton: UIButton!
	
	// MARK: Variables
	
	var locationFromMapOrCurrent = false
	var searchController = UISearchController(searchResultsController: nil)
	var locationManager = CLLocationManager()
	var usingSavedLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startUpdatingLocation()
		
		// set up search bar
		let resultsTableController = SearchTableViewController()
		resultsTableController.mapView = mapView
		resultsTableController.delegate = self
		
		// set up search controller for map search
		searchController = UISearchController(searchResultsController: resultsTableController)
		searchController.searchResultsUpdater = resultsTableController
		searchController.searchBar.autocapitalizationType = .none
		
		searchController.searchBar.placeholder = "Type to a find location . . ."
		searchController.delegate = self
		searchController.searchBar.delegate = self // Monitor when the search button is tapped.
		
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
		
		if usingSavedLocation {
			topLabel.text = "Viewing Saved Location"
			addLocationButton.setTitle("   Save New Location   ", for: .normal)
			locationLabel.text = LocationSearch.name
		} else {
			topLabel.text = "Please select a location to associate with this entry"
			addLocationButton.setTitle("   Add Location   ", for: .normal)
			locationLabel.text = "-"
		}
    }
	
	// MARK: Custom functions
	
	func updateLocation(location: MKPlacemark) {
		// wipe annotations if location was updated
		mapView.removeAnnotations(mapView.annotations)
		
		let coordinate = CLLocationCoordinate2D(latitude: LocationSearch.latitude, longitude: LocationSearch.longitude)
		
		let regionRadius: CLLocationDistance = 10000
		
		let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		
		let annotation = MKPointAnnotation()
		
		// if location came from map tap, parse address to assign it to title for pin
		if self.locationFromMapOrCurrent {
			let locale = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			let geocoder = CLGeocoder()
			
			geocoder.reverseGeocodeLocation(locale, completionHandler: { [unowned self] (placemarks, error) in
				if error == nil {
					guard let firstLocation = placemarks?[0] else { return }
					annotation.title = LocationSearch.parseAddress(selectedItem: firstLocation)
					self.locationLabel.text = annotation.title
				}
				else {
					// an error occurred during geocoding
					self.showAlert(title: "Network Lost", message: "The location cannot be found - please check your network connection")
				}
			})
		} else {
			// otherwise use location that was included with location object, which came from a search
			annotation.title = LocationSearch.parseAddress(selectedItem: location)
		}
		
		annotation.coordinate = coordinate
		mapView.addAnnotation(annotation)
		mapView.setRegion(region, animated: true)
		
		locationLabel.text = annotation.title
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: IBActions
	
	@IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			let tappedLocation = sender.location(in: mapView)
			let coordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
			let placemark = MKPlacemark(coordinate: coordinate)
			LocationSearch.latitude = placemark.coordinate.latitude
			LocationSearch.longitude = placemark.coordinate.longitude
			locationFromMapOrCurrent = true
			updateLocation(location: placemark)
		}
	}
	
	
	@IBAction func useDeviceLocationTapped(_ sender: UIButton) {
		locationManager.requestLocation()
	}
	
	
	@IBAction func addLocationTapped(_ sender: UIButton) {
		if mapView.annotations.isEmpty {
			showAlert(title: "No location selected", message: "Please choose a location to add")
			return
		}
		
		guard let name = locationLabel.text else { return }
		LocationSearch.name = name
		
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "locationAdded"), object: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func cancelTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

extension AddLocationViewController: MapUpdaterDelegate {
	// delegate used to pass location from search
	func updateMapLocation(for location: MKPlacemark) {
		updateLocation(location: location)
	}
}

extension AddLocationViewController: MKMapViewDelegate, CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if usingSavedLocation == false {
			if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude, let location = locations.last {
				locationManager.stopUpdatingLocation()
				print("current location: \(lat) \(long)")
				
				locationFromMapOrCurrent = true
				LocationSearch.latitude = lat
				LocationSearch.longitude = long
				
				var coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
				var loc = MKPlacemark(coordinate: coord)
				updateLocation(location: loc)
			}
		} else {
			var coord = CLLocationCoordinate2D(latitude: LocationSearch.latitude, longitude: LocationSearch.longitude)
			var loc = MKPlacemark(coordinate: coord)
			locationFromMapOrCurrent = true
			updateLocation(location: loc)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
	
}

extension AddLocationViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
	// function needed to satisfy compiler
	func updateSearchResults(for searchController: UISearchController) {
	}
}


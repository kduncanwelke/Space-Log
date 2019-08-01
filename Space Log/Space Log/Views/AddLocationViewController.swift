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
	@IBOutlet weak var deleteLocationButton: UIButton!
	@IBOutlet weak var useDeviceLocationButton: UIButton!
	
	
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
		
		addLocationButton.layer.cornerRadius = CGFloat(15.0)
		addLocationButton.clipsToBounds = true
		addLocationButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
		
		deleteLocationButton.layer.cornerRadius = CGFloat(15.0)
		deleteLocationButton.clipsToBounds = true
		deleteLocationButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
		
		useDeviceLocationButton.layer.cornerRadius = CGFloat(15.0)
		useDeviceLocationButton.clipsToBounds = true
		useDeviceLocationButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
		
		if usingSavedLocation {
			topLabel.text = "Viewing Saved Location"
			addLocationButton.setTitle("   Save New Location   ", for: .normal)
			locationLabel.text = LocationSearch.name
			
			deleteLocationButton.backgroundColor = .red
			deleteLocationButton.isEnabled = true
		} else {
			topLabel.text = "Please select a location"
			addLocationButton.setTitle("   Add Location   ", for: .normal)
			locationLabel.text = "-"
			
			deleteLocationButton.backgroundColor = .black
			deleteLocationButton.isEnabled = false
		}
    }
	
	override func viewDidAppear(_ animated: Bool) {
		// perform check for location services access, as this is the main area that depends on location
		if CLLocationManager.locationServicesEnabled() {
			switch CLLocationManager.authorizationStatus() {
			case .notDetermined, .restricted, .denied:
				showSettingsAlert(title: "Location undetermined", message: "Location services have not been enabled. Device location will not be detectable until settings are adjusted.")
			case .authorizedAlways, .authorizedWhenInUse:
				print("access")
			@unknown default:
				return
			}
		} else {
			showAlert(title: "Notice", message: "Location services are not available - location will have to be selected for entries manually.")
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
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
	
	@IBAction func deleteLocationTapped(_ sender: UIButton) {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "locationDeleted"), object: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func cancelTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

// MARK: Extensions

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


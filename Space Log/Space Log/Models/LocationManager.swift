//
//  LocationManager.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 7/12/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import MapKit

struct LocationSearch {
	static var latitude: Double = 0
	static var longitude: Double = 0
	static var name: String = ""
	
	static func parseAddress(selectedItem: CLPlacemark) -> String {
		// put a space between "4" and "Melrose Place"
		let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
		// put a comma between street and city/state
		let comma = (selectedItem.locality != nil || selectedItem.administrativeArea != nil) && (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
		// put a space between "Washington" and "DC"
		let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? ", " : ""
		let addressLine = String(
			format:"%@%@%@",//%@%@%@%@%@",
			// street number
			//selectedItem.subThoroughfare ?? "",
			//firstSpace,
			// street name
			//selectedItem.thoroughfare ?? "",
			//comma,
			// city
			selectedItem.locality ?? "",
			secondSpace,
			// state
			selectedItem.administrativeArea ?? ""
		)
		return addressLine
	}
}

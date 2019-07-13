//
//  Protocol.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/22/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import MapKit

protocol CellCheckDelegate: class {
	func didChangeSelectedState(sender: CheckListTableViewCell, isChecked: Bool)
}

// handle updating map location when locale is changed
protocol MapUpdaterDelegate: class {
	func updateMapLocation(for: MKPlacemark)
}

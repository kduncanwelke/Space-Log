//
//  Protocol.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/22/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

protocol CellCheckDelegate: class {
	func didChangeSelectedState(sender: CheckListTableViewCell, isChecked: Bool)
}

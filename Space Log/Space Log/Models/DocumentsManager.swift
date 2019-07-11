//
//  DocumentsManager.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 7/11/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct DocumentsManager {
	static let fileManager = FileManager.default
	static let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!	
}

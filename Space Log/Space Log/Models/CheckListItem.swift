//
//  CheckListItem.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/20/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

public class CheckListItem: NSObject, NSCoding {
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(item, forKey: "item")
		aCoder.encode(isComplete, forKey: "isComplete")
	}
	
	public required init?(coder aDecoder: NSCoder) {
		item = aDecoder.decodeObject(forKey: "item") as! String
		isComplete = aDecoder.decodeBool(forKey: "isComplete")
	}
	
	var item: String
	var isComplete: Bool
	
	init(item: String, isComplete: Bool) {
		self.item = item
		self.isComplete = isComplete
	}
}

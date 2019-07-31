//
//  Extensions.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/20/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit

extension UISplitViewController {
	var primaryViewController: MasterViewController? {
		let navController = self.viewControllers.first as? UINavigationController
		return navController?.topViewController as? MasterViewController
	}
}

extension UIViewController {
	func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func showSettingsAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { value in
			let path = UIApplication.openSettingsURLString
			if let settingsURL = URL(string: path), UIApplication.shared.canOpenURL(settingsURL) {
				UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
			}
		})
		self.present(alert, animated: true, completion: nil)
	}
}


// handle status bar color
extension UISplitViewController {
	open override var preferredStatusBarStyle: UIStatusBarStyle {
		let master = viewControllers.first
		return master?.preferredStatusBarStyle ?? .default
	}
}

extension UINavigationController {
	open override var preferredStatusBarStyle: UIStatusBarStyle {
		return topViewController?.preferredStatusBarStyle ?? .default
	}
}


extension UIView
{
	func fixInputAssistant()
	{
		for subview in self.subviews
		{
			if type(of: subview) is UITextField.Type
			{
				let item = (subview as! UITextField).inputAssistantItem
				item.leadingBarButtonGroups = []
				item.trailingBarButtonGroups = []
			}
			else if subview.subviews.count > 0
			{
				subview.fixInputAssistant()
			}
		}
	}
}

//
//  NotificationManager.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/24/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationManager {
	
	static func addTimeBasedNotification(for reminder: Reminder) {
		let identifier = "\(reminder.id)"
		
		let notificationCenter = UNUserNotificationCenter.current()
		let notificationContent = UNMutableNotificationContent()
		
		guard let title = reminder.note, let date = reminder.date else { return }
		notificationContent.title = "Space Log Reminder"
		notificationContent.body = "\(title)"
		notificationContent.sound = UNNotificationSound.default
		
		var formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd 'at' hh:mm a"
		guard let dateToUse = formatter.date(from: date) else { return }
		
		// convert to calendar date
		var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateToUse)
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
		let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
		
		notificationCenter.add(request) { (error) in
			if error != nil {
				print("Error adding notification with identifier: \(identifier)")
			}
		}
		
		print("notification added")
	}
}

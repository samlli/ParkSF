//
//  NotificationManager.swift
//  ParkSF
//
//  Created by Samuel Li on 5/21/24.
//

import Foundation
import UserNotifications

struct NotificationSetting: Identifiable {
    let id: String
    var minutesBefore: Int
    var enabled: Bool
}

class NotificationManager: ObservableObject {
    @Published var notifications: [NotificationSetting] = []
    
    func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission request error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for sweepingInfo: StreetSweepingInfo, minutesBefore: Int) {
        let center = UNUserNotificationCenter.current()
        
        guard let sweepingDate = getNextSweepingDate(from: sweepingInfo) else {
            print("Invalid sweeping date")
            return
        }
        
        let notificationDate = sweepingDate.addingTimeInterval(TimeInterval(-minutesBefore * 60))
        
        let content = UNMutableNotificationContent()
        content.title = "Street Sweeping Alert"
        content.body = "Street sweeping on \(sweepingInfo.fullname ?? "") starts at \(sweepingInfo.fromhour ?? ""). Move your car!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationDate.timeIntervalSinceNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func getNextSweepingDate(from info: StreetSweepingInfo) -> Date? {
        // Parse the fromhour and tohour to determine the next sweeping date
        // Assuming the schedule is weekly, find the next date based on the current date and the weekday
        // This is a simplified version. You might need more sophisticated date parsing depending on the format
        return Date()
    }
}

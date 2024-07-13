//
//  NotificationsView.swift
//  ParkSF
//
//  Created by Samuel Li on 5/21/24.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var notificationsManager: NotificationManager
    @State private var showingAddNotification = false
    
    var body: some View {
        VStack {
            List {
                ForEach(notificationsManager.notifications) { notification in
                    HStack {
                        Text("\(notification.minutesBefore) minutes before")
                        Spacer()
                        Toggle("Enabled", isOn: $notificationsManager.notifications[notification.id].enabled)
                            .labelsHidden()
                    }
                    .onTapGesture {
                        showingAddNotification = true
                    }
                }
                .onDelete { indexSet in
                    notificationsManager.notifications.remove(atOffsets: indexSet)
                }
            }
            Button("Add Notification") {
                showingAddNotification = true
            }
        }
        .sheet(isPresented: $showingAddNotification) {
            AddNotificationView(notificationsManager: notificationsManager)
        }
        .navigationTitle("Notifications")
    }
}

struct AddNotificationView: View {
    @ObservedObject var notificationsManager: NotificationManager
    @State private var minutesBefore = 30
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Minutes Before Street Sweeping")) {
                    Stepper(value: $minutesBefore, in: 1...1440, step: 1) {
                        Text("\(minutesBefore) minutes")
                    }
                }
                Button("Save") {
                    let newNotification = NotificationSetting(id: UUID().uuidString, minutesBefore: minutesBefore, enabled: true)
                    notificationsManager.notifications.append(newNotification)
                    // Assuming we have a StreetSweepingInfo object for scheduling
                    // notificationsManager.scheduleNotification(for: <StreetSweepingInfo>, minutesBefore: newNotification.minutesBefore)
                }
            }
            .navigationTitle("Add Notification")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        notificationsManager.dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    NotificationsView()
//}

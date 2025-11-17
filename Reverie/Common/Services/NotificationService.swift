////
////  NotificationService.swift
////  Reverie
////
////  Created by Nithya Ravula on 11/16/25.
////
//
import Foundation
import UserNotifications
import Combine

class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { success, error in

            if let error = error {
                print("🔴 Notification permission error: \(error.localizedDescription)")
                return
            }

            if success {
                print("🟢 Notifications authorized!")
                
                Task {
                    await self.scheduleNotificationsFromSleep()
                }

            } else {
                print("🟡 Notifications *not* authorized by user")
            }
        }
    }

    func scheduleNotificationsFromSleep() async {
        guard let sleep = await HealthKitService.shared.getSleepTimes() else {
            print("⚠️ No sleep time available")
            self.scheduleNotification(
                title: "Good morning!",
                body: "How did you sleep? Log your dream 🌙",
                hour: 00,
                minute: 00
            )
            return
        }

        print(sleep.bedtime)
        print(sleep.wakeUpTime)

        let bedtime = Calendar.current.dateComponents([.hour, .minute], from: sleep.bedtime)
//        let wakeup = /*Calendar.current.dateComponents([.hour, .minute], from: sleep.wakeUpTime)*/DateComponents(hour: 23, minute: 14)
        let wakeup = DateComponents(
            calendar: Calendar.current,
            timeZone: .current,
            hour: 23,
            minute: 18
        )

        if let hour = bedtime.hour, let minute = bedtime.minute {
            scheduleNotification(
                title: "Good night!",
                body: "Time to get ready for bed 😴",
                hour: hour,
                minute: minute
            )
        }

        if let hour = wakeup.hour, let minute = wakeup.minute {
            scheduleNotification(
                title: "Good morning!",
                body: "How did you sleep? Log your dream 🌙",
                hour: hour,
                minute: minute
            )
        }
    }

    func scheduleNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔴 Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("🟢 Scheduled notification at \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    func removeNotification(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }

    func removeAllNotifications() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.banner, .sound])
    }
}

//
//  AppDelegate.swift
//  historic city tours
//
//  Created by Tim Bachmann on 24.07.2024.
//

import Foundation
import UIKit

/**
 AppDelegate to manage notifications
 */
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /**
     Sets notification center delegate after launch
     */
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    /**
     Resets icon badge after launch
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().setBadgeCount(0)
        return true
    }
    
    /**
     Resets icon badge when app becomes active
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    /**
     Resets icon badge when app will enter foreground
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /**
     Receive notification when application is in foreground
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let notificationName = Notification.Name("ARExplorer")
        NotificationCenter.default.post(name:notificationName , object: notification.request.content)
        completionHandler([.banner, .sound])
    }
    
    /**
     Receive notification when application is in background
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationName = Notification.Name("ARExplorer")
        NotificationCenter.default.post(name:notificationName , object: response.notification.request.content)
        completionHandler()
    }
}

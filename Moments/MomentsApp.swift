//
//  MomentsApp.swift
//  Moments
//
//  Created by Zachary Tao on 3/23/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging

struct ErrorMessage{
    static var errorMessage = ""
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.Message_ID"
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication
                        .LaunchOptionsKey: Any]?) -> Bool {
                            FirebaseApp.configure()
                            do{
                                if let teamId = ProcessInfo.processInfo.environment["teamId"]{
                                    try Auth.auth().useUserAccessGroup("\(teamId).edu.vanderbilt.zachtao.Moments")
                                }
                            }catch{
                                print("firebase configure error: \(error.localizedDescription)")
                            }
                            
                            // [START set_messaging_delegate]
                            Messaging.messaging().delegate = self
                            // [END set_messaging_delegate]
                            
                            // Register for remote notifications. This shows a permission dialog on first run, to
                            // show the dialog at a more appropriate time move this registration accordingly.
                            // [START register_for_notifications]
                            
                            UNUserNotificationCenter.current().delegate = self
                            
                            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                            UNUserNotificationCenter.current().requestAuthorization(
                                options: authOptions,
                                completionHandler: { _, _ in }
                            )
                            
                            application.registerForRemoteNotifications()
                            
                            // [END register_for_notifications]
                            
                            return true
                        }
    
}

@main
struct MomentsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AuthenticatedView{
                
            }content: {
                HomeView()
                    .fontDesign(.rounded)
            }
        }
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // ...
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        return [[.banner,.badge, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        return UIBackgroundFetchResult.newData
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    
    
}



extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        let db = Firestore.firestore().collection("Users")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("error getting user id for message delegate")
            ErrorMessage.errorMessage = "error getting user id for message delegate"
            return}
        guard let fcmToken else{
            print("Error fcmToken is null")
            ErrorMessage.errorMessage = "error getting user id for message delegate"
            return}
        Task{
            do{
                if let userInstance = try await db.whereField("userId", isEqualTo: userId).limit(to: 1).getDocuments().documents.first?.documentID
                {
                    try await db.document(userInstance).setData(["FCMtoken": fcmToken], merge: true)
                }
                
                
            }catch{
                print("Error saving FCM token: \(error.localizedDescription)")
                ErrorMessage.errorMessage = "Error is here" + error.localizedDescription
            }
        }
    }
    
}

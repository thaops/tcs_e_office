import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // QUAN TRỌNG: Set UNUserNotificationCenter delegate cho iOS
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    // QUAN TRỌNG: Register for remote notifications
    DispatchQueue.main.async {
      application.registerForRemoteNotifications()
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication,
                          didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ Registered for remote notifications - iOS")
    print("✅ Device token length: \(deviceToken.count)")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  override func application(_ application: UIApplication,
                          didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
  
  // QUAN TRỌNG: Xử lý notification khi app ở foreground
  @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("📱 Notification received in foreground: \(notification.request.identifier)")
    
    // Hiển thị notification ngay cả khi app ở foreground
    // iOS 14+: .banner, .sound, .badge
    // iOS 13-: .alert, .sound, .badge
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
  
  // QUAN TRỌNG: Xử lý khi user click vào notification
  @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      didReceive response: UNNotificationResponse,
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
    print("📱 Notification clicked: \(response.notification.request.identifier)")
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    completionHandler()
  }
}

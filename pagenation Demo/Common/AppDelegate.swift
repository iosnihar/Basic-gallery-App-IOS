//
//  AppDelegate.swift
//  pagenation Demo
//
//  Created by Admin on 28/04/23.
//

import UIKit
import Kingfisher
import GoogleSignIn

@available(iOS 16.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                // Show GoogleVC to sign in again
                self.showGoogleSignIn()
            } else {
                // Successfully restored previous sign-in
                self.showCollectionView()
            }
        }

        return true
    }
    func showCollectionView() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let collectionVC = storyboard.instantiateViewController(withIdentifier: "CollectionViewVC") as? CollectionViewVC {
                self.window?.rootViewController = collectionVC
            }
        }

        func showGoogleSignIn() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let googleVC = storyboard.instantiateViewController(withIdentifier: "GoogleVC") as? GoogleVC {
                self.window?.rootViewController = googleVC
            }
        }
    
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool

      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

      // Handle other custom URL types.

      // If not handled by this app, return false.
      return false
    }
    func sign(_ signIn: GIDSignIn!,
              didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        
        // Check for sign in error
        if let error = error {
            if (error as NSError).code == GIDSignInError.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
           
            return
        }

        // Post notification after user successfully sign in
        NotificationCenter.default.post(name: .signInGoogleCompleted, object: nil)
    }
}

// MARK:- Notification names
extension Notification.Name {
    
    /// Notification when user successfully sign in using Google
    static var signInGoogleCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


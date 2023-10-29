//
//  GoogleVC.swift
//  pagenation Demo
//
//  Created by Nihar Vaghela on 28/10/23.
//

import UIKit
import GoogleSignIn

@available(iOS 16.0, *)
class GoogleVC: UIViewController {
    
    @IBOutlet weak var btnSignin: UIButton!
   
 

    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Show sign in button
        btnSignin.isHidden = false
        
        // Register notification to update screen after user successfully signed in
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidSignInGoogle(_:)),
                                               name: .signInGoogleCompleted,
                                               object: nil)
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            // User is already signed in, skip the login screen
            showMainContent()
        } else {
            
        }
        
    }
   @IBAction func signIn(sender: Any) {
     GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
         if let error = error {
             print("Google Sign-In error: \(error.localizedDescription)")
             return
         }
         // Successful sign-in
         self.showMainContent()
     }
   }
    @objc private func userDidSignInGoogle(_ notification: Notification) {
           // Handle user sign-in using the notification
           showMainContent()
       }

       func showMainContent() {
           let user = GIDSignIn.sharedInstance.currentUser
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "CollectionViewVC") as! CollectionViewVC
           
           UserDefaults.standard.set(user?.profile?.email, forKey: "email")
           UserDefaults.standard.set(user?.profile?.name, forKey: "name")
           UserDefaults.standard.set(true, forKey: "isLogin")
           
           self.navigationController?.pushViewController(vc, animated: true)
       }
}

//
//  AppDelegate.swift
//  Texty
//
//  Created by Jeslin Yeoh on 25/12/2021.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self

        
        return true
    }
    
    
    
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)

    }
    
    
    

}


// MARK: - GIDSignInDelegate
extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        
        print("Did sign in with Google: \(user)")
            
        guard let email = user.profile.email,
                let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
                  return
              }
        
        // cache user email to retrieve info from Firestore
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
    
        
        
        DatabaseManager.shared.userExists(with: email, completion: { exists in
            if !exists {
                // insert to database
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        
                        // Check if user have Google profile picture
                        if user.profile.hasImage {
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    return
                                }
                                
                                // upload image
                                let fileName = chatUser.profilePictureFileName
                                // completion is (Result<String, Error>) -> Void
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in

                                    switch result {
                                    case .success(let  downloadURL):

                                        // save to cache
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        print(downloadURL)

                                    case .failure(let error):
                                        print("Storage manager (FB) error: \(error)")
                                    }
                                })
                            }).resume() // ask URL dataTask to begin
                            
                            
                        }

                        
                    }
                })
            }
        })
        
        guard let authentication = user.authentication else {
            print("Missing auth object of Google user.")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
            
            guard authResult != nil, error == nil else {
                print("Failed to log in with Google.")
                return
            }
            
            print("Successfully signed in with Google.")
            
            // call function from LoginViewController to dismiss the login screen
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        })
            
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        print("Google user was disconnected.")
    }
    
}

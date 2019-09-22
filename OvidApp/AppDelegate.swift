//
//  AppDelegate.swift
//  OvidApp
//
//  Created by Jan Cho on 9/4/19.
//  Copyright © 2019 Jan Cho. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    var signInCallback: (()->())?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self

        return true
    }
    
    // Authenticate user with Google SignIn
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error.localizedDescription)
        } else {
            print("Wow! Our user signed in! \(String(describing: user))")
            
            // Get Google ID token and Google access token from the GIDAuthentication object and exchange them for a Firebase credential
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            // Authenticate user in Firebase
            Auth.auth().signIn(with: credential) { (result, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print(result?.user.email ?? "Email missing")
                    print(result?.user.displayName ?? "Username missing")
                    
//                self.window?.rootViewController!.performSegue(withIdentifier: "ViewController", sender: nil)
                }
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")

            let rootViewController = self.window!.rootViewController as! UINavigationController
            rootViewController.pushViewController(viewController, animated: true)
        }
    }
    
    
    // Call the handleURL method of the GIDSignIn instance, which will properly handle the URL that your application receives at the end of the authentication process
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return (GIDSignIn.sharedInstance()?.handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:]))!
    }
    
    // For app to run on iOS 8 and older, implement the deprecated method
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return (GIDSignIn.sharedInstance()?.handle(url, sourceApplication: sourceApplication, annotation: annotation))!
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


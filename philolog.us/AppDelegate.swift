//
//  AppDelegate.swift
//  philolog.us
//
//  Created by Jeremy March on 5/21/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

/*
 /Users/jeremy/Library/Developer/CoreSimulator/Devices/3A765A42-5B22-45D9-88CD-5B1A7A54AC5E/data/Containers/Data/Application/0B3F219C-9BF0-4A56-9682-9DD7FFE3E03A/Library/Application Supports
 
 INSERT INTO A.ZGREEKWORDS VALUES () FROM B.ZGREEKWORDS;
 */

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    //http://stackoverflow.com/questions/34037274/shouldautorotate-not-working-with-navigation-controllar-swift-2
    //var shouldSupportAllOrientation = false
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return UIInterfaceOrientationMask.portrait
        }
        else
        {
            return UIInterfaceOrientationMask.all
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = self.persistentContainer.viewContext
        return true
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    // MARK: - Core Data stack
    
    //https://stackoverflow.com/questions/22582020/crash-when-using-nsreadonlypersistentstoreoption

    lazy var persistentContainer: NSPersistentContainer = {
        let appName = "philolog_us"
        
        let container = NSPersistentContainer(name: appName)
        
        let seededData: String = appName
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        //let storeUrl = self.applicationDocumentsDirectory.appendingPathComponent("app_name.sqlite")
        //let storeURL = [[NSBundle mainBundle] URLForResource:@"philologus" withExtension:@"sqlite"];
        let storeURL = Bundle.main.url(forResource: appName, withExtension: "sqlite")
      /*
        if !FileManager.default.fileExists(atPath: (storeURL?.path)!) {
            let seededDataUrl = Bundle.main.url(forResource: seededData, withExtension: "sqlite")
            try! FileManager.default.copyItem(at: seededDataUrl!, to: storeURL!)
            
        }
 */
        print(storeURL!)
        //var options = NSMutableDictionary()
        //options[NSReadOnlyPersistentStoreOption] = true
        
        //container.persistentStoreCoordinator.addPersistentStore(ofType: <#T##String#>, configurationName: <#T##String?#>, at: <#T##URL?#>, options: <#T##[AnyHashable : Any]?#>)
        
        let d:NSPersistentStoreDescription = NSPersistentStoreDescription(url: storeURL!)
        d.setOption(true as NSObject, forKey: NSReadOnlyPersistentStoreOption)
        d.setOption(["journal_mode": "delete"] as NSObject!, forKey: NSSQLitePragmasOption)
        container.persistentStoreDescriptions = [d]
        
        //persistentStoreDescriptions.setOption(true as NSObject, forKey: NSReadOnlyPersistentStoreOption)
        //container.persistentStoreCoordinator.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                
                fatalError("Unresolved error \(error),")
            }
        })
        
        return container
    }()
 
    /*
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "philolog_us")
        //container.persistentStoreDescriptions[0].setOption(, forKey: )
        container.persistentStoreDescriptions[0].setOption(true as NSObject, forKey: NSReadOnlyPersistentStoreOption)
        container.persistentStoreDescriptions[0].setOption(["journal_mode": "delete"] as NSObject!, forKey: NSSQLitePragmasOption)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
*/
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension NSPersistentContainer {
    
    public convenience init(name: String, bundle: Bundle) {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Unable to located Core Data model")
        }
        
        self.init(name: name, managedObjectModel: mom)
    }
    
}


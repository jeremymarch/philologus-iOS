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
 updating core data model.
 best done on iOS simulator for earliest iOS version supported
 change bundle db to point to app directory so it can create a new db.
 change options for that db to disable readonly
 have it print path to where the db is stored in simulator
 stop simulator
 in terminal cd to new db path retrieved above
 from this location in terminal open paradigm db (with orig data) in sqlite3
 now in sqlite3:
 sqlite> attach 'philolog_us.sqlite' as newdb;
 sqlite> INSERT INTO newdb.ZGREEKDEFS SELECT * FROM ZGREEKDEFS;
 sqlite> INSERT INTO newdb.ZGREEKWORDS SELECT * FROM ZGREEKWORDS;
 sqlite> INSERT INTO newdb.ZLATINWORDS SELECT * FROM ZLATINWORDS;
 sqlite> INSERT INTO newdb.ZLATINDEFS SELECT * FROM ZLATINDEFS;
 sqlite> vacuum;
 sqlite> .exit
 
 in terminal copy db from simulator back to xcode project in orig location
 change store to point back to the bundle and enable readonly
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
        if #available(iOS 10.0, *) {
            controller.managedObjectContext = self.persistentContainer.viewContext
        }
        else
        {
            controller.managedObjectContext = managedObjectContext
        }
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
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let appName = "philolog_us"
        
        let container = NSPersistentContainer(name: appName)
        
        let seededData: String = appName
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        //let storeUrl = self.applicationDocumentsDirectory.appendingPathComponent("app_name.sqlite")
        //let storeURL = [[NSBundle mainBundle] URLForResource:@"philologus" withExtension:@"sqlite"];
        let storeURL = Bundle.main.url(forResource: appName, withExtension: "sqlite")
        //let storeURL = self.applicationDocumentsDirectory.appendingPathComponent(appName + ".sqlite")
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
        d.setOption(["journal_mode": "delete"] as NSObject?, forKey: NSSQLitePragmasOption)
        
        let userDataURL = self.applicationDocumentsDirectory.appendingPathComponent("userData.sqlite")
        
        let d2:NSPersistentStoreDescription = NSPersistentStoreDescription(url: userDataURL)
        d2.setOption(false as NSObject, forKey: NSReadOnlyPersistentStoreOption)
        d2.setOption(["journal_mode": "delete"] as NSObject?, forKey: NSSQLitePragmasOption)
        
        container.persistentStoreDescriptions = [d,d2]
        
        //persistentStoreDescriptions.setOption(true as NSObject, forKey: NSReadOnlyPersistentStoreOption)
        //container.persistentStoreCoordinator.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                
                fatalError("Unresolved error \(error),")
            }
        })
        
        return container
    }()
    
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "philolog_us", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("philolog_us.sqlite")
        //let url = Bundle.main.url(forResource: "philolog_us", withExtension: "sqlite")!
        print(url)
        let userDataURL = self.applicationDocumentsDirectory.appendingPathComponent("userData.sqlite")

        var failureReason = "There was an error creating or loading the application's saved data."
        
        let opt = [ NSReadOnlyPersistentStoreOption: false as NSObject,
                    NSSQLitePragmasOption: ["journal_mode": "delete"] as NSObject?,
                    NSMigratePersistentStoresAutomaticallyOption:false as NSObject,
                    NSInferMappingModelAutomaticallyOption:false as NSObject]
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "bundleData", at: url, options: opt as Any as? [AnyHashable : Any])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        let opt2 = [ NSReadOnlyPersistentStoreOption: false as NSObject,
                    NSSQLitePragmasOption: ["journal_mode": "delete"] as NSObject?,
                    NSMigratePersistentStoresAutomaticallyOption:false as NSObject,
                    NSInferMappingModelAutomaticallyOption:false as NSObject]
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "userData", at: userDataURL, options: opt2 as Any as? [AnyHashable : Any])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
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
    
    if #available(iOS 10.0, *) {
        
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
            
        } else {
            // iOS 9.0 and below - however you were previously handling it
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
            
        }
    }
}
}

@available(iOS 10.0, *)
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


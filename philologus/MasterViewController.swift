//
//  MasterViewController.swift
//  philolog.us
//
//  Created by Jeremy March on 5/21/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//
/*
/Users/jeremy/Library/Developer/CoreSimulator/Devices/3A765A42-5B22-45D9-88CD-5B1A7A54AC5E/data/Containers/Data/Application/0B3F219C-9BF0-4A56-9682-9DD7FFE3E03A/Library/Application Support
*/

import UIKit
import CoreData

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,UITextFieldDelegate {
    @IBOutlet var tableView:UITableView!
    @IBOutlet var langButton:UIButton!
    @IBOutlet var searchTextField:PHTextField!
    @IBOutlet var searchView:UIView!
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var kb:KeyboardViewController? = nil
    
    var highlightSelectedRow = true
    //let highlightedRowBGColor = UIColor.init(red: 136/255.0, green: 153/255.0, blue: 238/255.0, alpha: 1.0)
    let highlightedRowBGColor = UIColor.init(red: 66/255.0, green: 127/255.0, blue: 237/255.0, alpha: 1.0)
    //let highlightedRowBGColor = UIColor.init(red: 233/255.0, green: 253/255.0, blue: 233/255.0, alpha: 1.0)

    //hex color 427fed
    
    let GREEK = 0
    let LATIN = 1
    var whichLang:Int = 0
    var selectedRow = -1
    var selectedId = -1
    var animatedScroll = false
    
    let infoButton = UIButton.init(type: .infoDark)
    
    @objc func defaultsChanged()
    {
        let defaults = UserDefaults.standard
        let b = defaults.object(forKey: "highlightrow")
        if (b != nil)
        {
            highlightSelectedRow = b as! Bool
        }
        else
        {
            highlightSelectedRow = true
            defaults.set(highlightSelectedRow, forKey: "highlightrow")
            defaults.synchronize()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as?
        //    NSValue)?.cgRectValue.height {
        
            //the above doesn't work on ipad because we change the kb height later
        let keyboardHeight = (kb?.portraitHeight)! //this works
        tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        //}
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        })
    }
    
    //because of table bottom/keyboard code below
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        //decreases width on ipad in landscape and fixes issue of titleview being sized incorrectly
        //when the app is closed and reopened.
        self.splitViewController?.maximumPrimaryColumnWidth = 320
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = ""
        
        //remove navigation bar bottom border
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()

        searchView.layer.borderColor = UIColor.black.cgColor
        searchView.layer.borderWidth = 2.0
        searchView.layer.cornerRadius = 20

        searchTextField?.autocapitalizationType = .none
        searchTextField?.autocorrectionType = .no
        searchTextField?.clearButtonMode = .always
        searchTextField.contentVerticalAlignment = .center
        
        let searchFont = UIFont(name: "HelveticaNeue", size: 20.0)
        if #available(iOS 11.0, *) {
            //dynamic type
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            searchTextField?.font = fontMetrics.scaledFont(for: searchFont!)
            searchTextField?.adjustsFontForContentSizeCategory = true
        }
        else
        {
            searchTextField?.font = searchFont
        }
        
        langButton.backgroundColor = UIColor.clear
        langButton.clipsToBounds = true
        langButton.setTitleColor(UIColor.black, for: .normal)
        langButton.titleLabel?.textAlignment = .right
        langButton.setTitle("Greek:", for: .normal)
        let titleFont = UIFont(name: "Helvetica-Bold", size: 18.0) //abcdef
        if #available(iOS 11.0, *) {
            //dynamic type
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            langButton.titleLabel?.font = fontMetrics.scaledFont(for: titleFont!)
            langButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
        else
        {
            langButton.titleLabel?.font = titleFont
        }
        
        langButton.addTarget(self, action: #selector(toggleLanguage), for: .touchDown)

        //add padding around button label
        //could also set a equal to or greater than height constraint on button and make vertical values smaller.
        langButton.contentEdgeInsets = UIEdgeInsets(top: 13.0, left: 8.0, bottom: 13.0, right: 2.0)
        
        //https://stackoverflow.com/questions/7537858/ios-place-uiview-on-top-of-uitableview-in-fixed-position
        infoButton.addTarget(self, action: #selector(showCredits), for: .touchUpInside)
        self.view.addSubview(infoButton)
        infoButton.tintColor = .black
        var infoButtonFrame = self.infoButton.frame
        var infoButtonPadding:CGFloat = 28.0
        if UIScreen.main.nativeBounds.height == 2436.0 && UIScreen.main.nativeBounds.width == 1125.0
        {
            //extra bottom padding for iPhone X
            infoButtonPadding = 38.0
        }
        infoButtonFrame.origin.x = self.view.bounds.size.width - infoButtonPadding
        infoButtonFrame.origin.y = self.view.bounds.size.height - infoButtonPadding
        self.infoButton.frame = infoButtonFrame;
        self.tableView.bringSubview(toFront: self.infoButton)
        
        let defaults = UserDefaults.standard
        whichLang = defaults.integer(forKey: "lang") //defaults to 0 (Greek), if doesn't exist
        
        defaultsChanged() //check once at start
        
        kb = KeyboardViewController() //kb needs to be member variable, can't be local to just this function
        kb?.appExt = false
        searchTextField?.inputView = kb?.inputView
        searchTextField?.delegate = self
        
        //these 3 lines prevent undo/redo/paste from displaying above keyboard on ipad
        if #available(iOS 9.0, *)
        {
            let item: UITextInputAssistantItem = searchTextField!.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
        
        setLanguage(language: whichLang)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        //move bottom of table up when keyboard shows, so we can access bottom rows and
        //also so selected row is in middle of screen - keyboard height.
        //https://stackoverflow.com/questions/594181/making-a-uitableview-scroll-when-text-field-is-selected/41040630#41040630
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextField?.resignFirstResponder()
    }
    
    @objc func toggleLanguage()
    {
        if whichLang == GREEK
        {
            whichLang = LATIN
        }
        else
        {
            whichLang = GREEK
        }
        searchTextField?.text = ""
        setLanguage(language: whichLang)
    }
    
    func setLanguage(language:Int)
    {
        if language == GREEK
        {
            langButton.setTitle("Greek:", for: .normal)
            title = "Greek"
        }
        else
        {
            langButton.setTitle("Latin:", for: .normal)
            title = "Latin"
        }
        UserDefaults.standard.set(language, forKey: "lang")
        UserDefaults.standard.synchronize()
        
        kb?.setLang(lang: language)
        
        tableView.reloadData()
        
        //scroll to top
        if tableView.numberOfRows(inSection: 0) > 0
        {
            let scrollIndexPath:IndexPath = NSIndexPath(row: 0, section: 0) as IndexPath
            tableView.scrollToRow(at: scrollIndexPath as IndexPath, at: UITableViewScrollPosition.middle, animated: animatedScroll)
        }
    }
    
    @objc func textDidChange(_ notification: Notification) {
        //guard let textView = notification.object as? UITextField else { return }
        //print(textView.text ?? "abc")
        scrollToWord()
    }

    override func viewWillAppear(_ animated: Bool) {
        //clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        /*
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
             
        // If appropriate, configure the new managed object.
        newEvent.timestamp = NSDate()

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
 */
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchTextField?.resignFirstResponder() //works for pad and phone
        if segue.identifier == "showDetail" {
            var wordid = -1
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                if whichLang == GREEK
                {
                    let object = fetchedResultsController.object(at: indexPath)
                    wordid = Int(object.wordid)
                }
                else
                {
                    let object = latinFetchedResultsController.object(at: indexPath)
                    wordid = Int(object.wordid)
                }
                //NSLog("Find word1b: %d", wordid)
                controller.wordid = wordid
                controller.whichLang = whichLang
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        else if segue.identifier == "showCredits"
        {
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.wordid = -1
            controller.whichLang = whichLang
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    /*
     //does nothing--was hoping it would deselect row when touching other row than one currently highlighted.
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animatedScroll)
        }
        return indexPath
    }
    */
    
    @objc func showCredits()
    {
        searchTextField?.resignFirstResponder()
        //detailViewController?.performSegue(withIdentifier: "showDetail", sender: self)
        self.performSegue(withIdentifier: "showCredits", sender: self)

    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        if whichLang == GREEK
        {
            return fetchedResultsController.sections?.count ?? 0
        }
        else
        {
            return latinFetchedResultsController.sections?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionInfo:NSFetchedResultsSectionInfo? = nil
        if whichLang == GREEK
        {
            sectionInfo = fetchedResultsController.sections![section]
        }
        else
        {
            sectionInfo = latinFetchedResultsController.sections![section]
        }
        return sectionInfo!.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if #available(iOS 11.0, *) {
            cell.textLabel?.adjustsFontForContentSizeCategory = true
        }
        
        if whichLang == GREEK
        {
            let event = fetchedResultsController.object(at: indexPath)
            greekConfigureCell(cell, withEvent: event)
        }
        else
        {
            let event = latinFetchedResultsController.object(at: indexPath)
            latinConfigureCell(cell, withEvent: event)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
/*
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
 */
        }
    }
    
    func removeMacronsBreves(string:String) -> String
    {
        var temp = string.replacingOccurrences(of: "ā", with: "a")
        temp = temp.replacingOccurrences(of: "ă", with: "a")
        temp = temp.replacingOccurrences(of: "ē", with: "e")
        temp = temp.replacingOccurrences(of: "ĕ", with: "e")
        temp = temp.replacingOccurrences(of: "ī", with: "i")
        temp = temp.replacingOccurrences(of: "ĭ", with: "i")
        temp = temp.replacingOccurrences(of: "ō", with: "o")
        temp = temp.replacingOccurrences(of: "ŏ", with: "o")
        temp = temp.replacingOccurrences(of: "ū", with: "u")
        temp = temp.replacingOccurrences(of: "ŭ", with: "u")
        temp = temp.replacingOccurrences(of: "ȳ", with: "y")
        
        temp = temp.replacingOccurrences(of: "Ă", with: "A")
        temp = temp.replacingOccurrences(of: "Ā", with: "A")
        temp = temp.replacingOccurrences(of: "Ĕ", with: "E")
        temp = temp.replacingOccurrences(of: "Ē", with: "E")
        temp = temp.replacingOccurrences(of: "Ī", with: "I")
        temp = temp.replacingOccurrences(of: "Ĭ", with: "I")
        temp = temp.replacingOccurrences(of: "Ŏ", with: "O")
        temp = temp.replacingOccurrences(of: "Ō", with: "O")
        temp = temp.replacingOccurrences(of: "Ŭ", with: "U")
        temp = temp.replacingOccurrences(of: "Ū", with: "U")
        
        return temp
    }

    func greekConfigureCell(_ cell: UITableViewCell, withEvent gw: GreekWords) {
        //cell.textLabel!.text = event.timestamp!.description
        cell.textLabel!.text = gw.word!.description
        let greekFont = UIFont(name: "NewAthenaUnicode", size: 24.0)
        if #available(iOS 11.0, *) {
            //dynamic type
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            cell.textLabel?.font = fontMetrics.scaledFont(for: greekFont!)
            //cell.textLabel?.adjustsFontForContentSizeCategory = true
        }
        else
        {
            cell.textLabel?.font = greekFont
        }
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = highlightedRowBGColor
        cell.selectedBackgroundView = bgColorView
    }
    
    func latinConfigureCell(_ cell: UITableViewCell, withEvent gw: LatinWords) {
        //cell.textLabel!.text = event.timestamp!.description
        cell.textLabel!.text = removeMacronsBreves(string: gw.word!.description)
        let latinFont = UIFont(name: "Helvetica-Light", size: 22.0)
        if #available(iOS 11.0, *) {
            //dynamic type
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            cell.textLabel?.font = fontMetrics.scaledFont(for: latinFont!)
            //cell.textLabel?.adjustsFontForContentSizeCategory = true
        }
        else
        {
            cell.textLabel?.font = latinFont
        }
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = highlightedRowBGColor
        cell.selectedBackgroundView = bgColorView
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<GreekWords> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<GreekWords> = GreekWords.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "seq", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<GreekWords>? = nil
    
    var latinFetchedResultsController: NSFetchedResultsController<LatinWords> {
        if _latinFetchedResultsController != nil {
            return _latinFetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<LatinWords> = LatinWords.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "seq", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "LatinMaster")
        aFetchedResultsController.delegate = self
        _latinFetchedResultsController = aFetchedResultsController
        
        do {
            try _latinFetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _latinFetchedResultsController!
    }
    var _latinFetchedResultsController: NSFetchedResultsController<LatinWords>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                greekConfigureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! GreekWords)
            case .move:
                greekConfigureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! GreekWords)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func scrollToWord()
    {
        let rowCount = tableView.numberOfRows(inSection: 0)
    
        //There are zero rows
        if rowCount < 1
        {
            return;
        }
    
        let searchText = searchTextField?.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        var vc:NSManagedObjectContext
        if #available(iOS 10.0, *) {
            vc = delegate.persistentContainer.viewContext
        } else {
            vc = delegate.managedObjectContext
        }
        
        var seq = -1
        
        if whichLang == GREEK
        {
            let request: NSFetchRequest<GreekWords> = GreekWords.fetchRequest()
            if #available(iOS 10.0, *) {
                request.entity = GreekWords.entity()
            } else {
                request.entity = NSEntityDescription.entity(forEntityName: "GreekWords", in: delegate.managedObjectContext)
            }
            
            let pred = NSPredicate(format: "(unaccentedWord >= %@)", searchText!)
            request.predicate = pred
            
            let sortDescriptor = NSSortDescriptor(key: "unaccentedWord", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            request.fetchLimit = 1
            var results: [GreekWords]? = nil
            do {
                results =
                    try vc.fetch(request as!
                        NSFetchRequest<NSFetchRequestResult>) as? [GreekWords]
                
            } catch let error {
                // Handle error
                NSLog("Error: %@", error.localizedDescription)
                return
            }
            
            if results != nil && results!.count > 0
            {
                //let match = results?[0]
                seq = Int((results?[0].seq)!)
            }
            else
            {
                selectedRow = -1
                selectedId = -1
                NSLog("Error: Word not found by id.");
            }
        }
        else
        {
            let request: NSFetchRequest<LatinWords> = LatinWords.fetchRequest()
            if #available(iOS 10.0, *) {
                request.entity = LatinWords.entity()
            } else {
                request.entity = NSEntityDescription.entity(forEntityName: "LatinWords", in: delegate.managedObjectContext)
            }
            
            let pred = NSPredicate(format: "(unaccentedWord >= %@)", searchText!)
            request.predicate = pred
            
            let sortDescriptor = NSSortDescriptor(key: "unaccentedWord", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            request.fetchLimit = 1
            var results: [LatinWords]? = nil
            do {
                results =
                    try vc.fetch(request as!
                        NSFetchRequest<NSFetchRequestResult>) as? [LatinWords]
                
            } catch let error {
                // Handle error
                NSLog("Error: %@", error.localizedDescription)
                return
            }
            
            if results != nil && results!.count > 0
            {
                seq = Int((results?[0].seq)!)
            }
            else
            {
                selectedRow = -1
                selectedId = -1
                NSLog("Error: Word not found by id.");
            }
        }

        if seq < 1 || seq > rowCount
        {
            //NSLog("Scroll out of bounds: %d", seq);
            seq = rowCount;
        }
        
        let scrollIndexPath = NSIndexPath(row: (seq - 1), section: 0) as IndexPath
        //NSLog("scroll to: \(highlightSelectedRow)")
        if highlightSelectedRow
        {
            if seq == 1
            {
                tableView.scrollToRow(at: scrollIndexPath, at: UITableViewScrollPosition.middle, animated: animatedScroll)
                if let indexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: indexPath, animated: animatedScroll)
                }
            }
            else
            {
                tableView.selectRow(at: scrollIndexPath, animated: animatedScroll, scrollPosition: UITableViewScrollPosition.middle)
            }
        }
        else
        {
            tableView.scrollToRow(at: scrollIndexPath, at: UITableViewScrollPosition.middle, animated: animatedScroll)
        }
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}


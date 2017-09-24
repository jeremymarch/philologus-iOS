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

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate,UITextFieldDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var kb:KeyboardViewController? = nil
    
    let GREEK = 0
    let LATIN = 1
    var whichLang:Int = 0
    
    var searchTextField:UITextField?
    let langButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 38))// [UIButton
    
    var selectedRow = -1
    var selectedId = -1
    var animatedScroll = false
    
    var tc:NSLayoutConstraint?
    var lc:NSLayoutConstraint?
    var rc:NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //to hide title
        let label = UILabel.init()
        self.navigationItem.titleView = label;
        
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = ""
        
        //remove navigation bar bottom border
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        
        let defaults = UserDefaults.standard
        let a = defaults.object(forKey: "lang")
        if (a != nil)
        {
            whichLang = a as! Int
        }
        else
        {
            whichLang = 0
            defaults.set(whichLang, forKey: "lang")
            defaults.synchronize()
        }
        
        tableView.separatorStyle = .none

        searchTextField = UITextField(frame: CGRect(x: navigationController!.navigationBar.bounds.origin.x, y: navigationController!.navigationBar.bounds.origin.y, width: navigationController!.navigationBar.bounds.size.width, height: 38))
        
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
        
        searchTextField?.layer.borderColor = UIColor.black.cgColor
        searchTextField?.layer.borderWidth = 2.0
        searchTextField?.layer.cornerRadius = 15.5
        searchTextField?.delegate = self
        searchTextField?.autocapitalizationType = .none
        searchTextField?.autocorrectionType = .no
        searchTextField?.clearButtonMode = .always
        searchTextField?.autoresizingMask = [.flexibleWidth]
    
        //self.navigationItem.titleView?.addSubview(searchTextField!)
        //self.navigationController?.navigationBar.addSubview(searchTextField!)
        
        self.navigationItem.titleView = searchTextField!
        searchTextField?.frame = CGRect(x: navigationController!.navigationBar.bounds.origin.x, y: navigationController!.navigationBar.bounds.origin.y, width: navigationController!.navigationBar.bounds.size.width, height: 38)
        //self.navigationItem.titleView.
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        //self.navigationItem.titleView?.autoresizingMask = [.flexibleWidth]
        
        //let screenSize = UIScreen.main.bounds
        //let screenWidth = screenSize.width
        //let screenHeight = screenSize.height
        
        /*
         UIView* ctrl = [[UIView alloc] initWithFrame:navController.navigationBar.bounds];
         ctrl.backgroundColor = [UIColor yellowColor];
         ctrl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
         [navController.navigationBar addSubview:ctrl];
 */
        
        //searchTextField?.frame = CGRect(x: 0, y: 0, width: (self.navigationItem.titleView?.frame.size.width)!, height: 38)

        //searchTextField.frame = CGRect(x: 0, y: 0, width: navFrame.width*3, height: 38)

        
//        let myView = UIView(frame: CGRect(x: 0, y: 0, width: navFrame.width*3, height: navFrame.height))

        //NSLog("nb width: %f, %f, %f", (self.navigationController?.navigationBar.frame.size.width)!, screenWidth,tableView.frame.size.width)
        
        searchTextField?.autoresizingMask = [.flexibleWidth]
        searchTextField?.translatesAutoresizingMaskIntoConstraints = true
        //searchTextField?.contentMode = .redraw

        /*
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        tc = searchTextField.topAnchor.constraint(equalTo: (searchTextField.superview!.topAnchor))
        lc = searchTextField.leftAnchor.constraint(equalTo: (searchTextField.superview!.leftAnchor))
        rc = searchTextField.rightAnchor.constraint(equalTo: (searchTextField.superview!.rightAnchor))
        tc?.isActive = true
        lc?.isActive = true
        rc?.isActive = true
        searchTextField.heightAnchor.constraint(equalToConstant: 34.0).isActive = true
        */
        
        //let langButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 34))// [UIButton buttonWithType:UIButtonTypeCustom];
        langButton.backgroundColor = UIColor.clear
        langButton.layer.cornerRadius = 10
        langButton
            .clipsToBounds = true
        langButton.setTitleColor(UIColor.black, for: .normal)
        langButton.setTitle("Greek:", for: .normal)
        langButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 16.0)
        
        langButton.addTarget(self, action: #selector(toggleLanguage), for: .touchDown)
        
        searchTextField?.leftView = langButton
        searchTextField?.leftViewMode = UITextFieldViewMode.always
        
        
        let infoButton = UIButton.init(type: .infoDark)
        infoButton.addTarget(self, action: #selector(showCredits), for: .touchUpInside)
        searchTextField?.rightView = infoButton
        searchTextField!.rightViewMode = .unlessEditing
        
        searchTextField?.rightView?.frame = CGRect(x: 0, y: 0, width: 35, height: 30)
        //align lang button title for ios7.  Gives it some left padding
        //we also adjust the size in setLang
        langButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0)
        
        setLanguage(language: whichLang)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        //NSLog("here3")
        //NSLog("Available fonts: %s", UIFont.familyNames);
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        NSLog("rotate")
        coordinator.animate(alongsideTransition: { _ in
            
            if self.view.frame.size.width != 0 && self.view.frame.size.height != 0
            {
                let navBar = self.navigationController!.navigationBar
                self.searchTextField?.frame = CGRect(x: navBar.bounds.origin.x, y: navBar.bounds.origin.y, width: navBar.bounds.size.width, height: 38)
            }
            
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //searchTextField?.isHidden = true
        /*
        searchTextField.isHidden = true
        tc?.isActive = false
        lc?.isActive = false
        rc?.isActive = false
 */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        tc?.isActive = true
        lc?.isActive = true
        rc?.isActive = true
        searchTextField?.isHidden = false
 */
        
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
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
        kb?.setLang(lang: language)
        tableView.reloadData()
        
        //scroll to top
        if tableView.numberOfRows(inSection: 0) > 0
        {
            let scrollIndexPath:IndexPath = NSIndexPath(row: 0, section: 0) as IndexPath
            tableView.scrollToRow(at: scrollIndexPath as IndexPath, at: UITableViewScrollPosition.middle, animated: animatedScroll)
        }
        
        /*
    UIButton *b = self.langButton;
    b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    b.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    b.titleLabel.textAlignment = UITextAlignmentLeft;
    
    int ios7Adjustment = 0;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
    ios7Adjustment = 2;
    }
    
    
    if ( language == LATIN )
    {
    self->lang = LATIN;
    self.wordTable = @"LatinWords";
    self.defTable = @"LatinDefs";
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    [self.keyboard setButtons:LATIN];
    
    if (self->mode == TAGS)
    {
    [b setFrame:CGRectMake(b.frame.origin.x, b.frame.origin.y, 120.0, 34.0)];
    [b setTitle:@"L&S > Tag:" forState:UIControlStateNormal];
    }
    else if (self->mode == HISTORY)
    {
    [b setFrame:CGRectMake(b.frame.origin.x, b.frame.origin.y, 120.0, 34.0)];
    [b setTitle:@"L&S > History:" forState:UIControlStateNormal];
    }
    else
    {
    [b setFrame:CGRectMake(b.frame.origin.x, b.frame.origin.y, 53.0 + ios7Adjustment, 34.0)];
    [b setTitle:@"Latin:" forState:UIControlStateNormal];
    }
    self.title = @"Latin";
    self.navigationItem.backBarButtonItem.title = @"Latin";
    }
    else
    {
    self->lang = GREEK;
    self.wordTable = @"GreekWords";
    self.defTable = @"GreekDefs";
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    [self.keyboard setButtons:GREEK];
    
    if (self->mode == TAGS)
    {
    [b setFrame:CGRectMake(b.frame.origin.x, b.frame.origin.y, 120.0, 34.0)];
    [b setTitle:@"LSJ > Tag:" forState:UIControlStateNormal];
    }
    else if (self->mode == HISTORY)
    {
    [b setFrame:CGRectMake(b.frame.origin.x, b.frame.origin.y, 120.0, 34.0)];
    [b setTitle:@"LSJ > History:" forState:UIControlStateNormal];
    }
    else
    {
    [b setFrame:CGRectMake(b.frame.origin.x, b.frame.origin.y, 60.0+ ios7Adjustment, 34.0)];
    [b setTitle:@"Greek:" forState:UIControlStateNormal];
    }
    self.title = @"Greek";
    self.navigationItem.backBarButtonItem.title = @"Greek";
    }
        */
    }
    
    @objc func textDidChange(_ notification: Notification) {
        //guard let textView = notification.object as? UITextField else { return }
        //print(textView.text ?? "abc")
        scrollToWord()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        //searchTextField?.isHidden = false
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTextField?.resignFirstResponder()
    }
    
    @objc func showCredits()
    {
        searchTextField?.resignFirstResponder()
        //detailViewController?.performSegue(withIdentifier: "showDetail", sender: self)
        self.performSegue(withIdentifier: "showCredits", sender: self)

    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        if whichLang == GREEK
        {
            return fetchedResultsController.sections?.count ?? 0
        }
        else
        {
            return latinFetchedResultsController.sections?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        cell.textLabel?.font = greekFont
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(red: 136/255.0, green: 153/255.0, blue: 238/255.0, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
    }
    
    func latinConfigureCell(_ cell: UITableViewCell, withEvent gw: LatinWords) {
        //cell.textLabel!.text = event.timestamp!.description
        cell.textLabel!.text = removeMacronsBreves(string: gw.word!.description)
        let greekFont = UIFont(name: "Helvetica-Light", size: 22.0)
        cell.textLabel?.font = greekFont
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.init(red: 136/255.0, green: 153/255.0, blue: 238/255.0, alpha: 1.0)
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
            NSLog("Scroll out of bounds: %d", seq);
            seq = rowCount;
        }
        
        let scrollIndexPath:IndexPath = NSIndexPath(row: (seq - 1), section: 0) as IndexPath
        tableView.scrollToRow(at: scrollIndexPath as IndexPath, at: UITableViewScrollPosition.middle, animated: animatedScroll)
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}


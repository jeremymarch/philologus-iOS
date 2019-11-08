//
//  DetailViewController.swift
//  philolog.us
//
//  Created by Jeremy March on 5/21/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import UIKit
import WebKit
import CoreData

class DetailViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    //https://www.hackingwithswift.com/example-code/wkwebview/whats-the-difference-between-uiwebview-and-wkwebview
    //https://www.hackingwithswift.com/articles/112/the-ultimate-guide-to-wkwebview
    
    //https://stackoverflow.com/questions/50537421/wkwebview-in-ios-app-takes-a-long-time-to-load
    static let webView = WKWebView()
    
    let suggestionCharLimit = 1024
    var wordid = -1
    var word:String?
    var whichLang = 0
    var fontSize = 14
    let allowReportButton = false
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var xwebView: UIWebView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    var reportNavButton:UIBarButtonItem?

    override func loadView() {
        self.view = DetailViewController.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DetailViewController.webView.contentScaleFactor = 2.0
        /*
        textViewHeight.constant = 0.0
        textView.delegate = self
        textView.layer.borderColor = UIColor.black.cgColor
        textView.text = ""
        */
        navigationController?.setNavigationBarHidden(false, animated: true)
        //to hide title
        let label = UILabel.init()
        self.navigationItem.titleView = label
        
        //self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = ""
        
        DetailViewController.webView.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            DetailViewController.webView.scrollView.delegate = self
        }
        
         //button to report mistakes, make suggestions
         //commented out for now
         //just need to add UITextView to get user comment
        reportNavButton = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(showreportIssue))
        navigationItem.rightBarButtonItem = nil
    }

    @objc func showreportIssue() {
        
        if textViewHeight.constant == 200.0
        {
            textViewHeight.constant = 0.0
            textView.resignFirstResponder()
            reportNavButton?.title = "Report"
        }
        else
        {
            textViewHeight.constant = 200.0
            textView.becomeFirstResponder()
            reportNavButton?.title = "Cancel"
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= suggestionCharLimit
    }
    
    @IBAction func reportIssue() {
        
        //realReportIssue()
        showreportIssue()
        textView.text = ""
    }
    
    func realReportIssue() { }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navController = self.splitViewController?.viewControllers[0]
        {
            if let navC = navController as? UINavigationController
            {
                //this will not always be the master (e.g. when multitasking on iPad), so we must check
                if let mvc = navC.topViewController as? MasterViewController
                {
                    mvc.searchTextField?.resignFirstResponder()
                }
            }
        }
    }

    @objc func showCredits()
    {
        //searchTextField?.resignFirstResponder()
        loadCredits()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Int? {
        didSet {
            self.navigationItem.title = ""
        }
    }
    
    /*
     override func viewDidAppear(_ animated: Bool) {
     
     }
     */
    
    func setFontSize()
    {
        if #available(iOS 11.0, *) {
            if self.traitCollection.preferredContentSizeCategory == .extraSmall
            {
                fontSize = 13
                print("extrasmall")
            }
            else if self.traitCollection.preferredContentSizeCategory == .small
            {
                fontSize = 14
                print("small")
            }
            else if self.traitCollection.preferredContentSizeCategory == .medium
            {
                fontSize = 15
                print("medium")
            }
            else if self.traitCollection.preferredContentSizeCategory == .large
            {
                fontSize = 16
                print("large")
            }
            else if self.traitCollection.preferredContentSizeCategory == .extraLarge
            {
                fontSize = 17
                print("extralarge")
            }
            else if self.traitCollection.preferredContentSizeCategory == .extraExtraLarge
            {
                fontSize = 19
                print("extraextralarge")
            }
            else if self.traitCollection.preferredContentSizeCategory == .extraExtraExtraLarge
            {
                fontSize = 22
                print("extraextraextralarge")
            }
            else if self.traitCollection.preferredContentSizeCategory == .accessibilityMedium
            {
                fontSize = 24
                print("accessibilityMedium")
            }
            else if self.traitCollection.preferredContentSizeCategory == .accessibilityLarge
            {
                fontSize = 26
                print("accessibilityLarge")
            }
            else if self.traitCollection.preferredContentSizeCategory == .accessibilityExtraLarge
            {
                fontSize = 30
                print("accessibilityExtraLarge")
            }
            else if self.traitCollection.preferredContentSizeCategory == .accessibilityExtraExtraLarge
            {
                fontSize = 36
                print("accessibilityExtraExtraLarge")
            }
            else if self.traitCollection.preferredContentSizeCategory == .accessibilityExtraExtraExtraLarge
            {
                fontSize = 44
                print("accessibilityExtraExtraExtraLarge")
            }
            else
            {
                fontSize = 14
                print("no dynamic font setting??")
            }
        }
    }
    
    @objc func textSizeChanged(_ notification: Notification) {
        //guard let textView = notification.object as? UITextField else { return }
        //print(textView.text ?? "abc")
        setFontSize()
        if wordid > 0
        {
            loadDef()
        }
        else
        {
            loadCredits()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = ""
        NotificationCenter.default.addObserver(self, selector: #selector(textSizeChanged), name: UIContentSizeCategory.didChangeNotification, object: nil)
        /*
        let infoButton = UIButton.init(type: .infoDark)
        infoButton.addTarget(self, action: #selector(showCredits), for: .touchUpInside)
        let buttonItem = UIBarButtonItem.init(customView: infoButton)
        navigationItem.rightBarButtonItem = buttonItem
         */
        setFontSize()
        if wordid > 0
        {
            loadDef()
        }
        else
        {
            loadCredits()
        }
    }
    
    func loadCredits()
    {
        //self.navigationController?.navigationItem.rightBarButtonItems = [button1]
        navigationItem.rightBarButtonItem = nil
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            var realVersion = ""
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            {
                //NSLog("Version: \(version)")
                realVersion = "<br><div>Version: " + version + "</div>"
            }
            
            let iPadCredits = String(format:"<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no shrink-to-fit=no'/></head><body style='font-family:helvetica;text-align:center;margin-top:40px;font-size:20pt;'><div style='font-size:34pt;font-weight:bold;'>philolog.us</div><div style='font-size:14pt;margin-top:20px;'>Digitized texts of</div><div style='margin-top:16px;'><b>Liddell, Scott, and Jones'<br> <i>A Greek-English Lexicon</i></b></div><div style='font-size:12pt;margin-top:10px;'>and</div><div style='margin-top:10px;'><b>Lewis and Short's<br><i>A Latin Dictionary</i></b></div><div style='font-size:12pt;margin-top:16px;'>courtesy of the</div><div style='margin-top:16px;'>Perseus Digital Library</div><div style='color:blue;'>http://www.perseus.tufts.edu</div><br/><div style='font-size:14pt;'>Visit philolog.us on the web at<br><span style='color:blue;'>https://philolog.us</span></div>%@</body></html>", realVersion)
            
            if true //let w = webView
            {
                DetailViewController.webView.loadHTMLString(iPadCredits, baseURL: Bundle.main.resourceURL)
            }
        }
        else
        {
            var realVersion = ""
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            {
                //NSLog("Version: \(version)")
                realVersion = "<br><div>Version: " + version + "</div>"
            }
            
            let iPhoneCredits = String(format:"<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no shrink-to-fit=no'/></head><body style='font-family:helvetica;text-align:center;margin-top:0px;font-size:14pt;'><div style='font-size:24pt;font-weight:bold;'>philolog.us</div><div style='font-size:12pt;margin-top:8px;'>Digitized texts of</div><div style='margin-top:16px;'><b>Liddell, Scott, and Jones'<br> <i>A Greek-English Lexicon</i></b></div><div style='font-size:12pt;margin-top:8px;'>and</div><div style='margin-top:8px;'><b>Lewis and Short's<br><i>A Latin Dictionary</i></b></div><div style='font-size:12pt;margin-top:10px;'>courtesy of the</div><div style='margin-top:10px;'>Perseus Digital Library</div><div style='color:blue;'>http://www.perseus.tufts.edu</div><br/><div>Visit philolog.us on the web at<br><span style='color:blue;'>https://philolog.us</span></div>%@</body></html>", realVersion);
            
            if true //let w = webView
            {
                DetailViewController.webView.loadHTMLString(iPhoneCredits, baseURL: Bundle.main.resourceURL)
            }
        }
    }
    
    func loadDef()
    {
        if wordid < -1
        {
            return
        }
        
        //self.navigationController?.navigationItem.rightBarButtonItems = [button1]
        if navigationItem.rightBarButtonItem == nil && allowReportButton
        {
            navigationItem.rightBarButtonItem = reportNavButton
        }
        let styles:[String] = ["color:black;","color:red;","color:blue;","color:green;","color:orange;","color:purple;","font-weight:bold;","font-style:italic;"]

        var authorStyle = styles[0]
        var titleStyle = styles[0]
        var bibscopeStyle = styles[0]
        var foreignStyle = styles[0]
        var quoteStyle = styles[0]
        var translationStyle = styles[0]
        let js = ""
 
        let enabled = UserDefaults.standard.object(forKey: "enableCustomColors") as? Bool
        if enabled == nil || enabled! == false
        {
            authorStyle = styles[1]
            titleStyle = styles[4]
            bibscopeStyle = styles[3]
            foreignStyle = styles[2]
            quoteStyle = styles[2]
            translationStyle = styles[6]
        }
        else
        {
            if let a = UserDefaults.standard.object(forKey: "authorStyle") as! Int?
            {
                authorStyle = styles[a]
            }
            if let titl = UserDefaults.standard.object(forKey: "titleStyle") as! Int?
            {
                titleStyle = styles[titl]
            }
            if let bib = UserDefaults.standard.object(forKey: "bibScopeStyle") as! Int?
            {
                bibscopeStyle = styles[bib]
            }
            if let foreign = UserDefaults.standard.object(forKey: "foreignStyle") as! Int?
            {
                foreignStyle = styles[foreign]
            }
            if let quote = UserDefaults.standard.object(forKey: "quoteStyle") as! Int?
            {
                quoteStyle = styles[quote]
            }
            translationStyle = styles[6]
        }

        let h = "<HTML><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no shrink-to-fit=no'/>%@<style>" +
            ".l1 { margin-left: 18px;position:relative;text-indent:-18px; } " +
            ".l2 { margin-left: 18px;position:relative;text-indent:-18px; } " +
            ".l3 { margin-left: 18px;position:relative;text-indent:-18px; } " +
            ".l4 { margin-left: 18px;position:relative;text-indent:-18px; } " +
            ".l5 { margin-left: 18px;position:relative;text-indent:-18px; } " +
            ".body {line-height:1.2;margin:8px 0px} " +
            ".fo {%@} " +
            ".qu {%@} " +
            ".qu:before { content: '\"'; } " +
            ".qu:after { content: '\"'; }  " +
            ".tr {%@} " +
            ".au {%@} " +
            ".bi {%@} " +
            ".ti {%@} " +
            ".label {font-weight:bold;padding-right:0px;text-indent:0px;} " +
            ".label:after { content: ' '; } " +
            ".orth {font-weight:bold; } " +
            "@font-face {font-family: 'NewAthenaUnicode';src: url('newathu5.ttf') format('truetype');} " +
        "</style></head><BODY style='font-size:%dpt;font-family:\"NewAthenaUnicode\";margin:0px 10px;'>"
        
        let header = String(format: h, js, foreignStyle, quoteStyle, translationStyle, authorStyle, bibscopeStyle, titleStyle, fontSize);
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        var vc:NSManagedObjectContext
        if #available(iOS 10.0, *) {
            vc = delegate.persistentContainer.viewContext
        } else {
            vc = delegate.managedObjectContext
        }
        
        if whichLang == 0
        {
            let request: NSFetchRequest<GreekDefs> = GreekDefs.fetchRequest()
            if #available(iOS 10.0, *) {
                request.entity = GreekDefs.entity()
            } else {
                request.entity = NSEntityDescription.entity(forEntityName: "GreekDefs", in: delegate.managedObjectContext)
            }
            
            let pred = NSPredicate(format: "(wordid = %d)", self.wordid)
            request.predicate = pred
            var results: [GreekDefs]? = nil
            do {
                results =
                    try vc.fetch(request as!
                        NSFetchRequest<NSFetchRequestResult>) as? [GreekDefs]
                
            } catch let error {
                // Handle error
                NSLog("Error: %@", error.localizedDescription)
                return
            }
            
            if results != nil && results!.count > 0
            {
                let match = results?[0]
                let def2:String = match!.def!
                //NSLog("res: %@", def2)
                
                if true //let w = webView
                {
                    //label.text = detail.timestamp!.description
                    let html = header + def2 + "</BODY></HTML>"
                    DetailViewController.webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
                    //NSLog("html: \(html)")
                }
            }
            else
            {
                if true //let w = webView
                {
                    //label.text = detail.timestamp!.description
                    DetailViewController.webView.loadHTMLString("<html><body>Could not find Greek word \(self.wordid).</body></html>", baseURL: Bundle.main.resourceURL)
                }
            }
        }
        else
        {
            let request: NSFetchRequest<LatinDefs> = LatinDefs.fetchRequest()
            if #available(iOS 10.0, *) {
                request.entity = LatinDefs.entity()
            } else {
                request.entity = NSEntityDescription.entity(forEntityName: "LatinDefs", in: delegate.managedObjectContext)
            }
            //NSLog("Find ID: %d", self.wordid)
            let pred = NSPredicate(format: "(wordid = %d)", self.wordid)
            request.predicate = pred
            var results: [LatinDefs]? = nil
            do {
                results =
                    try vc.fetch(request as!
                        NSFetchRequest<NSFetchRequestResult>) as? [LatinDefs]
                
            } catch let error {
                // Handle error
                NSLog("Error: %@", error.localizedDescription)
                return
            }
            
            if results != nil && results!.count > 0
            {
                let match = results?[0]
                let def2:String = match!.def!
                //NSLog("res: %@", header + def2)
                
                if true //let w = webView
                {
                    //label.text = detail.timestamp!.description
                    DetailViewController.webView.loadHTMLString(header + def2 + "</BODY></HTML>", baseURL: Bundle.main.resourceURL)
                }
            }
            else
            {
                if true //let w = webView
                {
                    //label.text = detail.timestamp!.description
                    DetailViewController.webView.loadHTMLString("<html><body>Could not find Latin word \(self.wordid).</body></html>", baseURL: Bundle.main.resourceURL)
                }
            }
        }
    }
}


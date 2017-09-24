//
//  DetailViewController.swift
//  philolog.us
//
//  Created by Jeremy March on 5/21/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    var wordid = -1
    var word:String?
    var whichLang = 0
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //to hide title
        let label = UILabel.init()
        self.navigationItem.titleView = label;
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = ""
        
        //configureView()
        self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Int? {
        didSet {
            self.navigationItem.title = ""
            // Update the view.
            //configureView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = ""
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
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            let iPadCredits = "<html><body style='font-family:helvetica;text-align:center;margin-top:40px;font-size:20pt;'><div style='font-size:34pt;font-weight:bold;'>philolog.us</div><div style='font-size:14pt;margin-top:20px;'>Digitized texts of</div><div style='margin-top:16px;'><b>Liddell, Scott, and Jones'<br> <i>A Greek-English Lexicon</i></b></div><div style='font-size:12pt;margin-top:10px;'>and</div><div style='margin-top:10px;'><b>Lewis and Short's<br><i>A Latin Dictionary</i></b></div><div style='font-size:12pt;margin-top:16px;'>courtesy of the</div><div style='margin-top:16px;'>Perseus Digital Library</div><div style='color:blue;'>http://www.perseus.tufts.edu</div><br/><div style='font-size:14pt;'>Visit philolog.us on the web at<br><span style='color:blue;'>http://philolog.us</span></div></body></html>"
            
            if let w = webView
            {
                w.loadHTMLString(iPadCredits, baseURL: nil)
            }
        }
        else
        {
            let iPhoneCredits = "<html><body style='font-family:helvetica;text-align:center;margin-top:0px;font-size:14pt;'><div style='font-size:24pt;font-weight:bold;'>philolog.us</div><div style='font-size:12pt;margin-top:8px;'>Digitized texts of</div><div style='margin-top:16px;'><b>Liddell, Scott, and Jones'<br> <i>A Greek-English Lexicon</i></b></div><div style='font-size:12pt;margin-top:8px;'>and</div><div style='margin-top:8px;'><b>Lewis and Short's<br><i>A Latin Dictionary</i></b></div><div style='font-size:12pt;margin-top:10px;'>courtesy of the</div><div style='margin-top:10px;'>Perseus Digital Library</div><div style='color:blue;'>http://www.perseus.tufts.edu</div><br/><div>Visit philolog.us on the web at<br><span style='color:blue;'>http://philolog.us</span></div></body></html>";
            
            if let w = webView
            {
                w.loadHTMLString(iPhoneCredits, baseURL: nil)
            }
        }
    }
    
    func loadDef()
    {
        if wordid < -1
        {
            return
        }
        
        let styles:[String] = ["color:black;","color:red;","color:blue;","color:green;","color:orange;","color:purple;","font-weight:bold;","font-style:italic;"]
        
        let enabled = UserDefaults.standard.object(forKey: "enableCustomColors") as? Bool

        var authorStyle = ""
        var titleStyle = ""
        var bibscopeStyle = ""
        var foreignStyle = ""
        var quoteStyle = ""
        var translationStyle = ""
        let js = ""
        if enabled == nil || !enabled!
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
            let a = UserDefaults.standard.object(forKey: "authorStyle") as! Int
            let titl = UserDefaults.standard.object(forKey: "titleStyle") as! Int
            let bib = UserDefaults.standard.object(forKey: "bibScopeStyle") as! Int
            let foreign = UserDefaults.standard.object(forKey: "foreignStyle") as! Int
            let quote = UserDefaults.standard.object(forKey: "quoteStyle") as! Int
            authorStyle = styles[a]
            titleStyle = styles[titl]
            bibscopeStyle = styles[bib]
            foreignStyle = styles[foreign]
            quoteStyle = styles[quote]
            translationStyle = styles[6]
        }
        
        let h = "<HTML><head>%@<style>" +
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
            "</style></head><BODY style='font-size:14pt;font-family:\"New Athena Unicode\";margin:0px 10px;'>"
        
        let header = String(format: h, js, foreignStyle, quoteStyle, translationStyle, authorStyle, bibscopeStyle, titleStyle);
        
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
                
                if let w = webView
                {
                    //label.text = detail.timestamp!.description
                    let html = header + def2 + "</BODY></HTML>"
                    w.loadHTMLString(html, baseURL: nil)
                    //NSLog("html: \(html)")
                }
            }
            else
            {
                if let w = webView {
                    //label.text = detail.timestamp!.description
                    w.loadHTMLString("<html><body>Could not find Greek word \(self.wordid).</body></html>", baseURL: nil)
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
                //NSLog("res: %@", def2)
                
                if let w = webView
                {
                    //label.text = detail.timestamp!.description
                    w.loadHTMLString(header + def2 + "</BODY></HTML>", baseURL: nil)
                }
            }
            else
            {
                if let w = webView {
                    //label.text = detail.timestamp!.description
                    w.loadHTMLString("<html><body>Could not find Latin word \(self.wordid).</body></html>", baseURL: nil)
                }
            }
        }
    }
}


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


    func configureView() {
        // Update the user interface for the detail item.

            if let w = webView {
                //label.text = detail.timestamp!.description
                w.loadHTMLString("<html><body><i>Testing</i></body></html>", baseURL: nil)
            }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureView()
        self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {

    //NSLog(@"wordid=%d", self.wordid);
        if wordid > 0
        {
            loadDef()
        }
        else
        {
         //   loadCredits()
        }
    }
    
    func loadDef()
    {
        if wordid < -1
        {
            return
        }
        
        let styles:[String] = ["color:black;","color:red;","color:blue;","color:green;","color:orange;","color:purple;","font-weight:bold;","font-style:italic;"]
        
        //NSLog(@"Custom Colors Enabled?: %d", enabled);
        var enabled = false
        var authorStyle = ""
        var titleStyle = ""
        var bibscopeStyle = ""
        var foreignStyle = ""
        var quoteStyle = ""
        var translationStyle = ""
        var js = ""
        if (!enabled)
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
            //UserDefaults.integer("authorStyel")
            
            let authorStyle = UserDefaults.standard.object(forKey: "authorStyle") as? [Int]
            let titleStyle = UserDefaults.standard.object(forKey: "titleStyle") as? [Int]
            let bibscopeStyle = UserDefaults.standard.object(forKey: "bibScopeStyle") as? [Int]
            let foreignStyle = UserDefaults.standard.object(forKey: "foreignStyle") as? [Int]
            let quoteStyle = UserDefaults.standard.object(forKey: "quoteStyle") as? [Int]
            let translationStyle = 6
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
            "</style></head><BODY style='font-size:14pt;font-family:NewAthenaUnicode;margin:0px 10px;'>"
        
        let header = String(format: h, js, foreignStyle, quoteStyle, translationStyle, authorStyle, bibscopeStyle, titleStyle);
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let vc = delegate.persistentContainer.viewContext
        
        if whichLang == 0
        {
            let request: NSFetchRequest<GreekDefs> = GreekDefs.fetchRequest()
            request.entity = GreekDefs.entity()
            
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
            
            if results != nil
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
        }
        else
        {
            let request: NSFetchRequest<LatinDefs> = LatinDefs.fetchRequest()
            request.entity = LatinDefs.entity()
            
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
            
            if results != nil
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
        }
    }
}


//
//  SecondViewController.swift
//  ale-lbs
//
//  Created by Dirk Evrard on 19/03/18.
//  Copyright © 2018 Dirk Evrard. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, FirstViewControllerDelegate {
    func logMsg(text: String?) {
        addToLog(txt: text!)
    }
    
    @IBOutlet weak var txtLog: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        debugPrint("ALE :: debug page loaded");
        addToLog(txt: "debug page loaded");
        let viewController = self.tabBarController?.viewControllers?[0] as? FirstViewController
        viewController?.delegate = self
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addToLog(txt: String) {
        txtLog.text = txtLog.text+txt+"\n"
    }

}


//
//  ViewController.swift
//  StockIt
//
//  Created by Development on 12/1/21.
//  Copyright © 2021 Development. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtMail.borderStyle = UITextBorderStyle.roundedRect
        txtPassword.borderStyle = UITextBorderStyle.roundedRect
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


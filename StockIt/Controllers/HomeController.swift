//
//  Home.swift
//  StockIt
//
//  Created by Development on 12/1/21.
//  Copyright © 2021 Development. All rights reserved.
//

import UIKit

class Home: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cerrarSesion(_ sender: UIButton) {
        
        //Quitar NavigationController para el Login
        var navController = self.navigationController
        
        navController?.dismiss(animated: true){
            navController = nil
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

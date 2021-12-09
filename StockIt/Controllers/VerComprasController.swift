//
//  VerCompras.swift
//  StockIt
//
//  Created by Development on 12/7/21.
//  Copyright © 2021 Development. All rights reserved.
//

import UIKit
import CoreData

class VerCompras: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var managedObjectContext: NSManagedObjectContext!

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadProductos().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        
        let producto: EProducto = loadProductos()[indexPath.row]
        cell.textLabel?.text = "producto.nombreProducto"
        return cell
    }
    

    @IBOutlet weak var tblViewCompras: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadProductos() -> [EProducto]
    {
        let fetchRequest: NSFetchRequest<EProducto> = EProducto.fetchRequest()
        var result: [EProducto] = []
        do {
            result = try managedObjectContext.fetch(fetchRequest)
        } catch {
            NSLog("Error: %@", error as NSError)
        }
        return result
    }


    
}

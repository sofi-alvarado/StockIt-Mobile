//
//  DetalleProducto.swift
//  StockIt
//
//  Created by Development on 12/5/21.
//  Copyright © 2021 Development. All rights reserved.
//

import UIKit

class DetalleCompra: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Variables
    var listProductosCompra = Array<MDetalleCompraProductos>()
    var idEncCompraProductoParametro:Int = 0
    var nomProveedor:String = ""
    var fecha:String = ""
    var monto:Double = 0.0
    
    //Controladores
    @IBOutlet weak var lblProveedor: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var lblMonto: UILabel!
    @IBOutlet weak var tvProductosCompra: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblProveedor.text = nomProveedor
        lblFecha.text = fecha.prefix(10).description
        lblMonto.text = "$\(String(format: "%.2f", monto))"
        
        seleccionarDetalleCompra(idEncabezadoCompra: idEncCompraProductoParametro)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listProductosCompra.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        
        let productoCompra: MDetalleCompraProductos = listProductosCompra[indexPath.row]
        
        if productoCompra.nombreProducto != "" {
            
            cell.textLabel?.text = "\(productoCompra.nombreProducto)"
            cell.detailTextLabel?.text = "$\(String(format: "%.2f", productoCompra.precioVenta))"
            
        } else {
            cell.textLabel?.text = "\(productoCompra.nombreProducto)"
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    //MARK - Metodo para consultar compras
    func seleccionarDetalleCompra(idEncabezadoCompra:Int){
        
        print("Enviar Solicitud Productos Activos")
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/detalleReporteCompraProductosJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "idEncabezadoCompra": idEncabezadoCompra
            ]
        
        request.httpBody = parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else { //si existe un error se termina la funcion
                print("solicitud fallida \(String(describing: error))") //manejamos el error
                
                return
            }
            
            do { //creamos nuestro objeto json
                
                print("Recibimos Repuesta Productos Activos")
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:Any]]
                {
                    
                    DispatchQueue.main.async {
                        
                        for compraJSON in json {
                            let compra:MDetalleCompraProductos = MDetalleCompraProductos()
                            compra.nombreProducto = compraJSON["NOMBRE_PRODUCTO"] as! String
                            compra.precioVenta = compraJSON["PRECIO_REAL"] as! Double
                            self.listProductosCompra.append(compra)
                        }
                        
                        self.tvProductosCompra.delegate = self
                        self.tvProductosCompra.dataSource = self
                        self.tvProductosCompra.reloadData()
                        
                        return
                    }
                } else {
                    return
                }
            }catch let parseError {//manejamos el error
                
                print("Error al parsear: \(parseError)")
                
                let responseString = String(data: data, encoding: .utf8)
                
                print("respuesta: \(responseString!)")
                
                return
            }
        }
        
        task.resume()
    }

}

//
//  ViewControllerProductos.swift
//  StockIt
//
//  Created by Development on 12/9/21.
//  Copyright © 2021 Development. All rights reserved.
//

import UIKit

class ViewControllerProductos: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Variables
    var listaProductos = Array<MCardProducto>()
    var idProducto:Int = 0
    
    //Outlets
    @IBOutlet weak var tvProductos: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tvProductos.delegate = self
        tvProductos.dataSource = self
        
        //Cargamos los productos
        seleccionarProductosActivos(idUsuario: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Delegate & DataSource for TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaProductos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        
        let producto: MCardProducto = listaProductos[indexPath.row]
        
        if producto.nombreProveedor != nil {
            
            cell.textLabel?.text = producto.nombreProducto + " - \(producto.nombreProveedor)"
            
        } else {
            cell.textLabel?.text = producto.nombreProducto + " (Sin proveedor)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(listaProductos[indexPath.row].idProducto)
        idProducto = listaProductos[indexPath.row].idProducto
        //Llamar el otro metodo
        self.performSegue(withIdentifier: "productosSegue", sender: self)
    }
    
    //MARK - Metodo para consultar los productos activos
    func seleccionarProductosActivos(idUsuario:Int){
        
        print("Enviar solicitud")
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/seleccionarProductosByIdUsuarioAndEstadoProductoJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "idUsuario": idUsuario,
            "estadoProducto" : "A",
        ]
        
        request.httpBody = parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else { //si existe un error se termina la funcion
                print("solicitud fallida \(String(describing: error))") //manejamos el error
                
                return
            }
            
            do { //creamos nuestro objeto json
                
                print("recibimos repuesta")
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:Any]]
                {
                    
                    DispatchQueue.main.async {
                        
                        for productoJSON in json {
                            let producto:MCardProducto = MCardProducto()
                            producto.idProducto = productoJSON["ID_PRODUCTO"] as! Int
                            producto.nombreProducto = productoJSON["NOMBRE_PRODUCTO"] as! String
                            producto.nombreProveedor = productoJSON["NOMBRE_PROVEEDOR"] as! String
                            producto.categoria = productoJSON["CATEGORIA"] as! String
                            producto.existencia = productoJSON["UNIDADES_ACTUALES"] as! Int
                            producto.precio = productoJSON["PRECIO_ACTUAL"] as! Double
                            producto.unidadesNuevas = productoJSON["UNIDADES_NUEVAS"] as! Int
                            producto.precioNuevo = productoJSON["PRECIO_NUEVO"] as! Double
                            self.listaProductos.append(producto)
                        }
                        
                        self.tvProductos.reloadData()
                        
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

//
//  VerCompras.swift
//  StockIt
//
//  Created by Development on 12/7/21.
//  Copyright © 2021 Development. All rights reserved.
//

import UIKit

class VerCompras: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Variables
    var listaCompras = Array<MEncabezadoCompraProductos>()
    var idUsuarioParametro:Int = 0
    var idEncCompraProductos:Int = 0
    var nomProveedor:String = ""
    var fechaIngreso:String = ""
    var monto:Double = 0.0
    
    //Outlets
    @IBOutlet weak var tvCompras: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //listaProductos.removeAll()
        seleccionarCompras(idUsuario: idUsuarioParametro)
    }
    
    // MARK: - Delegate & DataSource for TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaCompras.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        
        let compra: MEncabezadoCompraProductos = listaCompras[indexPath.row]
        
        if compra.nombreProveedor != "" {
            
            let fechaIngresoDate = compra.fechaIngreso.prefix(10)
            
            cell.textLabel?.text = compra.nombreProveedor
            cell.detailTextLabel?.text = "$\(String(format: "%.2f", compra.monto))  - \(fechaIngresoDate)"
            
        } else {
            cell.textLabel?.text = "$\(String(format: "%.2f", compra.monto)) (Sin fecha)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        idEncCompraProductos = listaCompras[indexPath.row].idEncCompraProductos
        nomProveedor = listaCompras[indexPath.row].nombreProveedor
        fechaIngreso = listaCompras[indexPath.row].fechaIngreso
        monto = listaCompras[indexPath.row].monto
        
        //Navegar a pantalla de Detalle Compra
        self.performSegue(withIdentifier: "detalleSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productosSegue2" {
            let viewControllerProductos = segue.destination as! ViewControllerProductos
            viewControllerProductos.idUsuarioParametro = idUsuarioParametro
        } else if segue.identifier == "detalleSegue" {
            let viewControllerComprasDetalle = segue.destination as! DetalleCompra
            viewControllerComprasDetalle.idEncCompraProductoParametro = idEncCompraProductos
            viewControllerComprasDetalle.nomProveedor = nomProveedor
            viewControllerComprasDetalle.fecha = fechaIngreso
            viewControllerComprasDetalle.monto = monto
        }
    }
    
    //MARK - Metodo para consultar compras
    func seleccionarCompras(idUsuario:Int){
        
        print("Enviar Solicitud Productos Activos")
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/encabezadosReporteCompraProductosJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let fechaInicioStr = "2021-11-01"
        let dateFormatter = DateFormatter()
        
        let fechaActual = Date()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fechaFinalStr = dateFormatter.string(from: fechaActual)
        
        let parameters: [String: Any] = [
            "idUsuario": idUsuario,
            "fechaInicio" : fechaInicioStr,
            "fechaFinal" : fechaFinalStr,
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
                        
                        if self.listaCompras.count > 0 {
                            self.listaCompras.removeAll()
                        }
                        
                        for compraJSON in json {
                            let compra:MEncabezadoCompraProductos = MEncabezadoCompraProductos()
                            compra.idEncCompraProductos = compraJSON["ID_ENC_COMPRA_PRODUCTOS"] as! Int
                            compra.nombreProveedor = compraJSON["NOMBRE_PROVEEDOR"] as! String
                            compra.fechaIngreso = compraJSON["FECHA_INGRESO"] as! String
                            compra.monto = compraJSON["MONTO"] as! Double
                            self.listaCompras.append(compra)
                        }
                        
                        self.tvCompras.delegate = self
                        self.tvCompras.dataSource = self
                        self.tvCompras.reloadData()
                        
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

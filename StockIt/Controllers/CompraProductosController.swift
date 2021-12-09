
import UIKit



class CompraProductos: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //Variables
    var proveedores = Array<MProveedor>()
    var idProveedor:Int = 0
    var categorias = Array<MCategoria>()
    var idCategoria:Int = 0
    
    //Controladores
    @IBOutlet weak var pvProveedores: UIPickerView!
    @IBOutlet weak var pvCategorias: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Llenamos los PickerView
        obtenerProveedores()
        obtenerCategorias()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Objeto PickerView seccion DataSource y Delegate
    //MARK: DataSources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == pvProveedores {
            return 1
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == pvProveedores {
            return self.proveedores.count
        } else {
            return self.categorias.count
        }
        
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == pvProveedores {
            return self.proveedores[row].nombreProveedor
        } else {
            return self.categorias[row].categoria
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == pvProveedores {
            idProveedor = self.proveedores[row].idProveedor
        } else if pickerView == pvCategorias {
            idCategoria = self.categorias[row].idCategoria
        }
        
    }
    
    //Metodo para llenar proveedores
    func obtenerProveedores(){
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/seleccionarProveedoresActivosByIdUsuarioJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "idUsuario": 1,
        ]
        
        request.httpBody = parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else { //si existe un error se termina la funcion
                print("solicitud fallida \(String(describing: error))") //manejamos el error
                
                return
            }
            
            do { //creamos nuestro objeto json
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:Any]]
                {
                    
                    DispatchQueue.main.async {
                        
                        for proveedoresJson in json{
                            let proveedor:MProveedor = MProveedor()
                            proveedor.idProveedor = proveedoresJson["ID_PROVEEDOR"] as! Int
                            proveedor.nombreProveedor = proveedoresJson["NOMBRE_PROVEEDOR"] as! String
                            self.proveedores.append(proveedor)
                        }
                        
                        self.pvProveedores.dataSource = self
                        self.pvProveedores.delegate = self
                        self.pvProveedores.reloadAllComponents()
                        
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

    
    //Metodo para llenar categorias
    func obtenerCategorias(){
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/seleccionarCategoriasActivasByIdUsuarioJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "idUsuario": 1,
        ]
        
        request.httpBody = parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else { //si existe un error se termina la funcion
                print("solicitud fallida \(String(describing: error))") //manejamos el error
                
                return
            }
            
            do { //creamos nuestro objeto json
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:Any]]
                {
                    
                    DispatchQueue.main.async {
                        
                        for categoriaJson in json{
                            let categoria:MCategoria = MCategoria()
                            categoria.idCategoria = categoriaJson["ID_CATEGORIA"] as! Int
                            categoria.categoria = categoriaJson["CATEGORIA"] as! String
                            self.categorias.append(categoria)
                        }
                        
                        self.pvCategorias.dataSource = self
                        self.pvCategorias.delegate = self
                        self.pvCategorias.reloadAllComponents()
                        
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

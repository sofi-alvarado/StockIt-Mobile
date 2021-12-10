
import UIKit



class CompraProductos: UIViewController {
    
    //Variables
    var idProductoParametro:Int = 0//Variable a pasar desde pantalla Productos
    var nomProveedor:String = ""
    var nomCategoria:String = ""
    var nomProducto:String = ""
    var cantidad:Int = 0
    var precioLote:Double = 0.0
    var precioUnitario:Double = 0.0
    var porcentajeGanancia:Double = 0.0
    var ganancia:Double = 0.0
    var precioVenta:Double = 0.0
    var detalles:String = ""
    
    //Controladores de Vistas
    @IBOutlet weak var lblNomProveedor: UILabel!
    @IBOutlet weak var lblNomCategoria: UILabel!
    @IBOutlet weak var lblNomProducto: UILabel!
    @IBOutlet weak var lblCantidad: UILabel!
    @IBOutlet weak var txtPrecioLote: UITextField!
    @IBOutlet weak var txtPrecioUnitario: UITextField!
    @IBOutlet weak var txtPorcentajeGanancia: UITextField!
    @IBOutlet weak var txtGanancia: UITextField!
    @IBOutlet weak var txtPrecioVenta: UITextField!
    @IBOutlet weak var lblDetalles: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblNomProveedor.text = nomProveedor
        lblNomCategoria.text = nomCategoria
        lblNomProducto.text = nomProducto
        lblDetalles.text = detalles
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Insertar Productos - Inicio
    
    @IBAction func btnFinalizarCompra(_ sender: UIButton) {
        
        if 5 <= 0 {
            
            print("Debes seleccionar una imagen")
            
        } else {
            insertarProductos(idCategoria: 0, idUsuario: 1, nombreProducto: "Producto", precio: 5.0, existencia: 5, detalles: "Detalles"){
                (r) in
                print("Resultado compra: \(String(r))")
            }
        }
        
    }
    
    //MARK: Insertar Productos - Fin
    
    
    
    //Metodo para guardar productos
    func insertarProductos(idCategoria:Int, idUsuario:Int, nombreProducto:String, precio:Double, existencia:Int, detalles:String, completion:@escaping(_ r:Int) -> ()){
        
        print("Enviar solicitud")
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/insertarProductosJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "idCategoria": idCategoria,
            "idUsuario": idUsuario,
            "nombreProducto" : nombreProducto,
            "precio" : precio,
            "existencia" : existencia,
            "detalles" : detalles
        ]
        
        request.httpBody = parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else { //si existe un error se termina la funcion
                print("solicitud fallida \(String(describing: error))") //manejamos el error
                
                completion(-3)
                return
            }
            
            do { //creamos nuestro objeto json
                
                print("recibimos repuesta")
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:Any]]
                {
                    
                    DispatchQueue.main.async {
                        
                        print("Datos completos: \(json)")
                        
                        let idUsuario:Int = json[0]["ID_PRODUCTO"] as! Int
                        
                        print("Datos: \(json[0]["ID_PRODUCTO"] ?? "null")")
                        
                        completion(idUsuario)
                        return
                    }
                } else {
                    completion(-3)
                    return
                }
            }catch let parseError {//manejamos el error
                
                print("Error al parsear: \(parseError)")
                
                let responseString = String(data: data, encoding: .utf8)
                
                print("respuesta: \(responseString!)")
                
                completion(-3)
                return
            }
        }
        
        task.resume()
    }

}

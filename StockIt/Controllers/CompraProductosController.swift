
import UIKit



class CompraProductos: UIViewController, UITextFieldDelegate {
    
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
        
        //Asignamos delegates
        txtPorcentajeGanancia.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Control de TextField onChange - Inicio
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPorcentajeGanancia {
            
            if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil{
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == txtPorcentajeGanancia {
            let porcentajeGananciaS = txtPorcentajeGanancia.text != nil ? txtPorcentajeGanancia.text : "0"
            porcentajeGanancia = (porcentajeGananciaS! as NSString).doubleValue / 100
        }
    }
    //MARK: Control de TextField onChange - Fin
    
    //MARK: Agregar/Disminuir cantidad - Inicio
    
    @IBAction func stepperCantidad(_ sender: UIStepper) {
        cantidad = Int(sender.value)
        lblCantidad.text = String(cantidad)
    }
    
    //MARK: Agregar/Disminuir cantidad - Fin
    
    //MARK: Metodos de calculos - Inicio
    func calcGananciaYPrecioVenta(){
        
    }
    //MARK: Metodos de calculos - Fin
    
    //MARK: Insertar Compra - Inicio
    
    @IBAction func btnFinalizarCompra(_ sender: UIButton) {
        
        var message:String = ""//Variable para mostrar alert
        
        if idProductoParametro <= 0 || cantidad <= 0 || precioLote <= 0.0 || precioUnitario <= 0.0 || porcentajeGanancia <= 0.0 || porcentajeGanancia > 100 || ganancia <= 0.0 || precioVenta <= 0.0{
            
            if idProductoParametro <= 0 {
                
                message = "No has seleccionado un producto"
                
            } else if porcentajeGanancia > 100 {
                
                message = "El porcentaje de ganancia no puede ser superior al 100%"
                
            } else {
                
                message = "Debes completar todos los campos"
                
            }
            
            let alert = UIAlertController(title: "Alerta", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
        } else {
            print("Paso las validaciones")
            
            
            /*insertarProductos(idCategoria: 0, idUsuario: 1, nombreProducto: "Producto", precio: 5.0, existencia: 5, detalles: "Detalles"){
                (r) in
                print("Resultado compra: \(String(r))")
            }*/
            //Insertar compra
        }
        
    }
    
    //Metodo para comprar productos
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
    //MARK: Insertar Compra - Fin

}

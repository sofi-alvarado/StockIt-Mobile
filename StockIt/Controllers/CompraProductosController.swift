
import UIKit

extension String {
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        
        // Usamos NumberFormatter para verificar si podemos convertir la cadena en numero
        // y ubicar el punto decimal.
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."  // Obtenemos la ubicacion especifica del punto decimal. Si no hay uno, asumimos "." como valor.
        
        // Verificamos si podemos crear un numero valido
        if formatter.number(from: self) != nil {
            
            // Separamos nuestra cadena en el punto decimal
            let split = self.components(separatedBy: decimalSeparator)
            
            let digits = split.count == 2 ? split.last ?? "" : ""
            
            
            return digits.count <= maxDecimalPlaces
        }
        
        return false
    }
}

class CompraProductos: UIViewController, UITextFieldDelegate {
    
    //Variables
    var idProductoParametro:Int = 0//Variable a pasar desde pantalla Productos
    var idProveedorParametro:Int = 0//Variable a pasar desde pantalla Productos
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
        txtPrecioLote.delegate = self
        txtPrecioUnitario.delegate = self
        txtPorcentajeGanancia.delegate = self
        txtGanancia.delegate = self
        txtPrecioVenta.delegate = self
        
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
            
        } else if textField == txtPrecioLote {
            
            let currentText = textField.text ?? ""
            let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Use our string extensions to check if the string is a valid double and
            // only has the specified amount of decimal places.
            return replacementText.isValidDouble(maxDecimalPlaces: 2)
        } else {
            return false
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == txtPorcentajeGanancia {
            
            let valorTextField = txtPorcentajeGanancia.text != nil ? txtPorcentajeGanancia.text : "0"
            porcentajeGanancia = (valorTextField! as NSString).doubleValue / 100
            
            calcGananciaYPrecioVenta()
            
        } else if textField == txtPrecioLote {
            
            let valorTextField = txtPrecioLote.text != nil ? txtPrecioLote.text : "0"
            precioLote = (valorTextField! as NSString).doubleValue
            
            calcGananciaYPrecioVenta()
        }
    }
    //MARK: Control de TextField onChange - Fin
    
    //MARK: Agregar/Disminuir cantidad - Inicio
    
    @IBAction func stepperCantidad(_ sender: UIStepper) {
        cantidad = Int(sender.value)
        lblCantidad.text = String(cantidad)
        
        calcGananciaYPrecioVenta()
    }
    
    //MARK: Agregar/Disminuir cantidad - Fin
    
    //MARK: Metodos de calculos - Inicio
    func calcGananciaYPrecioVenta(){
        precioUnitario = (precioLote / Double(cantidad))
        txtPrecioUnitario.text = String(format: "%.2f", precioUnitario)
        
        ganancia = (precioUnitario * porcentajeGanancia)
        txtGanancia.text = String(format: "%.2f", ganancia)
        
        precioVenta = (precioUnitario + ganancia)
        txtPrecioVenta.text = String(format: "%.2f", precioVenta)
        
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
            
            var message:String = ""//Variable para mostrar alert
            
            insertarEncabezadoCompra(idProveedor: idProveedorParametro, monto: precioLote){
                (r) in
                
                if r > 0 {
                    //Insertar detalle
                    self.insertarDetalleCompraPoductos(idEncabezado: r, idProducto: self.idProductoParametro, cantidad: self.cantidad, precioLote: self.precioLote, precioUnitario: self.precioUnitario, precioUnitarioReal: self.precioVenta, porcentajeGanancia: self.porcentajeGanancia){
                        (r) in
                        
                        print("Resultado compra: \(String(r))")
                    }
                    
                } else if r == -1 {
                    
                    message = "No puedes agregar un nuevo lote, hay uno en existencia."
                    
                } else {
                    
                    message = "Hubo un error. Intente mas tarde."
                    
                }
                
                let alert = UIAlertController(title: "Alerta", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
            
            //Insertar compra
        }
        
    }
    
    //Metodo para insertar encabezado compra
    func insertarEncabezadoCompra(idProveedor:Int, monto:Double, completion:@escaping(_ r:Int) -> ()){
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/insertarEncabezadoCompraJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "idProveedor": idProveedor,
            "monto" : monto,
        ]
        
        request.httpBody = parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else { //si existe un error se termina la funcion
                print("solicitud fallida \(String(describing: error))") //manejamos el error
                
                completion(-2)
                return
            }
            
            do { //creamos nuestro objeto json
                
                print("recibimos repuesta")
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:Any]]
                {
                    
                    DispatchQueue.main.async {
                        
                        print("Datos completos: \(json)")
                        
                        let encabezadoCompra:MEncabezadoCompraProductos = MEncabezadoCompraProductos()
                        
                        for encabezadoCompraJSON in json{
                            
                            encabezadoCompra.idEncCompraProductos = encabezadoCompraJSON["ID_ENC_COMPRA_PRODUCTOS"] as! Int
                            
                        }
                        
                        completion(encabezadoCompra.idEncCompraProductos)
                        return
                    }
                } else {
                    completion(-2)
                    return
                }
            }catch let parseError {//manejamos el error
                
                print("Error al parsear: \(parseError)")
                
                let responseString = String(data: data, encoding: .utf8)
                
                print("respuesta: \(responseString!)")
                
                completion(-2)
                return
            }
        }
        
        task.resume()
    }
    
    //Metodo para insertar detalle compra
    func insertarDetalleCompraPoductos(idEncabezado:Int, idProducto:Int, cantidad:Int, precioLote:Double, precioUnitario:Double, precioUnitarioReal:Double, porcentajeGanancia:Double, completion:@escaping(_ r:Int) -> ()){
        
        print("Enviar solicitud")
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/insertarProductosJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "idEncabezado": idEncabezado,
            "idProducto": idProducto,
            "cantidad" : cantidad,
            "precioLote" : precioLote,
            "precioUnitario" : precioUnitario,
            "precioUnitarioReal" : precioUnitarioReal,
            "porcentajeGanancia" : porcentajeGanancia
        ]
        
        request.httpBody = parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else { //si existe un error se termina la funcion
                print("solicitud fallida \(String(describing: error))") //manejamos el error
                
                completion(-2)
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
                    completion(-2)
                    return
                }
            }catch let parseError {//manejamos el error
                
                print("Error al parsear: \(parseError)")
                
                let responseString = String(data: data, encoding: .utf8)
                
                print("respuesta: \(responseString!)")
                
                completion(-2)
                return
            }
        }
        
        task.resume()
    }
    //MARK: Insertar Compra - Fin

}

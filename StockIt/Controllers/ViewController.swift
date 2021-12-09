//
//  ViewController.swift
//  StockIt
//
//  Created by Development on 12/1/21.
//  Copyright © 2021 Development. All rights reserved.
//

import UIKit

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
            .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

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

    @IBAction func iniciarSesion(_ sender: UIButton) {
        if txtMail.text != nil && txtPassword.text != nil{
            if txtMail.text != "" && txtPassword.text != ""{
                var resultado:Int = 0
                
                login(email: txtMail.text!, password: txtPassword.text!){
                    (r) in
                    resultado = r
                    
                    if r > 0 {
                        self.performSegue(withIdentifier: "homeSegue", sender: self)
                    } else {
                        print("Resultado: \(String(resultado))")
                    }
                }
            }
        } else {
            
        }
    }
    
    func login(email:String, password:String, completion:@escaping(_ r:Int) -> ()){
        
        print("Enviar solicitud")
        
        //192.168.1.8
        let url=URL(string: "http://192.168.1.8/WebService/WebServiceSI.asmx/loginJSON")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "correo": email,
            "password": password
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
                        
                        let idUsuario:Int = json[0]["ID_USUARIO"] as! Int
                        
                        print("Datos: \(json[0]["ID_USUARIO"] ?? "null")")
                        
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


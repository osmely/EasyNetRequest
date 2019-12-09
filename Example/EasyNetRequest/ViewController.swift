//
//  ViewController.swift
//  EasyNetRequest
//
//  Created by m-kinesis on 12/07/2019.
//  Copyright (c) 2019 m-kinesis. All rights reserved.
//

import UIKit
import EasyNetRequest


//================================================================
//================================================================

//La estructura de datos de la respuesta de api
struct User: Codable {
    let id: Int
    let username: String
}


//La request que maneja la llamada a la api '/users'
struct GetAllUsers: EasyNetRequest {
    
    //Declarar el tipo de respuesta (si es array declaramos como array de la estructura!)
    typealias EasyNetResponseType = [User]
    
    //Podemos agrupar en un enum los errores que va a generar esta api especificamente.
    enum Errors : Error {
        case userNumInsuficiente
        case jsonError
    }

    //Este es un ejemplo de validador que genera un error si el numero de users es < 100
    struct Validator : EasyNetResponseValidator {
        func validate(json: Any) throws {
            guard let json_a = json as? [[String: Any]] else {
                throw Errors.jsonError
            }
            guard json_a.count > 100 else {
                throw Errors.userNumInsuficiente
            }
        }
    }
    
    func log(data: String) {
        print("\(data)")
    }
    
    //Construimos la informacion de esta request.
    var data: EasyNetRequestData {
        return EasyNetRequestData(path: "https://jsonplaceholder.typicode.com/users", method: .GET)
    }
    
    //Podemos declarar validadores para esta request.. cada validador va a ser consultado uno tras otro,
    //en caso de que todos se cumplan la llamada tendra lugar. Si no hay validadores devolver [] o nil
    var validators: [EasyNetResponseValidator]? { nil /* [Validator()] */}
}



//================================================================
//================================================================



class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var users = [User]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        
        GetAllUsers().execute { (result) in
            do {
               let users = try result.get()
                self.users = users
                
                //los errores pueden ser capturados uno a uno
            } catch GetAllUsers.Errors.userNumInsuficiente {
                print("el numero de users es insuficiente")
                
                //los errores pueden ser capturados todos en un solo lugar
            } catch {
                self.users = []
                print(error.localizedDescription)
            }
            
            //Esta es otra variante!
            //if let users = try? result.get() {
            //
            //}
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.users[indexPath.row].username
        return cell
    }
    
    
}



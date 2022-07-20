//
//  Alerts.swift
//  GeoMarker
//
//  Created by Игорь Ущин on 19.07.2022.
//

import UIKit

extension  UIViewController {
  //Coordinate alert
    func alertAddAdress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
      let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
      let actionAlert = UIAlertAction(title: "Добавить", style: .default) {(action) in
            
          
          let tfText = alertController.textFields?.first
          guard let text = tfText?.text else { return }
          completionHandler(text)
        }
        alertController.addTextField { (tf) in
            tf.placeholder = placeholder
        }
        let alertCancel = UIAlertAction(title: "Отмена", style: .destructive) { (_) in
        }
        alertController.addAction(actionAlert)
        alertController.addAction(alertCancel)
        present(alertController, animated:  true, completion:  nil)
    }
    //Error alert
    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Хорошо", style: .default)
        
        alertController.addAction(alertOk)
        present(alertController, animated: true)
    }
}

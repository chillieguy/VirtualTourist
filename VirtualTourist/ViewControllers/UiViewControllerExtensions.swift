//
//  UiViewControllerExtensions.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 12/22/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(_ errorString: String = "Could not connect to network."){
        let alert = UIAlertController(title: "Error", message:
            errorString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

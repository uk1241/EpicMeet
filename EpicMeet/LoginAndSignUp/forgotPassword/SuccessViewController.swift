//
//  SuccessViewController.swift
//  EpicMeet
//
//  Created by R.Unnikrishnan on 25/07/23.
//

import UIKit

class SuccessViewController: UIViewController {

    @IBOutlet var backToLoginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToLoginAction(_ sender: Any)
    {
        navigationController?.popToRootViewController(animated: true)
    }
}

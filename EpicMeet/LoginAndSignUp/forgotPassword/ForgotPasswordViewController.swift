//
//  ForgotPasswordViewController.swift
//  EpicMeet
//
//  Created by R.Unnikrishnan on 25/07/23.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var submitBtn: RoundedButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitBtnAction(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let successPage = storyboard.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController

        if let navigationController = self.navigationController {
            navigationController.pushViewController(successPage, animated: true)
        }
    }
    
}

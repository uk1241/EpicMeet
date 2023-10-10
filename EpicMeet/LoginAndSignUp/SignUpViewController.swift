//
//  SignUpViewController.swift
//  EpicMeet
//
//  Created by R Unnikrishnan on 20/09/23.
//

import UIKit
import Starscream
import SwiftyJSON
import WebRTC
import AVFoundation
import NotificationCenter
class SignUpViewController: UIViewController {
    @IBOutlet var bgView : UIImageView!
    @IBOutlet var firstName : UITextField!
    @IBOutlet var LastName : UITextField!
    @IBOutlet var userName : UITextField!
    @IBOutlet var email : UITextField!
    @IBOutlet var password : UITextField!
    @IBOutlet var signUpBtn : UIButton!
    private var command: RequestHelper!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        //MARK: - CORNER RADIUS FOR THE TEXT FIELD AND BUTTON
        firstName.layer.cornerRadius = 6
        LastName.layer.cornerRadius = 6
        userName.layer.cornerRadius = 6
        email.layer.cornerRadius = 6
        password.layer.cornerRadius = 6
        signUpBtn.layer.cornerRadius = 6
        //MARK: - TEXTFEILD DELEGATE
        firstName.delegate = self
        LastName.delegate = self
        userName.delegate = self
        email.delegate = self
        password.delegate = self
        //MARK: - FOR AUTO LAYOUT WHILE KEYBOARD ON TEXTFEILD
        // Register for keyboard notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: - KEYBOARD AUTOLAYOUT ACTIONS
    @objc func keyboardShown(notification: Notification)
    {
        // Get the keyboard size.
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size ?? .zero
        // Move the view up by the keyboard size.
        self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height)
    }
    @objc func keyboardHidden(notification: Notification) {
        // Move the view back to its original position.
        self.view.transform = .identity
    }
    @IBAction func signUpBtnAction(_ Sender : UIButton)
    {
        //MARK: - SIGNUP FUNCTION PARAMS VALUES 
        let firstname = firstName.text!
        let lastname = LastName.text!
        let username = userName.text!
        let email = email.text!
        let password = password.text!
        let name = firstname + " " + lastname
        print("name :",name)// Concatenate the first name and last name with a space in between
        //MARK: - SIGNUP FUNCTION CALL(EXECUTION)
        command.signUpRequest(
            name: name,
            email: email,
            password: password,
            clientID: "",
            isPasswordRequired: true,
            allowMultiple: true,
            profile: [:],
            groupName: "",
            sessionID: "" ,
            sessions: []
        )
    }
}
extension SignUpViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        firstName.resignFirstResponder()
        LastName.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        userName.resignFirstResponder()
        textField.resignFirstResponder()
        return true
    }
}
//MARK: - REDIRECTION AFTER SIGNUP SUCEESSFULL
extension SignUpViewController : signIndelegate
{
    func passData()
    {
        DispatchQueue.main.async{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let signIn = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            self.navigationController?.pushViewController(signIn, animated: true)
        }
    }
}


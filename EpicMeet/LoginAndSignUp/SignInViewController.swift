//  SignInViewController.swift
//  EpicMeet
//  Created by R Unnikrishnan
import UIKit
import Starscream
import SwiftyJSON
import WebRTC
import AVFoundation
import NotificationCenter
class SignInViewController: UIViewController{
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn : UIButton!
    @IBOutlet weak var passwordEye : UIButton!
    @IBOutlet weak var  forgotPasswordBtn : UIButton!
    var toggleState = false
    private var command:RequestHelper!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.layer.cornerRadius = 6
        passwordField.layer.cornerRadius = 6
        loginBtn.layer.cornerRadius = 6
        emailField.delegate = self
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
        //MARK: - SOCKET CONNECTION
        let url = URL(string: "wss://\(SocketUtil.BASE_URL)")!
        var request = URLRequest(url: url)
        request.setValue("protoo", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        let pinner = FoundationSecurity(allowSelfSigned: true)
        let compression = WSCompression()
        let socket = WebSocket(request: request, certPinner:pinner, compressionHandler: compression)
        socket.callbackQueue = DispatchQueue.global()
        command = RequestHelper.createOpen(socket, ip: SocketUtil.BASE_URL)
        socket.connect()
        command.signIndelegate = self
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
    //MARK: - MAKE THE NAVIGATION BAR HIDDEN AFTER SIGNUP CALL BACK
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    //MARK: - BUTTON ACTIONS
    @IBAction func loginBtnAction(_ sender: Any)
    {
        emailField.text = "ios@appsteamtechnologies.com"
        passwordField.text = "123456789"
        let email = emailField.text!
        let password = passwordField.text!
        print("LOGIN BUTTON TAPPED")
        command.loginRequest(email: email, password: password)
    }
    @IBAction func signUpBtnAction(_ sender : UIButton)
    {
        print("SIGNUP BUTTON TAPPED")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homePage = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        if let navigationController = self.navigationController
        {
            navigationController.pushViewController(homePage, animated: true)
        }
    }
    @IBAction func passwordEyeBtnAction(_ sender: UIButton)
    {
        if toggleState == false
        {
            passwordField.isSecureTextEntry = false
            toggleState = true
        }
        else
        {
            passwordField.isSecureTextEntry = true
            toggleState = false
        }
    }
    @IBAction func forgotPasswordAction(_ sender: UIButton)
    {
        print("FORGOT PASSWORD BUTTON TAPPED")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let forgotPasswordVc = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(forgotPasswordVc, animated: true)
    }
}
//MARK: - EXTENSIONS
extension SignInViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        textField.resignFirstResponder()
        return true
    }
}
//MARK: - PASSING THE VIEWCONTROLLER AFTER LOGIN EVENT 
extension SignInViewController : signIndelegate
{
    func passData() {
        DispatchQueue.main.async{ [self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homePage = storyboard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            homePage.command = self.command
            if let navigationController = self.navigationController {
                navigationController.pushViewController(homePage, animated: true)
            }
        }
    }
}

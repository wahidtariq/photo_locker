//
//  AuthenticateViewController.swift
//  Locker
//
//  Created by wahid tariq on 31/10/21.
//

import UIKit
import LocalAuthentication
private var loginPassword: String?

class AuthenticateViewController: UIViewController {
    @IBOutlet var imageview: UIImageView!
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageview.isUserInteractionEnabled = true
        imageview.addGestureRecognizer(tapGestureRecognizer)
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Identify Yourself!."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){ [weak self] (success,authError) in
                DispatchQueue.main.async {
                    if success{
                        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "ImagesVc") as! ViewController
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
                    }else{
                        
                        //  biometric is avaliable but could not be verified.
                        
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be Verified, Please Try Again Later", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        ac.addAction(UIAlertAction(title: "Try Password.", style: .default, handler: { _ in
                            self?.loginWithPassword()
                        }))
                        
                        
                        self?.present(ac, animated: true, completion: nil)
                    }
                }
            }
        }else{
            
            //             there is neither touch id or face id.
            
            let ac = UIAlertController(title: "Biometry Unavaliable", message: "your device is not configured with Biometric authentication", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            ac.addAction(UIAlertAction(title: "Try Password", style: .default, handler: { _ in
                self.loginWithPassword()
            }))
            
            
            present(ac, animated: true, completion: nil)
        }
    }
    
    @objc func saveSecretMessage(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func passwordTapped(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Password Manager", message: "Remember You can only Set Your password once.", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Set Your Passowrd", style: .default, handler: { (action) in
            //            Setting Password.
            
            self.setPassword()
            
        }))
        ac.addAction(UIAlertAction(title: "Change Your Password", style: .default, handler: { (action1) in
            //            code for change password.
            self.changePassword()
            
        }))
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func setPassword(){
        
        let checkPassword = self.defaults.string(forKey: "savedPassword")
        
        if checkPassword != nil{
            
            self.uiAlert(title: "Password Already set.", message: "Password is already set, you can set your password only once.")
            return
        }else{
            
            
            var password = UITextField()
            var confirmPassword = UITextField()
            
            let alert = UIAlertController(title: "Enter Your Password.", message: "Remember You Can only Set your password once.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Done", style: .cancel) { (action) in
                
                guard let password = password.text else {return}
                guard let cfrmPassword = confirmPassword.text else {return}
                
                //            Checking for empty Fields. if empty show alert.
                
                if password.isEmpty || cfrmPassword.isEmpty{
                    self.uiAlert(title: "Empty Fields", message: "Please Fill All Fields")
                    return
                }
                
                if password == cfrmPassword{
                    //                if passwords are same then save it.
                    
                    self.defaults.set(password, forKey: "savedPassword")
                    guard let passwordForSave = self.defaults.string(forKey: "savedPassword") else {return}
                    loginPassword = passwordForSave
                    self.uiAlert(title: "Success!", message: "Saved Succesfully.")
                    
                }else{
                    
                    self.uiAlert(title: "Oops Not Matching.", message: "Passwords are not matching.Try again")
                }
                
                
                
                
            }
            alert.addTextField { (passwordTextField) in
                passwordTextField.placeholder = "Enter your Password."
                passwordTextField.isSecureTextEntry = true
                password = passwordTextField
            }
            alert.addTextField { (confirmPasswordField) in
                confirmPasswordField.placeholder = "Confirm Your Password."
                confirmPasswordField.isSecureTextEntry = true
                confirmPassword = confirmPasswordField
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func uiAlert(title: String,message: String){
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
        
    }
    
    
    func loginWithPassword(){
        var tempPassword = UITextField()
        guard let password = self.defaults.string(forKey: "savedPassword") else
        {
            self.uiAlert(title: "Password is not set yet.", message: "Set your Password.")
//            fatalError("cannot find password in user defaults.")
            return
            
        }
        
        let alert = UIAlertController(title: "Enter Your Password.", message: "Enter password To Login.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { _ in
            guard let passwordForLogin = tempPassword.text else {return}
            
            if password == passwordForLogin{
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImagesVc") as! ViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                self.uiAlert(title: "Invalid Password", message: "Password is invalid.")
            }
        }
        alert.addTextField { (passwordTextField) in
            passwordTextField.placeholder = "Enter Your Password"
            passwordTextField.isSecureTextEntry = true
            tempPassword = passwordTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func changePassword(){
        var oldPassword = UITextField()
        var newPassword = UITextField()
        var confirmNewPassword = UITextField()
        
        guard let password = self.defaults.string(forKey: "savedPassword") else {fatalError("cannot find password in user defaults.")}
        
        
        let alert = UIAlertController(title: "Change Your Password", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Submit", style: .default) { (action) in
            guard let oldpass = oldPassword.text else {return}
            guard let newpass = newPassword.text else {return}
            guard let confirmNewPass = confirmNewPassword.text else {return}
            
            if oldpass.isEmpty || newpass.isEmpty || confirmNewPass.isEmpty{
                self.uiAlert(title: "Empty fields.", message: "Please Fill All Fields.")
                return
            }
            if oldpass == password{
                
                //                check if newPassword and confirm new passwords are same.
                if newpass == confirmNewPass{
                    
                    self.defaults.set(newpass, forKey: "savedPassword")
                    loginPassword = self.defaults.string(forKey: "savedPassword")
                    print(loginPassword!)
                    //                    print("loginPassword before saving\(loginPassword)")
                    //
                    //                    loginPassword = newPassword
                    //                    print("loginPassword after saving\(loginPassword)")
                    self.uiAlert(title: "Success!", message: "Password Changed Successfully.")
                }else{
                    self.uiAlert(title: "Try again", message: "Passwords are not matching.")
                }
            }else{
                self.uiAlert(title: "Invalid old Password", message: "old password is invalid please enter correct old password.")
            }
            
        }
        
        alert.addTextField { (oldPasswordTextField) in
            oldPasswordTextField.placeholder = "Enter Your old Password."
            oldPasswordTextField.isSecureTextEntry = true
            oldPassword = oldPasswordTextField
        }
        alert.addTextField { (newPasswordTextField) in
            newPasswordTextField.placeholder = "Enter New Password"
            newPassword = newPasswordTextField
        }
        alert.addTextField { (confirmNewPasswordTextField) in
            confirmNewPasswordTextField.placeholder = "Confirm New Password."
            confirmNewPasswordTextField.isSecureTextEntry = true
            confirmNewPassword = confirmNewPasswordTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
}

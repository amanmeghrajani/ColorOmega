//
//  SettingsViewController.swift
//  ColorOmega
//
//  Created by  user on 7/31/17.
//  Copyright © 2017 Aman Meghrajani. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField
import SAMKeychain


class SettingsViewController: UIViewController, UITextFieldDelegate {

    var ref : FIRDatabaseReference?
    var username: String!
    var usernameInput : SkyFloatingLabelTextField!
    var hideStatusBar = true
    var anonymous = "anonymous"
    let doneButton = UIButton(frame: CGRect(x: 125, y: 400, width: 100, height: 50))
    var usernameKey = "username"
    lazy var uuid : String = {
        return self.UUID()
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference().child("users")
        self.hideKeyboardWhenTappedAround()
        self.loadUsername()
        
        
        self.usernameInput = SkyFloatingLabelTextField(frame: CGRect(x: 10, y: 10, width: 120, height: 45))
        self.usernameInput.translatesAutoresizingMaskIntoConstraints = false
       
        let mainview = self.view!
        mainview.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        mainview.addSubview(usernameInput)
        mainview.addSubview(doneButton)
        
        doneButton.backgroundColor = UIColor.brown
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchDown)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
    
        
        //setup constraints
        NSLayoutConstraint.activate([
            usernameInput.leftAnchor.constraint(equalTo: mainview.leftAnchor, constant: 50),
            usernameInput.topAnchor.constraint(equalTo: mainview.topAnchor, constant: 70),
            usernameInput.widthAnchor.constraint(equalToConstant: 200),
            
            doneButton.leftAnchor.constraint(equalTo: mainview.leftAnchor, constant: 50),
            doneButton.widthAnchor.constraint(equalToConstant: 100),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            doneButton.topAnchor.constraint(equalTo: usernameInput.bottomAnchor, constant: 30)
            
            
            ])
        
        usernameInput.textColor = .black
        usernameInput.placeholderColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        usernameInput.selectedTitleColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        usernameInput.errorColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        usernameInput.delegate = self
        self.usernameInput.placeholder = "Setup Username"

        
    }
    
    
    func loadUsername(){
        if !ViewController.hasConnectivity(){
            return
        }
    self.ref?.child(uuid).observeSingleEvent(of: .value, with: { (snapshot) in
        self.username = (snapshot.childSnapshot(forPath: self.usernameKey).value as? String) ?? self.anonymous
        if self.username != self.anonymous {
        self.usernameInput.text = self.username
        }
    })
    }
    
    func saveUsernameToDatabase(){
        if !ViewController.hasConnectivity(){
            return
        }
       let input = self.usernameInput.text ?? self.anonymous
        if input.characters.count < 3 {
        self.ref?.child(uuid).child(usernameKey).setValue(self.anonymous)
        } else {
       self.ref?.child(uuid).child(usernameKey).setValue(input)
        }
    }
    
    func doneButtonTapped(){
        self.dismiss(animated: true) { 
            self.saveUsernameToDatabase()
            if let vc = self.presentingViewController {
                 (vc as! ViewController).setupTopPlayerScoreboard()

            }
        }
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if(text.characters.count < 3) {
                    floatingLabelTextField.errorMessage = "Username Too Short"
                    self.hideButton()
                }
                else if(text.characters.count > 10) {
                        floatingLabelTextField.errorMessage = "Username Too Long"
                        self.hideButton()
                    }
                else if(!text.isAlphanumeric) {
                    floatingLabelTextField.errorMessage = "Letters & Numbers Only"
                    self.hideButton()
                }
                else {
                    // The error message will only disappear when we reset it to nil or empty string
                    floatingLabelTextField.errorMessage = ""
                    floatingLabelTextField.selectedTitleColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                    self.unhideButton()
                    //enable button
                }
            }
        }
        return true
    }
    
    
    func hideButton(){
        UIView.animate(withDuration: 0.5) {
            self.doneButton.alpha = 0
        }
    }
    
    func unhideButton(){
        UIView.animate(withDuration: 0.5) {
            self.doneButton.alpha = 1
        }
    }
    
    func UUID() -> String {
        
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        let accountName = "incoding"
        
        var applicationUUID = SAMKeychain.password(forService: bundleName, account: accountName)
        
        if applicationUUID == nil {
            
            applicationUUID = UIDevice.current.identifierForVendor!.uuidString
            
            // Save applicationUUID in keychain without synchronization
            let query = SAMKeychainQuery()
            query.service = bundleName
            query.account = accountName
            query.password = applicationUUID
            query.synchronizationMode = SAMKeychainQuerySynchronizationMode.no
            
            do {
                try query.save()
            } catch let error as NSError {
                print("SAMKeychainQuery Exception: \(error)")
            }
        }
        
        return applicationUUID!
    }
    


    
    
    override var prefersStatusBarHidden: Bool {
        return self.hideStatusBar
    }

}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

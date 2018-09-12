//
//  LoginViewController.swift
//  Movie Time
//
//  Created by Ram Sri Charan on 4/5/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import FirebaseAuth



class LoginViewController: UIViewController {
    
    // My vars
    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        setupViews()
    }

    // Setting the status bar text color to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    

    
    // My Views on Login Page
    
    // Base imageview for background
    let backgroundImage : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image =  #imageLiteral(resourceName: "top movies")
        return view
    }()
    
    
    // Imageview for logo
    var appLogo : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = #imageLiteral(resourceName: "movieicon")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    // App Name label
    var appTitle : UILabel = {
        let view = UILabel()
        view.text = "Show Time"
        view.font = UIFont.boldSystemFont(ofSize: 50)
        view.textColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    
    // For username and password
    // Base container UIView
    var baseView : UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    
    // StackView to arrange all views in order
    var myStackView : UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.spacing = 8
        return v
    }()
    
    var usernameText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Username"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont.systemFont(ofSize: 25)
        return view
    }()
    
    let usernameDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var passwordText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Password"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont.systemFont(ofSize: 25)
        view.isSecureTextEntry = true
        return view
    }()
    
    // Login button
    let loginButton : UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Login", for: UIControlState.normal)
        view.backgroundColor = UIColor.red
        view.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return view
    }()
    

    
    // Label for New user
    let newUserPrompt : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.text = "New user? then create your new account"
        view.numberOfLines = 0
        view.textColor = UIColor.white
        return view
    }()
    
    // Register button
    let registerButton : UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleColor(UIColor.red, for: .normal)
        view.setTitle("Register", for: .normal)
        view.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return view
    }()
    
    @objc func handleRegister(){
        print("Register pressed")
        let registrationPage = RegisterViewController()
        present(registrationPage, animated : true, completion : nil)
    }

    
    
    
    func setupViews(){
        // Setting up background image
        view.addSubview(backgroundImage)
        backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
        
        // Baseview and its constraints
        view.addSubview(baseView)
        baseView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        baseView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        baseView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        baseView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        baseView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        // Add StackView to the baseView and set Constraints
        baseView.addSubview(myStackView)
        myStackView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        myStackView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
        myStackView.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 10).isActive = true
        myStackView.rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: -10).isActive = true
        
        // Adding all other views to the stackView
        myStackView.addArrangedSubview(usernameText)
        
        myStackView.addArrangedSubview(usernameDivider)
        usernameDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        myStackView.addArrangedSubview(passwordText)
        
        
        // Adding loggin button at the bottom of stackView
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        loginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        loginButton.topAnchor.constraint(equalTo: baseView.bottomAnchor, constant: 12).isActive = true
        
        // Create new account stuff
        view.addSubview(newUserPrompt)
        newUserPrompt.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newUserPrompt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        newUserPrompt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        newUserPrompt.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 48).isActive = true
        
        view.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: newUserPrompt.bottomAnchor).isActive = true
        
        
        // Adding title and app logo
        view.addSubview(appTitle)
        
        appTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appTitle.bottomAnchor.constraint(equalTo: baseView.topAnchor, constant: -40).isActive = true
        
        view.addSubview(appLogo)
        
        appLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appLogo.bottomAnchor.constraint(equalTo: appTitle.topAnchor, constant: -10).isActive = true
        appLogo.widthAnchor.constraint(equalToConstant: 100).isActive = true
        appLogo.heightAnchor.constraint(equalToConstant: 100).isActive = true

    }
    
    
    
    
    
    
    ///////////////////// Login button related functions /////////////////////
    
    @objc func handleLogin(){
        print("Login pressed")
        let loadingScreen = UIViewController.displaySpinner(onView: self.view, Message: "Loggin in")
        
        // Check for errors..
        if(!checkUserInput()){
            // Try to authenticate
            let email = usernameText.text!
            let password = passwordText.text!
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
                if(error != nil){
                    print(error ?? "error")
                    let errorMessage = error?.localizedDescription ?? "Seomething went wrong. Please try again."
                    self.showAlert(AlertTitle: "Failed to login", Message: errorMessage)
                    UIViewController.removeSpinner(spinner: loadingScreen)

                    return
                }
                else{
                    // Logged in successfully
                    UIViewController.removeSpinner(spinner: loadingScreen)
                    self.goToNextPage()
                }
            }
        }
        
        else{
            UIViewController.removeSpinner(spinner: loadingScreen)
        }
        
    }
    
    // Todo if successfully logged in
    func goToNextPage(){
        // Dismiss current page
        // Reload the master details page
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
//        window?.rootViewController = UINavigationController(rootViewController: MasterTableViewController())
        window?.rootViewController = CustomTabBarController()

    }
    
    // Checking for errors in user input..
    func checkUserInput() -> Bool{
        let username = usernameText.text!
        let password = passwordText.text!
        var isError = true
        var errorMessage = ""
        
        // Check if user inputs are null
        if username.isEmpty || password.isEmpty {
            isError = true
            errorMessage = "Username and Password cannot be empty"
            
            print("username or password is empty")
        }
            // Check if username is valid
        else if !username.contains("@st.com"){
            isError = true
            errorMessage = "Username must be a valid email ID. Make sure it contains @st.com suffix"
        }
            
            // If no errors
        else{
            isError = false
            print("No error..")
        }
        
        // If there are errors
        if(isError){
            self.showAlert(AlertTitle: "Input Error", Message: errorMessage)
        }
        
        return isError
    }
    
    
    
    // Helper method to show alert messages
    func showAlert(AlertTitle: String, Message : String){
        let alert = UIAlertController(title: AlertTitle, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    ///////////////////////////////////////////////////

    
    
    
    
    


}

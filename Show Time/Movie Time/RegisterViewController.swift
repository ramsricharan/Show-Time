//
//  RegisterViewController.swift
//  Show time
//
//  Created by Ram Sri Charan on 4/7/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase




class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        setupViews()
    }
    
    // Setting the status bar text color to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    

    
    
    // My Views on Registration Page
    
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
    
    // Create Account Label
    let createNewAccLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textAlignment = .center
        label.text = "Welcome,\n Enter following details to create a new account"
        label.textColor = UIColor.white
        return label
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
    
    // Register button
    let registerButton : UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Register", for: UIControlState.normal)
        view.backgroundColor = UIColor.red
        view.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return view
    }()
    
    @objc func handleRegister(){
        print("Register pressed")
        if(!checkUserInput()){
            // No errors found in the user input
            registerUser()
        }
    }
    
    // Back to login button
    let backToLoginButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("< Back to Login", for: UIControlState.normal)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        return button
    }()
    
    
    @objc func handleBackButton(){
        
        print("Back to login pressed")
        self.dismiss(animated: true, completion: nil)

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
        baseView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60).isActive = true
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
        view.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        registerButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        registerButton.topAnchor.constraint(equalTo: baseView.bottomAnchor, constant: 12).isActive = true
        
        // Adding the back to login button
        view.addSubview(backToLoginButton)
        backToLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backToLoginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        backToLoginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        backToLoginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 12).isActive = true
        

        
        // Adding create new account prompt
        view.addSubview(createNewAccLabel)
        createNewAccLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createNewAccLabel.bottomAnchor.constraint(equalTo: baseView.topAnchor, constant: -12).isActive = true
        createNewAccLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        createNewAccLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        
        
        
        // Adding title and app logo
        view.addSubview(appTitle)
        
        appTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appTitle.bottomAnchor.constraint(equalTo: createNewAccLabel.topAnchor, constant: -28).isActive = true
        
        view.addSubview(appLogo)
        
        appLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appLogo.bottomAnchor.constraint(equalTo: appTitle.topAnchor, constant: -10).isActive = true
        appLogo.widthAnchor.constraint(equalToConstant: 100).isActive = true
        appLogo.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    
    
    
    
    
    // All my helper methods
    
    
    // Checking for the errors in the user input.
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
        
        // If there are errors.. Show error alert
        if(isError){
            self.showAlert(AlertTitle: "Input Error", Message: errorMessage)
        }
        
        return isError
    }
    
    
    
    
    // Create new account in Firebase and add user to the database
    func registerUser(){
        let email = usernameText.text!
        let password = passwordText.text!
        let loadingScreen = UIViewController.displaySpinner(onView: self.view, Message: "Registering User")

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            // Some error occured
            if(error != nil){
                print(error ?? "error")
                let errorMessage = error?.localizedDescription ?? "Seomething went wrong. Please try again."
                UIViewController.removeSpinner(spinner: loadingScreen)
                self.showAlert(AlertTitle: "Registration Failed", Message: errorMessage)
            }
            
            // New user created
            else{

                let userID = user?.uid
                let userDetails = [ "user_name" : "",
                                    "phone_no" : "",
                                    "company_name" : "",
                                    "picture_path" : "",
                                    "about_me" : ""]
                var ref : DatabaseReference!
                ref = Database.database().reference()
                
                ref.child("users").child(userID!).setValue(userDetails, withCompletionBlock: {
                    (error, ref) in
                    print("user database created!")
                    
                    UIViewController.removeSpinner(spinner: loadingScreen)
                    self.goToProfilPage()
                })
            }

        }
    }
    
    
    
    
    
    // On sucessfully registring the account.. Go to profile page
    func goToProfilPage(){
        let myProfile : MyProfileViewController = MyProfileViewController()
        myProfile.entryType = "registration"
        present(myProfile, animated : true, completion : nil)
        
    }
    
    
    // Helper method to show alert messages
    func showAlert(AlertTitle: String, Message : String){
        let alert = UIAlertController(title: AlertTitle, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}

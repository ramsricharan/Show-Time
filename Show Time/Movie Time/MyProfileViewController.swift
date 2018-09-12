//
//  MyProfileViewController.swift
//  Show time
//
//  Created by Ram Sri Charan on 4/7/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase

class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // My variables
    var window: UIWindow?
    var imagePicker = UIImagePickerController()
    var entryType = ""

    var currentUserId = ""
    var UserName, PhoneNumber, CompanyName, AboutMe, ProfilePath : String?
    
    
    
    
    
    
    
    
    
    
    //////////////////////////////  My Functions ////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        view.backgroundColor = UIColor.black
        setupViews()
        
        currentUserId = (Auth.auth().currentUser?.uid)!
        
        fetchDataFromDB()
        

    }


    /////////////////////////////////// All my Views ///////////////////////////////////
    // My profile label
    let myProfileLabel : UILabel = {
        let label = UILabel()
        label.text = "My Profile"
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    // Profile imageview
    lazy var profileImageView : UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "blank_profile")
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileTapped))
        image.addGestureRecognizer(tap)
        image.isUserInteractionEnabled = true
        
        return image
    }()
    
    
    @objc func handleProfileTapped(){
        print("Profile image clicked")
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    
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
    
    // User name textfield and divider
    var usernameText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Name"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont.systemFont(ofSize: 20)
        return view
    }()
    
    let usernameDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Company name text field and divider
    var companyNameText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Company Name"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont.systemFont(ofSize: 20)
        return view
    }()
    
    let companyNameDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // Phone number text field and divider
    var phoneNumberText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Phone Number"
        view.keyboardType = .numberPad
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont.systemFont(ofSize: 20)
        return view
    }()
    
    let phoneNumberDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    // About me text view
    var aboutMeText : UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "About me"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont.systemFont(ofSize: 20)
        return view
    }()

    
    
    // Login button
    let saveButton : UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Save", for: UIControlState.normal)
        view.backgroundColor = UIColor.red
        view.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return view
    }()
    
    @objc func handleSave(){
        print("Save pressed")
        if(usernameText.text?.isEmpty)!{
            let alert = UIAlertController(title: "Unable to save", message: "User's name cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
        saveDetailsToDB()
        }
    }
    
    
    
    // Sets all the views on this controller
    func setupViews(){
        // Adding the heading
        view.addSubview(myProfileLabel)
        myProfileLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        myProfileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Adding the profile imageview
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: myProfileLabel.bottomAnchor, constant: 12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        
        // Adding the baseView
        view.addSubview(baseView)
        baseView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        baseView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        baseView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        baseView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        
        
        // Adding stackView to the baseView
        baseView.addSubview(myStackView)
        myStackView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        myStackView.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 8).isActive = true
        myStackView.rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: -8).isActive = true
        myStackView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 8).isActive = true
        myStackView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -8).isActive = true
        
        // Adding all textFields into the StackView
        myStackView.addArrangedSubview(usernameText)
        myStackView.addArrangedSubview(usernameDivider)
        usernameDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        myStackView.addArrangedSubview(companyNameText)
        myStackView.addArrangedSubview(companyNameDivider)
        companyNameDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        myStackView.addArrangedSubview(phoneNumberText)
        myStackView.addArrangedSubview(phoneNumberDivider)
        phoneNumberDivider.heightAnchor.constraint(equalToConstant: 1).isActive  = true
        
        myStackView.addArrangedSubview(aboutMeText)
        
        
        // Adding the save button
        view.addSubview(saveButton)
        saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        saveButton.topAnchor.constraint(equalTo: baseView.bottomAnchor, constant: 12).isActive = true
        
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    ///////////////////////////////////  All My Helper methods ///////////////////////////////////
    
    // Gets the data of current user from the Firebase
    func fetchDataFromDB(){
        let ref : DatabaseReference = Database.database().reference()
        
        ref.child("users").child(currentUserId).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            self.UserName = value?["user_name"] as? String ?? ""
            self.PhoneNumber = value?["phone_no"] as? String ?? ""
            self.CompanyName = value?["company_name"] as? String ?? ""
            self.AboutMe = value?["about_me"] as? String ?? ""
            self.ProfilePath = value?["picture_path"] as? String ?? ""
            
            self.setDataIntoViews()
        })
        
    }
    
    
    // Sets the data into the Views
    func setDataIntoViews(){
        
        // Set data only if available
        if(UserName != ""){
            usernameText.text = UserName
        }
        if(PhoneNumber != ""){
            phoneNumberText.text = PhoneNumber
        }
        if(CompanyName != ""){
            companyNameText.text = CompanyName
        }
        if(AboutMe != ""){
            aboutMeText.text = AboutMe
        }
        
        if(ProfilePath != ""){
            let profile_url = URL(string : ProfilePath!)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: profile_url!)
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: data!)
                }
            }
        }
        
        
    }
    
    
    // Save data to the database
    func saveDetailsToDB(){
        let loadingScreen = UIViewController.displaySpinner(onView: self.view, Message: "Saving Profile")
        
        let ref : DatabaseReference = Database.database().reference().child("users").child(currentUserId)
        let newUserName = usernameText.text ?? ""
        let newPhoneNumber = phoneNumberText.text ?? ""
        let newCompanyName = companyNameText.text ?? ""
        let newAboutMe = aboutMeText.text ?? ""
        let profileImageName = currentUserId + ".jpg"
        
        // Upload to database only if values changed
        if(newUserName != UserName){
            ref.child("user_name").setValue(newUserName)
        }
        if(newPhoneNumber != PhoneNumber){
            ref.child("phone_no").setValue(newPhoneNumber)
        }
        if(newCompanyName != CompanyName){
            ref.child("company_name").setValue(newCompanyName)
        }
        if(newAboutMe != AboutMe){
            ref.child("about_me").setValue(newAboutMe)
        }
        
        // Check if new image is uploaded
        if(profileImageView.image == #imageLiteral(resourceName: "blank_profile"))
        {
            print("No new image uploaded")
            
            let defaultImageURL = "https://firebasestorage.googleapis.com/v0/b/ios-assignment-4.appspot.com/o/profile_images%2Fblank_profile.jpg?alt=media&token=9a74f5e0-0c42-43c3-bb74-e6f8a0c4645f"
            
            ref.child("picture_path").setValue(defaultImageURL)
            
            UIViewController.removeSpinner(spinner: loadingScreen)
            self.goToHomePage()
        }
        
        // New image is selected.. Need to upload it
        else{
            // Now upload the profile image
            let storageRef : StorageReference = Storage.storage().reference().child("profile_images").child(profileImageName)
            
            if let uploadImage = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
                storageRef.putData(uploadImage, metadata: nil, completion: {(metadata, error) in
                    if(error != nil){
                        print(error!)
                        return
                    }

                    if let imageURL = metadata?.downloadURL()?.absoluteString {
                        ref.child("picture_path").setValue(imageURL)
                        // After Saving go to home
                        self.goToHomePage()
                    }
                })
            }
        }
    }
    
    
    // Go to home page after saving changes
    func goToHomePage(){
        // Dismiss current page
        if entryType == "edit"{
            self.dismiss(animated: true, completion: nil)
        }
        // Reload the master details page
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
//        window?.rootViewController = UINavigationController(rootViewController: MasterTableViewController())
        window?.rootViewController = CustomTabBarController()

    }
    
    // On Cancelling the image upload
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image upload cancelled")
        dismiss(animated: true, completion: nil)
    }
    // Image picker functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Got the image")
        dismiss(animated: true, completion: nil)
        
        var selectedImageFromPicker : UIImage?
        
        // Check if image is edited
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print("Got edited image")
            selectedImageFromPicker = editedImage
        }
          
        // If not take the original image
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            print("Got original image")
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }


    }

}

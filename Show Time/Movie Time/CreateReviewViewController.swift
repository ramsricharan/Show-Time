//
//  CreateReviewViewController.swift
//  Show time
//
//  Created by Ram Sri Charan on 4/9/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase

class CreateReviewViewController: UIViewController {
    
    // My variables
    var currentMovieId = ""
    var currentUserId = ""
    var currentUserName = ""
    
    var entryType = ""
    var currentReviewTitle = ""
    var currentReviewContent = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        setupViews()
        
        if entryType.contains("edit"){
            // This is editing review.. So show existing data
            reviewTitleTextField.text = currentReviewTitle
            reviewContentTextField.text = currentReviewContent
        }
    }
    
    
    
    
    
    // All my Views
    
    // Base stackView
    let baseStackView : UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.spacing = 8
        return v

    }()
    
    // Heading label
    let titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Write your review"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    // Vertical stackView to hold all my views
    let reviewTitleStackView : UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.spacing = 2
        return v
    }()
    
    // baseView for text fields
    var reviewTitleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    // Review Title label
    let reviewTitleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Review Headline: *"
        label.font = UIFont.boldSystemFont(ofSize: 10)
        return label
    }()
    
    // Review title textfield
    var reviewTitleTextField : UITextField = {
        let textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.white
        return textView
    }()
    
    // Divider line
    let reviewTitleDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    // All content text field views
    let reviewContentStackView : UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.spacing = 2
        return v
    }()
    
    // baseView for text fields
    var reviewContentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    // Review Content label
    let reviewContentLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Review Description: *"
        label.font = UIFont.boldSystemFont(ofSize: 10)
        return label
    }()
    
    // Review content Text Field
    var reviewContentTextField : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    
    // Submit button
    var submitButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Submit Review", for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
  
    
    @objc func handleSubmit(){
        if checkUserInput(){
            uploadReviewToDB()
        }
    }
    
    
    // Arranging views into the viewcontroller
    func setupViews(){
        // Prepare base Stackview which holds all the other views
        view.addSubview(baseStackView)
        baseStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        baseStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        baseStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        
        // Adding Page title view
        baseStackView.addArrangedSubview(titleLabel)
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Adding Review Title Text Field and related views
        baseStackView.addArrangedSubview(reviewTitleView)
        reviewTitleView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        reviewTitleView.addSubview(reviewTitleStackView)
        reviewTitleStackView.centerXAnchor.constraint(equalTo: reviewTitleView.centerXAnchor).isActive = true
        reviewTitleStackView.centerYAnchor.constraint(equalTo: reviewTitleView.centerYAnchor).isActive = true
        reviewTitleStackView.leftAnchor.constraint(equalTo: reviewTitleView.leftAnchor, constant: 10).isActive = true
        reviewTitleStackView.rightAnchor.constraint(equalTo: reviewTitleView.rightAnchor, constant: -10).isActive = true

        reviewTitleStackView.addArrangedSubview(reviewTitleLabel)
        reviewTitleStackView.addArrangedSubview(reviewTitleTextField)


        
        // Adding Review content Text View and related views
        baseStackView.addArrangedSubview(reviewContentView)
        reviewContentView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        reviewContentView.addSubview(reviewContentStackView)
        reviewContentStackView.centerXAnchor.constraint(equalTo: reviewContentView.centerXAnchor).isActive = true
        reviewContentStackView.centerYAnchor.constraint(equalTo: reviewContentView.centerYAnchor).isActive = true
        reviewContentStackView.leftAnchor.constraint(equalTo: reviewContentView.leftAnchor, constant: 10).isActive = true
        reviewContentStackView.rightAnchor.constraint(equalTo: reviewContentView.rightAnchor, constant: -10).isActive = true
        
        reviewContentStackView.addArrangedSubview(reviewContentLabel)
        reviewContentStackView.addArrangedSubview(reviewContentTextField)
        reviewContentTextField.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        // Adding submit button
        baseStackView.addArrangedSubview(submitButton)

    }
    
    
    // Check for user input errors
    func checkUserInput() -> Bool{
        // Check if Review heading is empty
        if (reviewTitleTextField.text?.isEmpty)!{
            showAlert(AlertTitle: "Failed to create", Message: "Review title cannot be empty.")
            return false
        }
        
        // Check if Review Content is empty
        else if reviewContentTextField.text.isEmpty{
            showAlert(AlertTitle: "Failed to create", Message: "Review content cannot be empty.")
            return false
        }
            
        // if no errors
        else{
            return true
        }
        
    }
    
    // Upload Review to the Firebase
    func uploadReviewToDB(){
        let reviewTitle = reviewTitleTextField.text!
        let reviewContent = reviewContentTextField.text!
        let likes = ["default" : "default"]
        let dislikes = ["default" : "default"]
        
        let ref : DatabaseReference = Database.database().reference()
        let reviewRef : DatabaseReference = ref.child("reviews").child(currentMovieId).child(currentUserId)
        
        reviewRef.child("owner_name").setValue(currentUserName)
        reviewRef.child("review_title").setValue(reviewTitle)
        reviewRef.child("review_content").setValue(reviewContent)
        
        if entryType.contains("new"){
        reviewRef.child("likes").setValue(likes)
            reviewRef.child("dislikes").setValue(dislikes, withCompletionBlock: {
                (error, reviewRef) in
                print("New Review created!")
            })
        }
        
        self.goBackToMovieDetails()

    }
    
    
    func goBackToMovieDetails(){
        navigationController?.popViewController(animated: true)
    }
    
    
    // Helper method to show alert messages
    func showAlert(AlertTitle: String, Message : String){
        let alert = UIAlertController(title: AlertTitle, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    

}

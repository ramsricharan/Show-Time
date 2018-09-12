//
//  DetailsViewController.swift
//  Movie Time
//
//  Created by Ram Sri Charan on 3/18/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase

class DetailsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource  {

    // All my Local variables
    var receivedMovieID = 0
    var CurrentUserID = ""
    var CurrentUserName = ""
    
    var CurrentMovie = MovieObject()
    var AllReviewsList = [ReviewObject]()
    
    // first and second half of the get request URL
    let getMovieURL = "https://api.themoviedb.org/3/movie/"
    let myAPIkey = "?api_key=606a18ba03513c0c982f6120e7d4b305"
    


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        getMovieDetailsFromURL()
        setupViews()
    }
    
    
    // To load/reload reviews list
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("View appeared")
        print("Reloading tableview")
        getReviewsFromFirebase()
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////  Data fetching functions //////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////

    // This function fetches data from the TMDB website
    func getMovieDetailsFromURL() {
        let fullURL = getMovieURL + String(receivedMovieID) + myAPIkey
        
        guard let url = URL(string : fullURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else {return}
            do{
                let jsonResponse = try JSONDecoder().decode(MovieObject.self, from: data)
                self.CurrentMovie = jsonResponse
                
                DispatchQueue.main.async{
                    self.populateViews()
                }
            }
            catch{
                print("JSON decoding failed!!")
            }
            }.resume()
    }
    
    
    // This function gets the reviews for the current movie from the Firebase
    func getReviewsFromFirebase(){
        AllReviewsList.removeAll()
        let currentMovieId = String (receivedMovieID)
        let ref : DatabaseReference = Database.database().reference()
        //let reviewsRef : DatabaseReference = ref.child("reviews").child(currentMovieId)
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // Get review Snapshot
            let reviewSnapshot : DataSnapshot = snapshot.childSnapshot(forPath: "reviews").childSnapshot(forPath: currentMovieId)
            
            // Check if reviews exists
            if(reviewSnapshot.childrenCount >= 1){

                let enumerator = reviewSnapshot.children
                while let currentReview = enumerator.nextObject() as? DataSnapshot {
                    let value = currentReview.value as? NSDictionary
                    
                    var tempReviewObject = ReviewObject()
                    tempReviewObject.ownerID = currentReview.key
                    
                    tempReviewObject.ownerName = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: tempReviewObject.ownerID!).childSnapshot(forPath: "user_name").value as? String
                    
                    tempReviewObject.reviewTitle = value?["review_title"] as? String ?? ""
                    tempReviewObject.reviewContent = value?["review_content"] as? String ?? ""
                    
                    let likescount = Int (currentReview.childSnapshot(forPath: "likes").childrenCount) - 1
                    let dislikesCount =  Int (currentReview.childSnapshot(forPath: "dislikes").childrenCount) - 1
                    
                    tempReviewObject.likeCount = String (likescount)
                    tempReviewObject.dislikeCount = String (dislikesCount)

                    self.AllReviewsList.append(tempReviewObject)
                }
                self.reviewsTableView.reloadData()
            }
        })
        
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////  Collection View and TableView helper methods //////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    //////////////////////////////  Collection View   //////////////////////////////
    // Fuction related to Collection View holding Movie posters
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    // Setting up images into collectionview
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! posterImageCell
    
        var imagePath = ""
        
        if(indexPath.row % 2) == 0 {
            imagePath = CurrentMovie.poster_path!
        }
        else{
            imagePath = CurrentMovie.backdrop_path!
        }
        
        let posterPath_str = "http://image.tmdb.org/t/p/w154\(imagePath)"
        let poster_url = URL(string : posterPath_str)
        
        // Downloading Image from web
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: poster_url!)
            DispatchQueue.main.async {
                if(data == nil)
                {
                    cell.posterImages.image = #imageLiteral(resourceName: "blankPoster")
                }
                else{
                cell.posterImages.image = UIImage(data: data!) ?? #imageLiteral(resourceName: "blankPoster")
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width : 240, height:180)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 14, 0, 14)
    }

    
    //////////////////////////////   Table View Methods  //////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllReviewsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyCell =  tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! customTableViewCell
        
        let review : ReviewObject = AllReviewsList[indexPath.row]
        // Setting values to the cells
        MyCell.reviewTitle.text = review.reviewTitle
        MyCell.reviewOwner.text = "  By: " + review.ownerName!
        MyCell.reviewContent.text = review.reviewContent
        MyCell.likeCountLabel.text = review.likeCount
        MyCell.dislikeCountLabel.text = review.dislikeCount
        
        
        // Like button
        MyCell.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)

        // Dislike button
        MyCell.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        
        
        return MyCell
    }
    
    // Handling like button pressed event
    @objc func handleLike(sender : UIButton){
        let cell = sender.superview?.superview?.superview?.superview as! customTableViewCell
        let indexPath = reviewsTableView.indexPath(for: cell)
        let review : ReviewObject = AllReviewsList[indexPath!.row]

        let currentMovieId = String (receivedMovieID)
        let ref : DatabaseReference = Database.database().reference()
        let LikesRef : DatabaseReference = ref.child("reviews").child(currentMovieId).child(review.ownerID!).child("likes")
        

        // Check if user liked this post or not
        LikesRef.observeSingleEvent(of: .value, with: {(snapshot) in
        
                // If user did not already like the post
                if !snapshot.hasChild(self.CurrentUserID){
                
                    LikesRef.child(self.CurrentUserID).setValue("0", withCompletionBlock: {
                            (error, LikesRef) in
                            if error == nil{
                                let currentLikes = Int (cell.likeCountLabel.text!)! + 1
                                cell.likeCountLabel.text = String (currentLikes)
                            }
                        })
                }
            
                // User already liked the post..
                else{
                    self.showAlert(AlertTitle: "Cannot like again", Message: "You have already liked this post.")
                }
            
            })
        
    }
    
    
    // Handling dislike button pressed event
    @objc func handleDislike(sender : UIButton){
        let cell = sender.superview?.superview?.superview?.superview as! customTableViewCell
        let indexPath = reviewsTableView.indexPath(for: cell)
        let review : ReviewObject = AllReviewsList[indexPath!.row]
        
        let currentMovieId = String (receivedMovieID)
        let ref : DatabaseReference = Database.database().reference()
        let DislikesRef : DatabaseReference = ref.child("reviews").child(currentMovieId).child(review.ownerID!).child("dislikes")
        
        
        // Check if user liked this post or not
        DislikesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // If user did not already like the post
            if !snapshot.hasChild(self.CurrentUserID){
                
                DislikesRef.child(self.CurrentUserID).setValue("0", withCompletionBlock: {
                    (error, DislikesRef) in
                    if error == nil{
                        let currentDislikes = Int (cell.dislikeCountLabel.text!)! + 1
                        cell.dislikeCountLabel.text = String (currentDislikes)
                    }
                })
            }
                
                // User already liked the post..
            else{
                self.showAlert(AlertTitle: "Cannot dislike again", Message: "You have already disliked this post.")
            }
            
        })
        
    }
    
    
    
    
    
    // Swipe to delete review functionality (allows only owner to delete)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteMovie = UITableViewRowAction(style: .destructive, title: "Delete Review") { (ACTION, indexPath) in
            
            let CurReviewOwnerId = self.AllReviewsList[indexPath.row].ownerID
            
            if self.CurrentUserID.elementsEqual(CurReviewOwnerId!){
                // Yes owner itself is trying to delete the review
                let currentMovieId = String (self.receivedMovieID)
                let ref : DatabaseReference = Database.database().reference()
                ref.child("reviews").child(currentMovieId).child(CurReviewOwnerId!).removeValue {
                    error, ref in
                    if(error == nil){
                        self.AllReviewsList.remove(at: indexPath.row)
                        self.reviewsTableView.reloadData()
                    }
                }
            }
                
            else{
                // No, the user is not the author for this review
                self.showAlert(AlertTitle: "Failed to Delete!", Message: "Only the author of this review can delete this review.")
            }
        }
        return [deleteMovie]
    }
    
    
    // On click event handler.. Takes the user to editing review screen (Only Author can edit)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let CurReviewOwnerId = self.AllReviewsList[indexPath.row].ownerID
        
        if self.CurrentUserID.elementsEqual(CurReviewOwnerId!){
            // Yes owner itself is trying to delete the review
            let editReview : CreateReviewViewController = CreateReviewViewController()
            editReview.currentMovieId = String (receivedMovieID)
            editReview.currentUserId = CurrentUserID
            editReview.currentUserName = CurrentUserName
            
            editReview.entryType = "edit"
            editReview.currentReviewTitle = AllReviewsList[indexPath.row].reviewTitle!
            editReview.currentReviewContent = AllReviewsList[indexPath.row].reviewContent!
            self.navigationController?.pushViewController(editReview, animated: true)
        }
        
        else{
            // No, the user is not the author for this review
            self.showAlert(AlertTitle: "Failed to Edit!", Message: "Only the author of this review can edit this review.")
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////// Everything regarding my Views on this UI ViewController /////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // All of my View objects
    
    // Scroll View
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Vertical stackView to hold all my views
    let stackView : UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.spacing = 8
        return v
    }()
    
    // Divider line to divide sections
    let dividerLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.white
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    // Movie Title label
    var MovieLabel : UILabel = {
        let label = UILabel()
        label.text = "No Name"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Movie Rating views
    var MovieRating : CosmosView = {
        let rating = CosmosView()
        rating.updateOnTouch = false
        rating.textColor = UIColor.white
        rating.translatesAutoresizingMaskIntoConstraints = false
        rating.totalStars = 10
        rating.settings.fillMode = .precise
        return rating
    }()
    
    // Movie Posters collection view
    var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout : layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    
    ///////////////////// About Movie Heading /////////////////////
    let AboutMovieHeading : UILabel = {
        let label = UILabel()
        label.text = "Details"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // Movie Genre label
    var MovieGenre : UILabel = {
        let l = UILabel()
        l.text = "No Genre"
        l.textColor = UIColor.white
        l.adjustsFontSizeToFitWidth = true
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // Movie Release Date Label
    var MovieReleaseDate : UILabel = {
        let label = UILabel()
        label.text = "No Release Date"
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Movie Duration label
    var MovieDuration : UILabel = {
        let l = UILabel()
        l.text = "Not available"
        l.textColor = UIColor.white
        l.adjustsFontSizeToFitWidth = true
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    
    
    ///////////////////// Movie Description Heading /////////////////////
    let MovieOverViewHeading : UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // Movie Description Label
    var MovieOverview : UILabel = {
        let label = UILabel()
        label.text = "No Overview"
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    ///////////////////// Reviews section /////////////////////

    // Divider line to divide sections
    let reviewsDivider : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.white
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let reviewsHeading : UILabel = {
        let label = UILabel()
        label.text = "Reviews"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let reviewCreateButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Write a review >", for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleCreateReview), for: .touchUpInside)
        return button
    }() 
    
    @objc func handleCreateReview(){
        let createReview : CreateReviewViewController = CreateReviewViewController()
        createReview.currentMovieId = String (receivedMovieID)
        createReview.currentUserId = CurrentUserID
        createReview.currentUserName = CurrentUserName
        createReview.entryType = "new"
        self.navigationController?.pushViewController(createReview, animated: true)
    }
    
    var reviewsTableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    

    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////  All My Custom cell setups   ////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////   Custom cell of my Collection View   ////////////////////
    
    class posterImageCell : UICollectionViewCell{
        
        let posterImages : UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            return image
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(posterImages)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[v0]-2-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : posterImages]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[v0]-2-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : posterImages]))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    
    ///////////////////// My Custom Table View cell ////////////////////
    
    class customTableViewCell : UITableViewCell {
        
        // All customCell views
        
        // Base View
        let cellBaseView : UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.darkGray
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
            return view
        }()
        
        
        // My StackView
        let myStackView : UIStackView = {
            let stack = UIStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .vertical
            stack.spacing = 3
            return stack
        }()
        
        
        // Review Title
        var reviewTitle : UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = UIColor.white
            label.adjustsFontSizeToFitWidth = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        // Username label
        var reviewOwner : UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = UIColor.white
            label.adjustsFontSizeToFitWidth = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        // Divider
        let reviewTitleDivider : UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        
        // Review content label
        var reviewContent : UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 18)
            label.textColor = UIColor.white
            label.adjustsFontSizeToFitWidth = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        
        // Like and dislike UI
        
        // BaseFrame
        var likeBaseView : UIView = {
            let view =  UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
//            view.backgroundColor = UIColor.black
            return view
        }()
        
        // Central dividing line
        let verticalDivider : UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        // Like button
        var likeButton : UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setBackgroundImage(#imageLiteral(resourceName: "like button"), for: .normal)
            button.contentMode = .scaleToFill
            return button
        }()
        
        // Like count label
        var likeCountLabel : UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.green
            label.text = "20"
            return label
        }()

        // dislike button
        var dislikeButton : UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setBackgroundImage(#imageLiteral(resourceName: "dislike"), for: .normal)
            button.contentMode = .scaleToFill
            return button
        }()
        
        // Like count label
        var dislikeCountLabel : UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.red
            label.text = "80"
            return label
        }()
        
        
        
        // Adding and setting constraints
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor.black
            
            // Adding subview
            addSubview(cellBaseView)
            cellBaseView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            cellBaseView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            cellBaseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
            cellBaseView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
            cellBaseView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
            
            // Adding stackView to the baseView
            cellBaseView.addSubview(myStackView)
            myStackView.centerXAnchor.constraint(equalTo: cellBaseView.centerXAnchor).isActive = true
            myStackView.leftAnchor.constraint(equalTo: cellBaseView.leftAnchor, constant: 8).isActive = true
            myStackView.rightAnchor.constraint(equalTo: cellBaseView.rightAnchor, constant: -8).isActive = true
            myStackView.topAnchor.constraint(equalTo: cellBaseView.topAnchor, constant: 8).isActive = true
            myStackView.bottomAnchor.constraint(equalTo: cellBaseView.bottomAnchor, constant: -8).isActive = true
            
            
            // Adding subview to the stackView
            myStackView.addArrangedSubview(reviewTitle)
            myStackView.addArrangedSubview(reviewOwner)
            
            myStackView.addArrangedSubview(reviewTitleDivider)
            reviewTitleDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            reviewTitleDivider.leftAnchor.constraint(equalTo: myStackView.leftAnchor, constant: 5).isActive = true
            reviewTitleDivider.rightAnchor.constraint(equalTo: myStackView.rightAnchor, constant: -5).isActive = true
            
            myStackView.addArrangedSubview(reviewContent)
            
            // Adding the base Like/Dislike view
            myStackView.addArrangedSubview(likeBaseView)
            likeBaseView.centerXAnchor.constraint(equalTo: myStackView.centerXAnchor).isActive = true
            likeBaseView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            // Arranging the like and dislike button inside the view
            likeBaseView.addSubview(verticalDivider)
            verticalDivider.centerXAnchor.constraint(equalTo: likeBaseView.centerXAnchor).isActive = true
            verticalDivider.widthAnchor.constraint(equalToConstant: 1).isActive = true
            verticalDivider.topAnchor.constraint(equalTo: likeBaseView.topAnchor, constant: 2).isActive = true
            verticalDivider.bottomAnchor.constraint(equalTo: likeBaseView.bottomAnchor, constant: -2).isActive = true
            
                // Like button side
                likeBaseView.addSubview(likeButton)
                likeButton.centerYAnchor.constraint(equalTo: likeBaseView.centerYAnchor).isActive = true
                likeButton.rightAnchor.constraint(equalTo: verticalDivider.leftAnchor, constant: -8).isActive = true
                likeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
                likeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
                likeBaseView.addSubview(likeCountLabel)
                likeCountLabel.centerYAnchor.constraint(equalTo: likeBaseView.centerYAnchor).isActive = true
                likeCountLabel.rightAnchor.constraint(equalTo: likeButton.leftAnchor, constant: -8).isActive = true
                likeCountLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

            
                // Dislike button side
            likeBaseView.addSubview(dislikeButton)
            dislikeButton.centerYAnchor.constraint(equalTo: likeBaseView.centerYAnchor).isActive = true
            dislikeButton.leftAnchor.constraint(equalTo: verticalDivider.rightAnchor, constant: 8).isActive = true
            dislikeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            dislikeButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
            
            likeBaseView.addSubview(dislikeCountLabel)
            dislikeCountLabel.centerYAnchor.constraint(equalTo: likeBaseView.centerYAnchor).isActive = true
            dislikeCountLabel.leftAnchor.constraint(equalTo: dislikeButton.rightAnchor, constant: 8).isActive = true
            dislikeCountLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
    
    ///////////////////////////////// End of UI View declarations and related classes //////////////////////////////

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////  Display and setup in the actual VIEW CONTROLLER      ////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Once the movie data is downloaded , this function populates all the UIVIew with respective data.
    func populateViews(){
        
        // Movie Title
        MovieLabel.text = CurrentMovie.original_title
        
        // Rating
        let Rating_Double = CurrentMovie.vote_average ?? 0.0
        MovieRating.rating = Rating_Double
        MovieRating.text = "\(Rating_Double)/10"
       
        // Reloading collection View to download Poster and backdrop images into the custom cells
        collectionView.reloadData()
        
        
        // Release Date
        let unwrapRD = CurrentMovie.release_date ?? "No Release Date"
        MovieReleaseDate.text = "Release Date: \(unwrapRD)"
        
        // Movie Duration
        let unwrapDur = CurrentMovie.runtime ?? 0
        var Duration = ""
        if unwrapDur == 0{
            Duration = "Not available"
        }
        else{
            Duration = String(unwrapDur)
        }
        MovieDuration.text = "Duration: \(Duration) mins"
        
        // Setting up Genre
        var GenreString = ""
        for Genre in CurrentMovie.genres!{
            GenreString += Genre.name! + ", "
        }
        
        GenreString = String(GenreString.dropLast().dropLast())
        MovieGenre.text = "Genres: \(GenreString)"
        
        
        // Setting Movie Description
        MovieOverview.text = CurrentMovie.overview
        
    }
    
    
    // Responsible for setting up views and required constraints.
    func setupViews(){
        
        // Get the width of the screen
        let screensize: CGRect = UIScreen.main.bounds
        let width = screensize.width - 20
        
        
        // Scroll View
        // First add scrollView to the root View
        view.addSubview(scrollView)
        
        // ScrollView constraints
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true

        
        
        // Next add stackView to the scrollView
        scrollView.addSubview(stackView)
        
        // StackView Constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalToConstant: width)
            ])
        
        

        // Setup Collection VIew
        collectionView.register(posterImageCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        
        // Fix height of the COllection View
        collectionView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true

        
        
        // Adding all other views to stack
        // First Section
        stackView.addArrangedSubview(MovieLabel)
        
        stackView.addArrangedSubview(MovieRating)
        MovieRating.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -8.0).isActive = true

        stackView.addArrangedSubview(collectionView)
        
        
        // Second Section (Details)
        stackView.addArrangedSubview(AboutMovieHeading)
        stackView.addArrangedSubview(MovieGenre)
        stackView.addArrangedSubview(MovieReleaseDate)
        stackView.addArrangedSubview(MovieDuration)
        
        stackView.addArrangedSubview(dividerLine)

        // Divider line constraints
        dividerLine.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 2.0).isActive = true
        dividerLine.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 2.0).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        // Third Section (Description)
        stackView.addArrangedSubview(MovieOverViewHeading)
        stackView.addArrangedSubview(MovieOverview)
        
        
        
        
        // Fourth section (Reviews)
        
        // Setup Table VIew
        reviewsTableView.register(customTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
        reviewsTableView.rowHeight = UITableViewAutomaticDimension
        reviewsTableView.estimatedRowHeight = 600.0
        reviewsTableView.backgroundColor = UIColor.black
        
        
        
        stackView.addArrangedSubview(reviewsDivider)
        reviewsDivider.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 2.0).isActive = true
        reviewsDivider.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 2.0).isActive = true
        reviewsDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true

        stackView.addArrangedSubview(reviewsHeading)
        stackView.addArrangedSubview(reviewCreateButton)

        stackView.addArrangedSubview(reviewsTableView)
        reviewsTableView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        reviewsTableView.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
        reviewsTableView.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
        reviewsTableView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
        reviewsTableView.reloadData()
        
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// My Model objects ///////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////

    // Movie object to hold Movie details
    struct MovieObject : Decodable{
        let original_title: String?
        let poster_path : String?
        let backdrop_path: String?
        let overview: String?
        let runtime: Int?
        let release_date: String?
        let vote_average: Double?
        let genres : [GenreDetails]?
        
        init() {
            original_title = "No title"
            poster_path = "nil"
            backdrop_path = "nil"
            overview = "nil"
            runtime = 0
            release_date = "Not available"
            vote_average = 0.0
            genres = [GenreDetails()]
        }
    }
    
    // Object for the genere details
    struct GenreDetails : Decodable{
        let id : Int?
        let name : String?
        init(){
            id = 000
            name = "General Category"
        }
    }
    
    
    // New
    // Object for the Reviews
    struct ReviewObject {
        var ownerName : String?
        var ownerID : String?
        var reviewTitle : String?
        var reviewContent : String?
        var likeCount : String?
        var dislikeCount : String?
    }
    
    

    
    ////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////// Extra helper methods /////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    
    // Helper method to show alert messages
    func showAlert(AlertTitle: String, Message : String){
        let alert = UIAlertController(title: AlertTitle, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

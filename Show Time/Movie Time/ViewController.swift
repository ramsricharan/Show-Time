//
//  ViewController.swift
//  Movie Time
//
//  Created by Ram Sri Charan on 3/14/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit
import Firebase


class MasterTableViewController: UITableViewController {
    
    
    // All my Model objects for decoding the JSON response
    // To extract movies branch from other values
    struct JSONResponse : Decodable {
        let results : [Movies]
    }
    // Model object for Movie
    struct Movies : Decodable {
        let id : Int?
        let title : String?
        let vote_average : Double?
        let poster_path : String?
        let backdrop_path : String?
        let overview : String?
        let release_date : String?
    }
    
    
    struct MiscMovieDetails {
        var reviewCount : String?
        var isFavorite : Bool?
    }
    
    
    // All my local variables and data containers
    var UserID, UserName, ProfilePic_path : String?
    
    let MyCellIdentifier = "MyCellID"
    var MovieListURL = "http://api.themoviedb.org/3/movie/now_playing?api_key=606a18ba03513c0c982f6120e7d4b305"
    var MovieListType = "API"
    
    var MyMovieList = [Movies]()
    var MyMovieMiscList = [MiscMovieDetails]()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the logout button on the Navigationbar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutPressed))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        navigationController?.navigationBar.barTintColor = UIColor.red


        // If user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(logoutPressed), with: nil, afterDelay: 0)
        }
        
        //  if user is logged in
        else{
            // First getting the data from the cloud
            if MovieListType == "API"{
                populateMovieList()
            }

            // Setting up the table view
            view.backgroundColor = UIColor.darkGray
            tableView.register(MyCustomCell.self, forCellReuseIdentifier: MyCellIdentifier)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser?.uid != nil {
            super.viewWillAppear(true)
            getUserDetails()
            
            if MovieListType == "FAV"{
                populateFavoriteMovieList()
            }
            
            else{
                getMiscMovieDetails()
            }
            
        }
    }
    
    
    // Logout button handler
    @objc func logoutPressed(){
        // Logging out the user
        do{
            try Auth.auth().signOut()
        } catch let error{
            print(error)
        }
        // Gping back to Login page
        let loginPage = LoginViewController()
        present(loginPage, animated : true, completion : nil)
    }

    
    
    
    
    
    //////////////////////////// Get and Set user details in Title bar functions ////////////////////////////
    
    // Get user details for the current user from Firebase
    func getUserDetails(){
        UserID = Auth.auth().currentUser?.uid
        let ref : DatabaseReference = Database.database().reference().child("users").child(UserID!)
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            self.UserName = value?["user_name"] as? String ?? "No Name"
            self.ProfilePic_path = value?["picture_path"] as? String ?? "No Path"
            
            self.setUserDetails()
        })
    }
    
    
    // Set user Details into the titlebar
    
    // Initialize UI objects
    // Base UIView
    var baseView : UIView = {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }()
    
    // Profile picture ImageView
    var Nav_ProfileImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "blank_profile")
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // User name label
    var Nav_UserName : UILabel = {
        let name = UILabel()
        name.text = "User Name"
        name.textColor = UIColor.white
        name.font = UIFont.boldSystemFont(ofSize: 12)
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    
    // Adding and setting constraints to the above views
    func setUserDetails(){
        
        // Creating a base View to hold image and text views
        baseView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        baseView.heightAnchor.constraint(equalToConstant: 50).isActive  = true
        
        // Adding imageView to baseView and setting constraints
        baseView.addSubview(Nav_ProfileImage)
        Nav_ProfileImage.topAnchor.constraint(equalTo: baseView.topAnchor).isActive = true
        Nav_ProfileImage.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        Nav_ProfileImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        Nav_ProfileImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Setting the profile image
        if(ProfilePic_path != ""){
            let profile_url = URL(string : ProfilePic_path!)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: profile_url!)
                DispatchQueue.main.async {
                    self.Nav_ProfileImage.image = UIImage(data: data!)
                }
            }
        }
        
        // Adding TextView to baseView and setting constraints
        baseView.addSubview(Nav_UserName)
        Nav_UserName.topAnchor.constraint(equalTo: Nav_ProfileImage.bottomAnchor).isActive = true
        Nav_UserName.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        Nav_UserName.bottomAnchor.constraint(equalTo: baseView.bottomAnchor).isActive = true
        Nav_UserName.heightAnchor.constraint(equalToConstant: 15).isActive = true
        Nav_UserName.text = UserName
        
        // Adding the baseview to the navigation bar
        navigationItem.titleView = baseView
        
        // Adding touch event
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(handleProfileTouch(_:)))
        navigationItem.titleView?.addGestureRecognizer(gesture)
    }
    
    
    
    // Adding on touch event handler for Profile touched in title bar
    @objc func handleProfileTouch(_ sender : UITapGestureRecognizer){
        print("Opening profile")
        let myProfile : MyProfileViewController = MyProfileViewController()
        myProfile.entryType = "edit"
        self.navigationController?.pushViewController(myProfile, animated: true)
    }
    
    
    
    
    
    ////////////////////////////    TableView methods    ////////////////////////////
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyMovieList.count
    }
    
    // Loading Poster and Movie names into each custom cell of tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyCell =  tableView.dequeueReusableCell(withIdentifier: MyCellIdentifier, for: indexPath) as! MyCustomCell
        
        // Setting Movie name
        MyCell.MovieNameLabel.text = MyMovieList[indexPath.row].title
    
        
        // Setting Movie review count
//        let MovieId = String (MyMovieList[indexPath.row].id!)
//        setReviewCountLabel(MovieId: MovieId, CountLabel: MyCell.MovieReviewCount)

        if(MyMovieMiscList.count > 0){
            MyCell.MovieReviewCount.text = MyMovieMiscList[indexPath.row].reviewCount
            MyCell.FavoriteButton.backgroundColor = MyMovieMiscList[indexPath.row].isFavorite! ? UIColor.yellow : .lightGray
        }
        
        // Setting Movie poster
        let posterPath_str = "http://image.tmdb.org/t/p/w154" + MyMovieList[indexPath.row].poster_path!
        let poster_url = URL(string : posterPath_str)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: poster_url!)
            if data != nil{
                DispatchQueue.main.async {
                    MyCell.MoviePoster.image = UIImage(data: data!)
                }
            }
        }
        
        // Handling favorite button tapped
        MyCell.FavoriteButton.addTarget(self, action: #selector(handleFavTapped), for: .touchUpInside)

        return MyCell
    }
    
    // Fav button tap handler
    @objc func handleFavTapped(sender : UIButton){
        let cell = sender.superview as! MyCustomCell
        let indexPath = tableView.indexPath(for: cell)
        let currentRow = (indexPath?.row)!
        let isCurrentFav = MyMovieMiscList[currentRow].isFavorite!
        
        let currentMovieId = String (MyMovieList[currentRow].id!)
        let currentMovieName = MyMovieList[currentRow].title!
        let currentMoviePoster = MyMovieList[currentRow].poster_path!
        
        let CurrentUserRef : DatabaseReference = Database.database().reference().child("users").child(UserID!).child("fav_movies")
        
        
        // if it is already fav
        if isCurrentFav{
            MyMovieMiscList[currentRow].isFavorite = false
            sender.backgroundColor = UIColor.lightGray
            CurrentUserRef.child(currentMovieId).removeValue()
        }
        
        // Not fav.. make it fav
        else{
            MyMovieMiscList[currentRow].isFavorite = true
            sender.backgroundColor = UIColor.yellow
            CurrentUserRef.child(currentMovieId).child("movie_name").setValue(currentMovieName)
            CurrentUserRef.child(currentMovieId).child("poster_path").setValue(currentMoviePoster)
        }


        if MovieListType == "FAV"{
            populateFavoriteMovieList()
        }
        
    }
    
    
    
    
    
    
    // Swipe to delete movie functionality
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteMovie = UITableViewRowAction(style: .destructive, title: "Delete Movie") { (ACTION, indexPath) in
            self.MyMovieList.remove(at: indexPath.row)
            tableView.reloadData()
        }
        return [deleteMovie]
    }
    
    // On click event handler
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsView : DetailsViewController = DetailsViewController()
        detailsView.receivedMovieID = MyMovieList[indexPath.row].id!
        detailsView.CurrentUserID = UserID!
        detailsView.CurrentUserName = UserName!
        self.navigationController?.pushViewController(detailsView, animated: true)
    }
    
    
    
    
    
    
    //////////////////////////////////   Helper methods   //////////////////////////////////
    
    // This function populates the data by decoding the JSON data received from the TMDB Url
    func populateMovieList() {
        guard let url = URL(string : MovieListURL) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in

            guard let data = data else {return}
            do{
                let jsonResponse = try JSONDecoder().decode(JSONResponse.self, from: data)
                self.MyMovieList = jsonResponse.results
                self.getMiscMovieDetails()
                
            }
            catch{
                print("JSON decoding failed!!")
            }
        }.resume()
    }
    
    func populateFavoriteMovieList(){
        
        MyMovieList.removeAll()
        
        let currentUserId = Auth.auth().currentUser?.uid
        let ref : DatabaseReference = Database.database().reference()

        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // Get fav movies Snapshot
            let favMoviesSnapshot : DataSnapshot = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: currentUserId!).childSnapshot(forPath: "fav_movies")
            
            // Check if fav movies exists
            if(favMoviesSnapshot.childrenCount >= 1){
                
                let enumerator = favMoviesSnapshot.children
                while let currentFavMovie = enumerator.nextObject() as? DataSnapshot {
                    let value = currentFavMovie.value as? NSDictionary
                    
                    let movieId = Int (currentFavMovie.key)
                    let movieName = value?["movie_name"] as? String ?? ""
                    let moviePoster = value?["poster_path"] as? String ?? ""
                    

                    let currentMovie : Movies = Movies.init(id: movieId, title: movieName, vote_average: nil, poster_path: moviePoster, backdrop_path: nil, overview: nil, release_date: nil)
                    
                    self.MyMovieList.append(currentMovie)
                }
            }
            self.getMiscMovieDetails()

        })
        
        
    }
    
    
    
    func getMiscMovieDetails(){
        MyMovieMiscList.removeAll()
        
        
        var count : Int = 0
        var countString = ""
        let ref : DatabaseReference = Database.database().reference()
        
        
        ref.observeSingleEvent(of: .value, with: { (snapshot)
                in
            
            for curMovie in self.MyMovieList{
                
                let movieId = String (curMovie.id!)
                let reviewSnapshot : DataSnapshot = snapshot.childSnapshot(forPath: "reviews").childSnapshot(forPath: movieId)
                let favMoviesRef : DataSnapshot = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: self.UserID!).childSnapshot(forPath: "fav_movies")
                
        
                count = Int(reviewSnapshot.childrenCount)
                
                if count > 0 {
                    countString = "\(count) reviews"
                }
                else{
                    countString = "No reviews"
                }
                
                var miscdata = MiscMovieDetails()
                miscdata.reviewCount = countString
                miscdata.isFavorite = favMoviesRef.hasChild(movieId)
                
                self.MyMovieMiscList.append(miscdata)
            
              }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            })

        
    }
    
    
    
    // Get reviews count
    func setReviewCountLabel(MovieId : String, CountLabel : UILabel) {
        var count : Int = 0
        var countString = ""
        let ref : DatabaseReference = Database.database().reference().child("reviews").child(MovieId)

        ref.observeSingleEvent(of: .value, with: { (snapshot)
            in
            count = Int(snapshot.childrenCount)
            
            if count > 0 {
                countString = "\(count) reviews"
            }
            else{
                countString = "No reviews"
            }
            CountLabel.text = countString
        })
    }
    
    


}










////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////   My Custom cell class   //////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

class MyCustomCell: UITableViewCell{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // Initilizing the subViews
    
    // Movie Poster Imageview
    var MoviePoster : UIImageView = {
        let image = UIImageView()
        image.image =  #imageLiteral(resourceName: "blankPoster")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // Movie Name label
    var MovieNameLabel : UILabel = {
        let label = UILabel()
        label.text = "No Name"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Movie review count label
    var MovieReviewCount : UILabel = {
        let label = UILabel()
        label.text = "No Reviews"
        label.textColor = UIColor.yellow
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Favorite Button
    var FavoriteButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
        button.backgroundColor = UIColor.lightGray
        return button
    }()

    
    // This function adds and sets the constraints for the above views
    func setupSubViews(){
        
        // Get the width of the screen
        let screensize: CGRect = UIScreen.main.bounds
        let width = Float(screensize.width) - 140.00
        
        backgroundColor = UIColor.black
        
        // Adding Movie Poster ImageView and its constraints
        addSubview(MoviePoster)
        MoviePoster.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        MoviePoster.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        MoviePoster.widthAnchor.constraint(equalToConstant: 60).isActive = true
        MoviePoster.heightAnchor.constraint(equalToConstant: 60).isActive = true
        MoviePoster.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        MoviePoster.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
        
        // Adding Movie Name and its constraints
        addSubview(MovieNameLabel)
        MovieNameLabel.leftAnchor.constraint(equalTo: MoviePoster.rightAnchor, constant: 16).isActive = true
//        MovieNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        MovieNameLabel.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
        MovieNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8).isActive = true
        
        // Adding Movie review count and its constraints
        addSubview(MovieReviewCount)
        MovieReviewCount.leftAnchor.constraint(equalTo: MoviePoster.rightAnchor, constant: 16).isActive = true
//        MovieReviewCount.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        MovieReviewCount.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
        MovieReviewCount.topAnchor.constraint(equalTo: MovieNameLabel.bottomAnchor, constant: 2).isActive = true
        
        
        addSubview(FavoriteButton)
        FavoriteButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        FavoriteButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        FavoriteButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        FavoriteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        FavoriteButton.leftAnchor.constraint(equalTo: MovieNameLabel.rightAnchor, constant: 8).isActive = true
        
    }
    
    
}







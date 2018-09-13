# Show Time
 A Simple Personalised movie details app that helps users to know everything about the Upcoming, New Releases,
 Popular movies etc. It allows users to check out what people are saying about a movie, or they can tell others
 about the movie. They can create their own list of favorite movies.


## Project Setup
```
 Category: Academic Project 
 Programming Language: Swift 4
 IDE: XCode
 Platform: iOS
 ```
 
## Key Features
 * Programmatically implemented Auto-Layouts for subView arrangement and also to handle orientation changes.
 * Implemented Secure User Authentication and User Registration to maintain the User database.
 * Used tmdb's API to fetch the New Releases, Upcoming, Popular movies lists. Each movie provides a detailed
   information regarding the movie which includes rating, overview, reviews etc.
 * Users can post reviews for any movie in the lists, edit their reviews, Like/Dislike other users reviews.
 * Users can shortlist the movies that they like by adding them to their favorite list.
 * Users can make basic profile modifications.
 
## Technical Details
 * Used Google's Firebase Authentication for Secure User Authentication and User Registration.
 * Used Google's Firebase Database to save the data related to favorite movies, reviews, Like/Dislikes etc.
 * Used Firebase Storage to save the User's profile images.
 * The app is always in Sync, thanks to Google's real-time database which pushes updates whenever the 
   database is changed.
 * Used **UITabBarController** to navigate between different Movie Lists.
 * Implemented Master/Details Flow Layout using **UINavigationController** to show List of movies and their
   detailed information pages.
 * Used an open source library called [Cosmos](https://github.com/evgenyneu/Cosmos) to create **Star Ratings**
   views to display the movie ratings.
 
 
 ## Demo
  * **Demo Video:** [Youtube](https://www.youtube.com/watch?v=NcVGLr4Sb5I&feature=youtu.be)
 
 
 
 

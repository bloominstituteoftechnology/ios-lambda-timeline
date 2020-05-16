# Lambda Timeline 

## Introduction

The goal of this project is to take an existing project called LambdaTimeline and add features to it throughout this sprint. 

1. To begin with you will design the photo filter UI in a new Xcode project using different filters.
2. After you finish implementing your UI for filters, you'll update the Lambda Timeline project with the ability to:
    1. Create posts with images from the user's photo library
    2. Add comments to posts
    3. Filter images you post using your photo filter UI

## Instructions

Create a new branch in the repository called `postGeotags` and work off of it from where you left off yesterday.

### Part 1 - ~~#NoFilter~~ #Filters

Create a new Xcode project called `ImageFilterEditor` to use as a playground for your Core Image filters and UI setup. *It is ok to create extra Xcode projects to make sure things are working (and it's faster to build and test).*

1. Add at least 5 filters. The [Core Image Filter Reference](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/#//apple_ref/doc/filter/ci/CIFalseColor) lists the filters that you can use. Note that some simply take in an `inputImage` parameter, while others have more parameters such as the `CIMotionBlur`, `CIColorControls`, etc. 
    1. Use at least two or three of filters with a bit more complexity than just the `inputImage`.
2. Create an `ImagePostViewController` that will get a starting image and filter it.
    1. Add whatever UI elements you want to control the filters with the selected image.
    2. For filters that require other parameters use a slider, UITextField, segmented control, or UIPanGestureRecognizer. 
3. Ensure that the controls to add your filters, adjust them, etc. are only available to the user at the apropriate time. 
    1. For example, you shouldn't let the user add a filter if they haven't selected an image yet. And it doesn't make sense to show the adjustment UI if they selected a filter that has no adjustment.
4. You can use a Collection or Table View to select filters with additional detail screens to fine tune amounts of filters (i.e.: Instagram or Apple Photo)

### Part 2 - Firebase Setup

Though you have a base project, you will need to modify it. 

**Cocoapods**

To begin, run `pod install` after navigating to the repo in terminal. (If you have issues with [Cocoapods, Homebrew, Ruby, follow this guide](Cocopods-Homebrew-and-Ruby-Install-Guide.md)) Work out of the generated `.xcworkspace`

    pod install
    
NOTE: If you run `pod update` there may be breaking changes from newer versions of Firebase. The current Podfile.lock versions work with Swift 5.1 and Xcode 11.

**Firebase Setup**

[Watch the iOS Firebase Authentication Video](https://youtu.be/vGeuZtHmcMM) to follow these steps
[![Watch the iOS Firebase Authentication Video](https://tk-assets.lambdaschool.com/a8f55011-48ef-4eb9-af2b-17a7b92fae64_FirebaseVideo.png)](https://youtu.be/vGeuZtHmcMM)

1. Create a new Firebase project (or use an existing one).
2. Change the project's bundle identifier to your own bundle identifier (e.g. `com.JohnSmith.LambdaTimeline`)
3. In the "Project Overview" in your Firebase project, you will need to add your app as we are using the Firebase SDK in our Xcode project. You will need to add the "GoogleService-Info.plist" file that will be given to you when you add the app.
4. Please refer to this page: https://firebase.google.com/docs/auth/ios/firebaseui and follow the steps under the “Set up sign-in methods”. 
    1. You will only need to do the two steps under the [Google section](https://firebase.google.com/docs/auth/ios/firebaseui#google). 
    2. The starter project will have a URL type already. You just need to paste the right URL scheme in. 
    3. You can find the URL Type in your project file in the `Project Settings > Info > URL Types (expand) > URL Schemes`
5. In the Firebase project's database, change the rules to:
``` JSON
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```
This will allow only users of the app who are authenticated to access the database. (Authentication is already taken care of in the starter project)

Either way you decide to do this has its pros and cons, so choose whatever makes the most sense to you.

3. Update the `dictionaryRepresentation` and both initializers to account for the property (or properties). 
    - **Note:** Firebase will not store a `CLLocationCoordinate2D`, so you must break it up into a key-value pair for both the latitude and longitude in the `dictionaryRepresentation`.
4. Update the `PostController` to account for creating posts with and without geotags.
5. Create a helper class that will take care of requesting location usage authorization from the user, as well as getting their current location in order to geotag a post that is being created. This can be done through using `CLLocationManager` and `CLLocationManagerDelegate`.
    - **Note:** For the base requirements of this project, every post that should be geotagged will just use the user's current location.
6. Update the UI for creating **image and video** posts to allow the user to choose whether to geotag their posts or not.
7. In the Main.storyboard, embed the navigation controller in a tab bar controller. Add a new view controller scene with a map view on it. There are a few things that you will have to change now that the tab bar is essentially the first view controller to be displayed once the user is authenticated.
    <details><summary>Hints</summary>
    <p>

At this point, run the app on your simulator or physical device in order to make sure that you've set up your Firebase Project correctly. If set up correctly, you should be able to create posts, comment on them, and have them get sent to Firebase. You should also be able to re-run the app and have the posts and comments get fetched correctly. If this does not work, the likely scenario is that you've not set up your Firebase project correctly. If you can't figure out what's wrong, please reach out to your TL.

*Note: If you have a free Apple Developer account you may need to reuse your Bundle ID from a previous project to run on a real device (Apple limits you to three unique identifiers).*

### Part 3: Feature Integration

1. Integrate your `ImagePostViewController` into the Lambda Timeline Firebase project.
2. You should be able to create a new post, select a photo, edit the photo, and post it to your Firebase server.

## Go Further

- Clean up the UI of the app, either with the UI you added to support filters. You're welcome to touch up the UI overall if you wish as well.
- Allow for undoing and redoing of filter effects (i.e.: Reset to the identity values, snap to default, etc.)
- Try using a `UIPanGestureRecognizer` on your `UIImageView` to get the (x, y) coordinate using `locationInView:` on the panGesture. (You may need to clamp the value to the bounds of the image).

You are encouraged to implement both methods if you feel up to it.

- Customize the annotations that are shown on the map view controller to also show the media (image or video) associated with it. **Note:** if you chose to create a `PostAnnotation` object, you may need to modify it so you can have more information than just the post's title and author.
- Add the ability to go directly to the detail view controller of a post (the one with the post's comments) from the annotation.

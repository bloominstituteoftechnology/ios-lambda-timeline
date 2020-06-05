# Lambda Timeline 

## Introduction

The goal of this project is to take an existing project called LambdaTimeline and add features to it throughout this sprint. 

<<<<<<< HEAD
1. To begin with you will design the photo filter UI in a new Xcode project using different filters.
2. After you finish implementing your UI for filters, you'll update the Lambda Timeline project with the ability to:
    1. Create posts with images from the user's photo library
    2. Add comments to posts
    3. Filter images you post using your photo filter UI
=======
Today you will be adding video posts.
>>>>>>> video

## Instructions

Create a new branch in the repository called `video` and work off of it from where you left off yesterday.

<<<<<<< HEAD
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
=======
You're welcome to fulfill these instructions however you want. There are a few suggestions to help you along if you need them.

## Part 1: VideoPost Prototype

Create a new Xcode project with the UI and functionality to capture and save a video to a URL that can be shared.
>>>>>>> video

1.  The UI should allow the user to record a video. 
    1. Once the video has been recorded, it should play back the video (the playback can be looped if you want).
    2. The user can add a title just like in an image post and can post it (to a collection view)
    3. Optional: There can be a button to retake the video before posting (discard the old video file using the FileManager).
2. A video post should be displayed in a custom Collection View cell (there can be multiple video posts)
3. You can decide how you want to handle preview and playback controls (Looping Instagram Story style with an `x` button, or QuickTime style with playback and seek controls)

### Tips

<<<<<<< HEAD
At this point, run the app on your simulator or physical device in order to make sure that you've set up your Firebase Project correctly. If set up correctly, you should be able to create posts, comment on them, and have them get sent to Firebase. You should also be able to re-run the app and have the posts and comments get fetched correctly. If this does not work, the likely scenario is that you've not set up your Firebase project correctly. If you can't figure out what's wrong, please reach out to your TL.

*Note: If you have a free Apple Developer account you may need to reuse your Bundle ID from a previous project to run on a real device (Apple limits you to three unique identifiers).*

### Part 3: Feature Integration

1. Integrate your `ImagePostViewController` into the Lambda Timeline Firebase project.
2. You should be able to create a new post, select a photo, edit the photo, and post it to your Firebase server.

## Go Further

- Clean up the UI of the app, either with the UI you added to support filters. You're welcome to touch up the UI overall if you wish as well.
- Allow for undoing and redoing of filter effects (i.e.: Reset to the identity values, snap to default, etc.)
- Try using a `UIPanGestureRecognizer` on your `UIImageView` to get the (x, y) coordinate using `locationInView:` on the panGesture. (You may need to clamp the value to the bounds of the image).
=======
1. You may take the `CameraViewController` used in the guided project as a base. 
2. You should be able to play the video using the `AVPlayer` and `AVPlayerLayer` classes.
3. You can reuse the special `UIView` layer backed classes to live preview the camera, as well as the video playback.
4. Optional: Grab the first frame of video to use when displaying a video post (alternatively you can use a placeholder image).

## Part 2: Video Posts on Lambda Timeline
1. Integrate your UI to create a video post onto your Firebase backend.

    <details><summary>Recording UI Suggestions</summary>
    <p>

      - If you use the `CameraViewController` you may need to modify it so the video doesn't get stored to the user's photo library. Instead you can use the url that the `didFinishRecordingTo outPutFileURL: URL` method gives you back to send the video data to Firebase
    </p>
    </details>
2. Add a new case to the `MediaType` enum in the Post.swift file for videos. Take a look at the memberwise initializer for the Post. Make sure that it takes in a `MediaType` and sets `mediaType` correctly.
3. Create a new collection view cell in the `PostsCollectionViewController`. It should display the video, as well as the post's title and author. It's up to you if you want the video to play automatically or have it play when you tap the cell, or a button, etc.
4. Create a detail view controller for video posts similar to the `ImagePostDetailViewController`. It should display the post's video, title, artist, and its comments. It should also allow the user to add their own text and audio comments.

## Go Further

- Add the ability to record audio with the video. When the video plays on a cell or in the video post view controller, the audio should play as well.
- Add the ability to record from the front camera and let the user flip the cameras.
- Add the option to save the video to the user's photo library
>>>>>>> video

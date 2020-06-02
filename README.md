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
Today you will be adding audio comments.
>>>>>>> audioComments

## Instructions

Create a new branch in the repository called `audio` and work off of it from where you left off yesterday.

You're welcome to fulfill these instructions however you want. If you'd like suggestions on how to implement something, open the disclosure triangle and there are some suggestions for most of the instructions.

### Part 1: Audio UI Prototyping

Your first goal is to work on the audio functionality to prototype how it should behave. Building and testing with Firebase is slow, so you can speed up your development by working in issolation on this feature change.

1. Create a new Xcode project for prototyping called `AudioComments`
2. Create UI that allows the user to create an audio comment. 
    1. The UI should allow the user to record, stop, cancel, and send the recording.
3. Create Table View UI that displays audio comments in a custom table view cell.
    1. The UI should allow the user to play, pause, and scrub through a recording. 
    
    
For inspiration, look at how the Phone app works with Voicemail, or how the Voice Memos app works.

### Part 2: Lambda Timeline Audio Integration

Integrate your custom recording UI into the Lambda Timeline project.

1. Users should be able to create an audio comment (in addition to a text comment).
    <details><summary>Recording UI Suggestions</summary>
    <p>

      - In the `ImagePostDetailViewController`, change the `createComment` action to allow the user select whether they want to make a text comment or an audio comment, then create a new view controller with the required UI. The view controller could be presented modally or as a popover.
      
      - Alternatively, you could modify the `ImagePostDetailViewController` to hold the audio recording UI.

    </p>
    </details>
    
2. Create a new table view cell that displays at least the author of the audio comment, and a button to play the comment.

3. Change the `Comment` to be either a text comment or an audio comment.

    <details><summary>Comment Suggestions</summary>
    <p>

    - In the `Comment` object, change the `text`'s type to be an optional string, and create a new `audioURL: URL?` variable as well. Modify the `dictionaryRepresentation` and the `init?(dictionary: ...)` to accomodate the `audioURL` and the now optional `text` string.

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
    </p>
    </details>

4. In the `PostController`, add the ability to create a comment with the audio data that the user records, and save it to Firebase Storage, add the comment to its post, then save the post to the Firebase Database.

    <details><summary>Post Controller Suggestions</summary>
    <p>
>>>>>>> audioComments

      - Create a separate function to create a comment with the audio data.
      - You can very easily change the `store` method to instead take in data and a `StorageReference` to accomodate for storing both Post media data and now the audio data as well.

    </p>
    </details>
5. In the `ImagePostDetailViewController`, make sure that the audio is being fetched for the audio comments. You are welcome to fetch the audio for each audio comment however you want.

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
    <details><summary>Audio Fetching Suggestions</summary>
    <p>

      - You can implement the audio fetching similar to the way images are fetched on the `PostsCollectionViewController` by using operations, an operation queue, and a new cache. Make a new subclass of `ConcurrentOperation` that fetches audio using the comment's `audioURL` and a `URLSessionDataTask`.

    </p>
    </details>

6. Implement the ability to play a comment's audio from the new audio comment cell from step 2. As you implement the `AVAudioRecorder`, remember to add a microphone usage description in the Info.plist.

## Go Further

- Add a label (if you don't have one already) to your recording UI that will show the recording time as the user is recording.
- Change the audio comment cell to display the duration of the audio, as well as show the current time the audio is at when playing.
>>>>>>> audioComments

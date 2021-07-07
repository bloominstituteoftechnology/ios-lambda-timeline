# Lambda Timeline 

## Introduction

The goal of this project is to take an existing project called LambdaTimeline and add features to it throughout this sprint. 

Today you will be adding video posts.

## Instructions

Create a new branch in the repository called `video` and work off of it from where you left off yesterday.

You're welcome to fulfill these instructions however you want. There are a few suggestions to help you along if you need them.

## Part 1: VideoPost Prototype

Create a new Xcode project with the UI and functionality to capture and save a video to a URL that can be shared.

1.  The UI should allow the user to record a video. 
    1. Once the video has been recorded, it should play back the video (the playback can be looped if you want).
    2. The user can add a title just like in an image post and can post it (to a collection view)
    3. Optional: There can be a button to retake the video before posting (discard the old video file using the FileManager).
2. A video post should be displayed in a custom Collection View cell (there can be multiple video posts)
3. You can decide how you want to handle preview and playback controls (Looping Instagram Story style with an `x` button, or QuickTime style with playback and seek controls)

### Tips

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

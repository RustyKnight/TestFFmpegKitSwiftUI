# TestFFmpegKitSwiftUI

A simple experiment using [ffmpeg-kit](https://github.com/tanersener/ffmpeg-kit) with SwiftUI

This example contains the [ffmpeg-kit-full-4.5.1-macos-xcframework.zip](https://github.com/tanersener/ffmpeg-kit/releases/download/v4.5.1/ffmpeg-kit-full-4.5.1-macos-xcframework.zip) libraries for simplicty.

This example has been targeted to MacOS, but the "concept" should work on iOS

**This is intended as an eductional example - blocking the main thread is NEVER a good idea**

# Bring your own media

The example has been updated to load the media from `Bundle` and output it to the `.documents` directory within the user's current context

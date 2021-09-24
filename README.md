Sonos Swift SDK
========

[![Swift](https://github.com/JimmyJammed/sonos-swift-sdk/actions/workflows/swift.yml/badge.svg)](https://github.com/JimmyJammed/sonos-swift-sdk/actions/workflows/swift.yml)
[![SwiftLint](https://github.com/JimmyJammed/sonos-swift-sdk/actions/workflows/SwiftLint.yml/badge.svg)](https://github.com/JimmyJammed/sonos-swift-sdk/actions/workflows/SwiftLint.yml)
[![License](https://img.shields.io/cocoapods/l/Swinject.svg?style=flat)](http://cocoapods.org/pods/Swinject)
[![Platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgrey.svg)](http://cocoapods.org/pods/Swinject)
[![Swift Version](https://img.shields.io/badge/Swift-5.0-F16D39.svg?style=flat)](https://developer.apple.com/swift)
[![Twitter](https://img.shields.io/badge/twitter-@jimmy_jammed-blue.svg?style=flat)](http://twitter.com/jimmy_jammed)

Sonos Swift SDK is a plug-and-play library that allows you to quickly integrate your iOS and macOS apps with the Sonos API.

## How To Get Started
* [ ] Create a Sonos Developer account [here](https://developer.sonos.com)
* [ ] Setup a new integration [here](https://integration.sonos.com/integrations)
* [ ] Open the `SonosSDK.xcworkspace` in Xcode.
* [ ] Grab the **Key Name**, **Key** and **Secret** from your new Sonos app integration and update the `SwiftUIExampleApp.swift` file with your values:

```
struct SonosConfiguration {

    static let keyName = "your-sonos-key-name"
    static let key = "your-sonos-developer-key"
    static let secret = "your-sonos-developer-secret"
    static let redirectURI = "sonos-swift-sdk://authorize"
    static let callbackURL = "your-webhook-api-url"

}
```

## Installation
Sonos Swift SDK supports the following installation methods:

### Swift Package Manager

in `Package.swift` add the following:

```swift
dependencies: [
    .package(url: "https://github.com/JimmyJammed/sonos-swift-sdk", from: "1.0.0")
],
targets: [
    .target(
        name: "MyProject",
        dependencies: ["sonos-swift-sdk"]
    )
    ...
]
```

###### Note: Sonos Swift SDK requires the following Swift Package dependencies:

[AFNetworking](https://github.com/AFNetworking/AFNetworking)
<br />
[BetterSafariView](https://github.com/stleamist/BetterSafariView)
<br />
[Swinject](https://github.com/Swinject/Swinject)
<br />
[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

## Requirements

| Sonos Swift SDK Version | Sonos Swift Networking Version | Minimum iOS Target  | Minimum macOS Target  | Minimum watchOS Target  | Minimum tvOS Target  |                                   Notes |
|:--------------------:|:--------------------:|:---------------------------:|:----------------------------:|:----------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
| 1.x | v1 | iOS 14 | x | x | x | Xcode 12+ is required. |

## Supported Sonos APIs

Here is a list of the supported Sonos API's in Sonos Swift SDK:

* [x] [Authorization](https://developer.sonos.com/reference/authorization-api/)
	* [x] [Create Authorization Code](https://developer.sonos.com/reference/authorization-api/create-authorization-code/) 
	* [x] [Create Token](https://developer.sonos.com/reference/authorization-api/create-token/) 
	* [x] [Refresh Token](https://developer.sonos.com/reference/authorization-api/refresh-token/) 
* [ ] [Control API](https://developer.sonos.com/reference/control-api/)
	* [ ] [Audio Clip](https://developer.sonos.com/reference/control-api/audioclip/)
	* [ ] [Favorites](https://developer.sonos.com/reference/control-api/favorites/)
	* [x] [Groups](https://developer.sonos.com/reference/control-api/groups/)
	* [ ] [Group Volume](https://developer.sonos.com/reference/control-api/group-volume/)
	* [ ] [Home Theater](https://developer.sonos.com/reference/control-api/hometheater/)
	* [x] [Households](https://developer.sonos.com/reference/control-api/households/)
	* [ ] [Music Service Accounts](https://developer.sonos.com/reference/control-api/musicserviceaccounts/)
	* [ ] [Playback](https://developer.sonos.com/reference/control-api/playback/)
	* [ ] [Playback Metadata](https://developer.sonos.com/reference/control-api/playback-metadata/)
	* [ ] [Playback Session](https://developer.sonos.com/reference/control-api/playbacksession/)
	* [x] [Player Volume](https://developer.sonos.com/reference/control-api/playervolume/)
	* [ ] [Playlists](https://developer.sonos.com/reference/control-api/playlists/)
	* [ ] [Settings](https://developer.sonos.com/reference/control-api/settings/)
* [ ] [Cloud Queue API](https://developer.sonos.com/reference/cloud-queue-api/)
* [ ] [Sonos Music API](https://developer.sonos.com/reference/sonos-music-api/)

## Unit Tests

Sonos Swift SDK includes a suite of unit tests within the Tests subdirectory.

## Contribution Guide

A guide to [submit issues](https://github.com/JimmyJammed/sonos-swift-sdk/issues), to ask general questions, or to [open pull requests](https://github.com/JimmyJammed/sonos-swift-sdk/pulls) are [here](CONTRIBUTING.md).

## Credits

Sonos Swift SDK is an open source project and unaffiliated with Sonos Inc.

And most of all, thanks to Sonos Swift SDK's [growing list of contributors](https://github.com/JimmyJammed/sonos-swift-sdk/contributors).

## License

Sonos Swift SDK is released under the MIT license. See [LICENSE](https://github.com/JimmyJammed/sonos-swift-sdk/blob/master/LICENSE) for details.

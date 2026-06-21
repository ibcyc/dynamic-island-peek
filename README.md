# DynamicIslandPeek

DynamicIslandPeek is a small personal iOS app that lets you choose an image and show it in Dynamic Island with a Live Activity.

## Features

- Pick an image from Photos
- Save a thumbnail in an App Group container
- Start and stop a persistent Live Activity
- Show the selected image in Dynamic Island

## Requirements

- Xcode 26 or newer
- iOS 17 or newer
- A physical iPhone that supports Dynamic Island

## Setup

This repository uses placeholder identifiers so it can be shared publicly. Before running it on your own device, update these values in Xcode:

1. Select the `DynamicIslandPeek` app target and choose your Apple Development Team.
2. Change the app bundle identifier from `com.example.DynamicIslandPeek` to your own unique identifier.
3. Select the Live Activity extension target and set its bundle identifier too.
4. Update the App Group in both entitlement files and in `Shared/PeekShared.swift`.

The placeholder App Group is:

```text
group.com.example.DynamicIslandPeek
```

Use an App Group that belongs to your own Apple developer account.

## Notes

Dynamic Island and Live Activities require a Widget Extension target. The project does not include a Home Screen widget.

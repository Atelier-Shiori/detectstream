# What is detectstream
This is an open source command line helper tool/Cocoa Framework that detects Web Stream presence in Safari, Webkit, OmniWeb and Chrome using the Scripting framework (other browsers are unsupported as they don't support Applescript)

detectstream only works on macOS 10.11 El Capitan or later. Built against the macOS 10.14 SDK.

detectstream is used in [Hachidori](https://github.com/Atelier-Shiori/hachidori) and [MAL Updater OS X](https://github.com/Atelier-Shiori/malupdaterosx-cocoa)

**macOS Mojave Considerations**: Due to security changes, you must specify the key: "NSAppleEventsUsageDescription" with a description on usage and also enable Apple Events under Resource Acces with Hardened Runtime enabled under Capabilities. This is required in order for stream detection and App Notarization to work.

# Support
detectstream currently supports these sites:
## Anime
Safari, Webkit, Chrome, Roccat Browser and Omniweb: Crunchyroll, AnimeNewsNetwork, AnimeLab, Viz Neon Valley, Viewster, Wakanim, Funimation, Netflix, Hidive, VRV,  Tubitv, Yahoo View, AsianCrush, AnimeDigitalNetwork, Sony Crackle, Adult Swim, and Plex.tv Media Server (locally and on the web).

Chrome and Safari only (requires Javascript Execution): Viewster, Amazon Prime Video, Adult Swim (For Safari, you need to have "Enable Javascript from Apple Events" enabled in the [Developer Menu](https://support.apple.com/kb/PH21491). For Google Chrome, View > Developer > Allow JavaScript from Apple Events)

## Manga
Safari, Webkit, Chrome, Roccat Browser and Omniweb: Crunchyroll

# How to use
Sample source code for using this helper program in Objective-C and Swift can be seen [here](https://github.com/Atelier-Shiori/detectstream/wiki/Usage)

# How to help out
You can help us out by sending the page title and URL of the Anime Stream with the series title, episode, service name and page source by using this form
https://docs.google.com/forms/d/1tuv5OhD71U8L_3NyZuuZii3_A3BHlUhPAfQkkicvciU/viewform

or

Fork this source code and add the necessary changes to improve the detection of various streaming sites.

# To Compile
Get the source and then type xcodebuild. Having the applications installed is no longer necessary as the scripting bridge headers are now included.

To include in your project, drag the DetectStreamKit.framework.

# License
This version is licensed under MIT License. Older versions are GPL Version 3 license.

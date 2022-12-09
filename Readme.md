# What is detectstream
This is an open source Cocoa Framework that detects Web Stream presence in Safari, Webkit, OmniWeb, Chrome, Edge, and Brave Browser using the Scripting framework (other browsers are unsupported as they don't support AppleScript)

detectstream only works on macOS 10.11 El Capitan or later. Built against the macOS 13 SDK and is Universal Binary 2 compatible for Intel and Apple Silicon.

detectstream is used in [Hachidori](https://github.com/Atelier-Shiori/hachidori) and [MAL Updater OS X](https://github.com/Atelier-Shiori/malupdaterosx-cocoa)

**macOS Mojave or later Considerations**: Due to security changes, you must specify the key: "NSAppleEventsUsageDescription" with a description on usage and also enable Apple Events under Resource Access with Hardened Runtime enabled under Capabilities. This is required in order for stream detection and App Notarization to work.

# Support
detectstream currently supports these sites:
## Anime
Safari, Webkit, Chrome, Edge, Brave Browser, Opera, Roccat Browser and Omniweb: Crunchyroll, AnimeNewsNetwork, AnimeLab, Viz Neon Valley, Viewster, Wakanim, Funimation, Netflix, Hidive, VRV,  Tubitv, AsianCrush, AnimeDigitalNetwork, Sony Crackle, Adult Swim, HBO Max, Retrocrush, Hulu, Peacocktv, YouTube and Plex.tv Media Server (locally and on the web).

Chrome, Edge, Brave Browser and Safari only (requires Javascript Execution): Viewster, Amazon Prime Video, Adult Swim, Funimation (detection from user's watch history on the My Account page), HBO Max, Retrocrush, Hulu, Crunchyroll, Peacocktv, Disney Plus, Netflix (For Safari, you need to have "Enable Javascript from Apple Events" enabled in the [Developer Menu](https://support.apple.com/kb/PH21491). For Google Chrome, View > Developer > Allow JavaScript from Apple Events)

Note: Detection does not support non-anime titles

Note 2: [Orion](https://browser.kagi.com) support will be added once Javascript support via AppleScript is added.

## Manga
Safari, Webkit, Chrome, Edge, Brave Browser, Opera, Roccat Browser and Omniweb: Crunchyroll

# How to use
Sample source code for using this helper program in Objective-C and Swift can be seen [here](https://github.com/Atelier-Shiori/detectstream/wiki/Usage)

# How to help out
Create a thread on our [Support Forums](https://support.malupdaterosx.moe/index.php?forums/hachidori-stream-detection-support.11/). See [this thread](https://support.malupdaterosx.moe/index.php?threads/reporting-stream-detection-issues.5/) on how to report stream detection issue first before posting.

# To Compile
Get the source and then type xcodebuild. Having the applications installed is no longer necessary as the scripting bridge headers are now included.

To include in your project, drag the DetectStreamKit.framework.

# License
This version is licensed under MIT License.

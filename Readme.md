# What is detectstream
This is an open source command line helper tool that detects Web Stream presence in Safari, Webkit, OmniWeb and Chrome using the Scripting framework (other browsers are unsupported as they don't support Applescript)

detectstream is used in [Hachidori](https://github.com/chikorita157/hachidori) and [MAL Updater OS X](https://github.com/chikorita157/malupdaterosx-cocoa)

# Support
detectstream currently supports these sites:

Safari, Webkit, Chrome, Roccat Browser and Omniweb: Crunchyroll, AnimeNewsNetwork, AnimeLab, Viz Neon Valley, Viewster, Wakanim, Funimation, Netflix, Hidive, VRV, Amazon Prime Video (including Anime Strike), and Plex.tv Media Server (locally and on the web).

Chrome and Safari only (requires Javascript Execution): Viewster, Amazon Prime Video (For Safari, you need to have "Enable Javascript from Apple Events" enabled in the [Developer Menu](https://support.apple.com/kb/PH21491))

# How to use
Sample source code for using this helper program in Objective-C and Swift can be seen [here](https://github.com/chikorita157/detectstream/wiki/Usage)

# How to help out
You can help us out by sending the page title and URL of the Anime Stream with the series title, episode, service name and page source by using this form
https://docs.google.com/forms/d/1tuv5OhD71U8L_3NyZuuZii3_A3BHlUhPAfQkkicvciU/viewform

or

Fork this source code and add the necessary changes to improve the detection of various streaming sites.

# To Compile
Get the source and then type xcodebuild. Having the applications installed is no longer necessary as the scripting bridge headers are now included.

# License
This version is licensed under MIT License. Older versions are GPL Version 3 license.

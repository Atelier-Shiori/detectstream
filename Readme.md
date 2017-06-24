# What is detectstream
This is an open source command line helper tool that detects Web Stream presence in Safari, Webkit, OmniWeb and Chrome using the Scripting framework (other browsers are unsupported as they don't support Applescript)

detectstream is used in [Hachidori](https://github.com/chikorita157/hachidori) and [MAL Updater OS X](https://github.com/chikorita157/malupdaterosx-cocoa)

# Support
detectstream currently supports these sites:

Safari, Webkit, Chrome, Roccat Browser and Omniweb: Crunchyroll, Daisuki, AnimeNewsNetwork, AnimeLab, Viz Neon Valley, Viewster, Wakanim, Funimation, Netflix, Hidive, VRV and Plex.tv Media Server (locally and on the web).

Chrome and Safari only (requires Javascript Execution): Viewster (For Safari, you need to have "Enable Javascript from Apple Events" enabled in the [Developer Menu](https://support.apple.com/kb/PH21491))

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
This version is licensed under GNU Public License V3 and all older versions now is licensed under GPL V3. This is because I do not want people to steal my work and make it closed source.

If you don't want to abide to these license terms, you may buy a paid license that allow you to use this helper program without following the terms of the GPL. Note that you may not distribute the source code without releasing to the GPL. You can do this by sending a request to ateliershiori at chikorita157.com.'

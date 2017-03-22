# What is detectstream
This is an open source command line helper tool that detects Web Stream presence in Safari, Webkit, OmniWeb and Chrome using the Scripting framework (other browsers are unsupported as they don't support Applescript)

detectstream is used in [Hachidori](https://github.com/chikorita157/hachidori) and [MAL Updater OS X](https://github.com/chikorita157/malupdaterosx-cocoa)

# Support
detectstream currently supports these sites:

Safari, Webkit, Chrome, Roccat Browser and Omniweb: Crunchyroll, Daisuki, AnimeNewsNetwork, AnimeLab, Viz Neon Valley, Viewster, Wakanim, Plex.tv Media Server (locally and on the web).

Safari, Webkit, [Roccat Browser](http://runecats.com/roccatbrowsermac.html) and [OmniWeb](http://www.omnigroup.com/more) only (requires HTML Scraping): Netflix, Funimation

Safari only (requires Javascript Execution): Viewster

# How to use
Sample source code for using this helper program in Objective-C and Swift can be seen [here](https://github.com/chikorita157/detectstream/wiki/Usage)

# How to help out
You can help us out by sending the page title and URL of the Anime Stream with the series title, episode, service name and page source by using this form
https://docs.google.com/forms/d/1tuv5OhD71U8L_3NyZuuZii3_A3BHlUhPAfQkkicvciU/viewform

or

Fork this source code and add the necessary changes to improve the detection of various streaming sites.

# To Compile
Get the source and then type xcodebuild. You need to have Google Chrome and Omniweb in your Applications folder in order to compile since its used for the scripting bridge.

# License
This version is licensed under GNU Public License V3 and all older versions now is licensed under GPL V3. This is because I do not want people to steal my work and make it closed source.

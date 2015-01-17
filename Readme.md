# What is this? 
This is an open source application that detects Web Stream presence in Safari and Chrome using the Scripting framework (other browsers are unsupported as they don't support Applescript)

Still a work in progress. Browser detection is done, but still need to do work on Regular Expressions.

#Support
detectstream currently supports these sites:

Chrome and Safari: Crunchyroll, Daisuki, AnimeNewsNetwork, AnimeLab, Viz Neon Valley

Safari only (requires HTML Scraping): Netflix 

# How to help out
You can help us out by sending the page title and URL of the Anime Stream with the series title, episode, service name and page source by using this form
https://docs.google.com/forms/d/1tuv5OhD71U8L_3NyZuuZii3_A3BHlUhPAfQkkicvciU/viewform

or

Fork this source code and add the necessary changes to improve the detection of various streaming sites.

#To Compile
Get the source and then type xcodebuild. You need to have Google Chrome instlalled to compile as it's used for the scripting bridge.

#License
This version is licensed under GNU Public License V3 and all older versions now is licensed under GPL V3. This is because I do not want people to steal my work and make it closed source.

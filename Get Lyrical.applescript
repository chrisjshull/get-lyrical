-- Get Lyrical.applescript
-- Get Lyrical

--  Created by Christopher J. Shull on 1/16/09.
--  Copyright 2009 S.P. LLC. All rights reserved.
--global foundcount

(* TODO
random notes all over the place here and in php
\add lyric display(/editor?)
\update checker
\failure reporter
stop itunes auto-start?
auto-load with itunes?


-- characters to \unaccented, \apostrophe (straight to smart), \"U" for "You", "vs" in artist ?, quote (straight to smart)?, \'$' to 's'

--URL scrape :
http://lyrics.wikia.com/Dream_(US):He_Loves_U_Not
http://lyrics.wikia.com/Dream:He_Loves_U_Not


lyricwiki.org ping check

*)

property myvers : "3.7" --no abc
property go_vers : ""

global fails
property previdle : ""
property ITObserver : null
global green, yellow, red, light1, light2, light3, light4, icon
property prevsel : {}

global lyricHUDsong
property lyricHUDtype : ""

property debuglogon : false

property thepreffile : "com.shullian.getlyrical"

on awake from nib theObject
	set nom to name of theObject
	if nom is "hud" then
		--set control tint of progress indicator "prog" to clear tint
		tell progress indicator "prog" of window "hud" to start
		hide theObject
	else if nom is "changetrigger" then
		call method "setActionButton:" of ITObserver with parameter theObject
	else if nom is "main" then
		set icon to ((path to resource "gl lyre.icns") as alias)
		
		set green to load image "green.tif"
		set yellow to load image "yellow.tif"
		set red to load image "red.tif"
		set light1 to image view "light1" of window "main"
		set light2 to image view "light2" of window "main"
		set light3 to image view "light3" of window "main"
		set light4 to image view "light4" of window "LyricsHUD"
		set visible of light1 to false
		set visible of light2 to false
		set visible of light3 to false
		set visible of light4 to false
		check_vers(false)
		
		set state of menu item "inclyrhead_toggle" of sub menu of menu item 2 of main menu to readDefaultEntry(thepreffile, "inclyrhead_toggle", 1)
		set state of menu item "inclyrfoot_toggle" of sub menu of menu item 2 of main menu to readDefaultEntry(thepreffile, "inclyrfoot_toggle", 1)
		set state of menu item "failrpt_toggle" of sub menu of menu item 2 of main menu to readDefaultEntry(thepreffile, "failrpt_toggle", 1)
		set state of menu item "keepontop" of sub menu of menu item 4 of main menu to readDefaultEntry(thepreffile, "keepontop", 0)
		
		my gl_go_check()
		
		if state of menu item "keepontop" of sub menu of menu item 4 of main menu is 0 then
			set level of window "main" to 0
		else
			set level of window "main" to 3
		end if
		
		(*set mepath to POSIX path of (path to me)
		log mepath
		if mepath contains "/Downloads/Get Lyrical/" or mepath contains "/Desktop/Get Lyrical/" then
			log "asking to move"
			set appfold to POSIX path of (path to applications folder)
		end if*)
		
	end if
end awake from nib

on gl_go_check()
	set gl_go_type to readDefaultEntry(thepreffile, "gl-go-type", "")
	if gl_go_type is "zh" then
		set state of menu item "zh_search" of sub menu of menu item 2 of main menu to true
	else if gl_go_type is not "" then
		set state of menu item "zh_search" of sub menu of menu item 2 of main menu to false
	end if
end gl_go_check

(*
on idle theObject
	--display dialog "Would you like to overwrite any existing lyrics?" attached to window "main"
	--log "idle"
	if (state of button "active" of window "main" is 1) and (enabled of button "active" of window "main" is true) then
		tell application "iTunes" to set curr to current track
		if previdle is "" or previdle is not curr then
			try
				tell application "iTunes"
					my liracl(curr, false)
					set previdle to (curr)
				end tell
			on error
				--
			end try
		end if
	end if
	return 10
end idle
*)

on selcheck()
	if lyricHUDtype is "Selection" then
		set itunesOn to true
		if (debuglogon) then log "selcheck"
		
		--delay 0.1
		(*try
		set proc to do shell script "ps -axc | grep -E 'iTunes$'"
	on error
		set itunesOn to false
	end 
	try*)
		
		
		tell application "System Events"
			if (name of processes) does not contain "iTunes" then
				set itunesOn to false
			end if
		end tell
		
		
		if (debuglogon) then log "itunes is " & itunesOn
		if itunesOn then
			try
				tell application "iTunes" to set sel to get selection
			on error e
				(*delay 0.1
			tell application "System Events"
				if (name of processes) does not contain "iTunes" then
					set itunesOn to false
				end if
			end tell*)
				if (debuglogon) then log e
				if e contains "Connection is invalid" then
					set itunesOn to false
					set sel to {}
				end if
			end try
		else
			set sel to {}
		end if
		
		if (debuglogon) then log sel
		--tell application "iTunes" to set sel to get selection
		(*tell application "iTunes"
		try
			tell me to log {prevsel, sel}
		end try
	end tell*)
		try
			if prevsel is not sel then
				set visible of light1 to false
				set prevsel to sel
				if (count of prevsel) is 1 and itunesOn then lyricHUD(item 1 of prevsel, "Selection", false)
			end if
		end try
		if (debuglogon) then log "done selcheck"
	end if
end selcheck

on clicked theObject
	selcheck()
	
	(*tell application "System Events"
		if (name of processes) does not contain "iTunes" then
			return
		end if
	end tell*)
	
	
	set tellerr to true
	set nom to name of theObject
	log "clicked: " & nom
	if nom is "active" then
		if (state of button "active" of window "main") is 1 then
			set nom to "changetrigger"
			set tellerr to false
			tell progress indicator "prog" of window "main" to start
		else
			tell progress indicator "prog" of window "main" to stop
		end if
	end if
	if nom is "curr" then
		tell application "iTunes" to set doit to player state is not stopped
		if doit then
			try
				set image of light2 to yellow
				set visible of light2 to true
				
				tell application "iTunes" to set curr to current track
				
				if (my liracl(curr, true)) then
					set image of light2 to green
				else
					set image of light2 to red
				end if
				
				set previdle to (curr)
			on error err
				--tell me to log err
			end try
			lyricHUD(curr, "Current", false)
		else
			tell application "System Events"
				if tellerr then tell me to display dialog (localized string "No tracks playing..." from table "Localizable") buttons {(localized string "OK" from table "Localizable")} default button 1 with icon icon giving up after 15
			end tell
		end if
	else if nom is "showlyrics-sel" then
		showlyricsSel()
	else if nom is "showlyrics-curr" then
		showlyricsCurr()
	else if nom is "re" then
		if lyricHUDsong is not null then
			try
				set image of light4 to yellow
				set visible of light4 to true
				
				if (my liracl(lyricHUDsong, true)) then
					set image of light4 to green
				else
					set image of light4 to red
				end if
				
				set previdle to (lyricHUDsong)
			on error err
				if debuglogon then log err
				set image of light4 to red
			end try
			lyricHUD(lyricHUDsong, (localized string "HUD" from table "Localizable"), true)
			set visible of light4 to true
			
		else
			tell application "System Events"
				if tellerr then tell me to display dialog (localized string "No track in HUD..." from table "Localizable") buttons {(localized string "OK" from table "Localizable")} default button 1 with icon icon giving up after 15
			end tell
		end if
		
	else if nom is "sel" then
		tell application "iTunes" to set trackers to (get selection)
		multisel(trackers, true)
		if (count of trackers) is 1 then
			lyricHUD(item 1 of trackers, "Selection", false)
		else if lyricHUDtype is "Selection" then
			lyricHUD(lyricHUDsong, "Selection", false)
		end if
		(*
			--HOW MANY DID I FIND?
			--have to check button disablings
			--how to stop?
			-- \"Devo\" \"Whip It\""
			-- what didn't i find?
			-- phil collins sussudio (lockout ex)
			--errors for no internet connection?
			--fast mode
			*)
	else if nom is "showuntagged" then
		tell application "iTunes" to set currlists to name of every playlist
		set nlist to (localized string "Lyrics Not Found" from table "Localizable") & " "
		set n to 1
		repeat
			if currlists does not contain nlist & n as text then
				exit repeat
			else
				set n to n + 1
			end if
		end repeat
		tell application "iTunes"
			set np to make new user playlist
			set name of np to (nlist & n as text)
			repeat with i from 1 to count of fails
				--ignoring application responses
				try
					set theTrack to item i of fails
					--add (get location of theTrack) to np
					duplicate theTrack to np
				on error
					--
				end try
				--end ignoring
			end repeat
			reveal np
			activate
		end tell
		(*
		set o to "TITLE – ARTIST"
		repeat with i from 1 to count of fails
			set theTrack to item i of fails
			tell application "iTunes" to set o to o & return & name of theTrack & " – " & artist of theTrack
		end repeat
		tell application "TextEdit"
			set E to make new document at end of documents with properties {name:"Untagged"}
			tell E
				set its text to (o as text)
			end tell
			activate
		end tell*)
	else if nom is "edit_save" then
		if title of theObject is (localized string "Edit" from table "Localizable") then
			hudedit(true, false)
		else
			hudedit(false, true)
		end if
	else if nom is "changetrigger" then
		set visible of light2 to false
		set visible of light3 to false
		if (state of button "active" of window "main" is 1) then
			try
				set visible of light3 to true
				--log "test"
				set image of light3 to yellow
				tell application "iTunes" to set curr to current track
				if (my liracl(curr, false)) then
					set image of light3 to green
				else
					set image of light3 to red
				end if
				lyricHUD(curr, "Active", false)
			on error
				--
			end try
		end if
	else if nom is "refresheditfield" then
		if lyricHUDsong is not null then
			tell application "iTunes" to set lyr to lyrics of lyricHUDsong
			--set contents of tv to lyr
			--set tv to text view "text" of scroll view "scroll" of window "LyricsHUD"
			tell window "LyricsHUD"
				set contents of text view "text" of scroll view "scroll" to lyr
			end tell
		end if
	else if nom is "rmeditfield" then
		tell window "LyricsHUD"
			set contents of text view "text" of scroll view "scroll" to ""
		end tell
	else if nom is "textedit" then
		set tv to text view "text" of scroll view "scroll" of window "LyricsHUD"
		set t to text of tv
		tell application "TextEdit"
			make new document at end of documents with properties {text:t}
			activate
		end tell
	end if
end clicked

on hudedit(allow, saveit) -- allow upload when saving
	set tv to text view "text" of scroll view "scroll" of window "LyricsHUD"
	if allow then
		set editable of tv to true
		set title of button "edit_save" of window "LyricsHUD" to (localized string "Save" from table "Localizable")
	else
		set editable of tv to false
		set title of button "edit_save" of window "LyricsHUD" to (localized string "Edit" from table "Localizable")
	end if
	tell window "LyricsHUD"
		set enabled of button "re" to (not allow)
		set enabled of button "rmeditfield" to (allow)
		set visible of button "rmeditfield" to (allow)
		set enabled of button "refresheditfield" to (allow)
		set visible of button "refresheditfield" to (allow)
	end tell
	
	set t to text of tv
	if saveit then tell application "iTunes" to set lyrics of lyricHUDsong to t
end hudedit

on lyricHUD(song, type, forceshow)
	--log "lyricHUD"
	log (visible of window "LyricsHUD") as string
	set lyricHUDtype to type
	if (visible of window "LyricsHUD" is false) or (title of button "edit_save" of window "LyricsHUD" is (localized string "Edit" from table "Localizable")) then
		hudedit(false, false)
		tell application "iTunes"
			set lyricHUDsong to song
			set lyr to lyrics of song
			set n to name of song
			set a to artist of song
		end tell
		--log n & " - " & a
		
		tell window "LyricsHUD"
			--disable_edit(false)
			set title to (localized string type from table "Localizable") & " - " & n & " : " & a --(localized string "Lyrics" from table "Localizable") & " (" & 
			set contents of text view "text" of scroll view "scroll" to lyr
			set visible of light4 to false
			set myTextRef to a reference to (text of text view "text" of scroll view "scroll")
			set color of myTextRef to {65535, 65535, 65535}
			set alignment of text view "text" of scroll view "scroll" to center text alignment
			if forceshow then show
		end tell
	end if
	
end lyricHUD

on multisel(trackers, sel_light)
	set foundcount to 0
	set overwriteit to false
	if trackers is not {} then
		set enabled of button "sel" of window "main" to false
		--set enabled of button "active" of window "main" to false
		--tell progress indicator "prog" of window "main" to stop
		
		tell button "showuntagged" of window "hud"
			set visible to false
			set enabled to false
		end tell
		tell progress indicator "prog" of window "hud"
			start
			set indeterminate to true
			set content to 0
		end tell
		set of_local_string to " " & (localized string "of" from table "Localizable") & " "
		set contents of text field "msg" of window "hud" to ""
		set contents of text field "msg" of window "hud" to "0" & of_local_string & "0" & of_local_string & "" & (count of items in trackers)
		
		if (count of items in trackers) is greater than 1 then
			show window "hud"
			
			set thebuttons to {(localized string "No" from table "Localizable"), (localized string "Yes" from table "Localizable")}
			repeat with i from 1 to count of items in trackers
				tell application "iTunes"
					if (get lyrics of item i of trackers) is not "" then
						tell me to set overdiag to button returned of (display dialog (localized string "Would you like to overwrite any existing lyrics?" from table "Localizable") buttons thebuttons default button 1 with icon icon)
						
						if overdiag is not item 1 of thebuttons then set overwriteit to true
						--display dialog overwriteit
						
						exit repeat
					end if
				end tell
			end repeat
		else
			if sel_light then
				set image of light1 to yellow
				set visible of light1 to true
			end if
			set overwriteit to true
		end if
		
		tell progress indicator "prog" of window "hud"
			set maximum value to count of items in trackers
			set indeterminate to false
		end tell
		
		set startdt to current date
		set fails to {}
		
		repeat with i from 1 to count of items in trackers
			--ignoring application responses
			set theTrack to item i of trackers
			if (my liracl(theTrack, overwriteit)) then
				set foundcount to foundcount + 1
			else
				set end of fails to theTrack
			end if
			if (count of items in trackers) is greater than 1 then
				tell progress indicator "prog" of window "hud" to set content to i
				
				set est to ((current date) - startdt) / i * ((count of items in trackers) - i) as integer
				set estm to round est / 60 rounding down
				set ests to est - estm * 60
				if ests < 10 then set ests to "0" & ests
				
				set msg to foundcount & of_local_string & i & of_local_string & (count of items in trackers) & " (" & estm & ":" & ests & ")" as text
				set contents of text field "msg" of window "hud" to msg
			end if
			--end ignoring
		end repeat
		
		set est to ((current date) - startdt) as integer
		set estm to round est / 60 rounding down
		set ests to est - estm * 60
		if ests < 10 then set ests to "0" & ests
		set msg to (localized string "Done! Found: " from table "Localizable") & foundcount & of_local_string & (count of items in trackers) & " (" & estm & ":" & ests & ")" as text
		set contents of text field "msg" of window "hud" to msg
		--HOW MANY DID I FIND?
		--have to check button disablings
		--how to stop?
		-- \"Devo\" \"Whip It\""
		-- what didn't i find?
		-- phil collins sussudio (lockout ex)
		--errors for no internet connection?
		--fast mode
		if (count of items in trackers) is 1 and sel_light then
			if foundcount is 1 then
				set image of light1 to green
			else
				set image of light1 to red
			end if
		end if
		if (count of items in trackers) is greater than 1 and (count of items in trackers) is not foundcount then
			tell button "showuntagged" of window "hud"
				set visible to true
				set enabled to true
			end tell
		end if
		set enabled of button "sel" of window "main" to true
		--set enabled of button "active" of window "main" to true
		--if (state of button "active" of window "main") is 1 then tell progress indicator "prog" of window "main" to start
	else
		tell application "System Events" to tell me to display dialog (localized string "No tracks selected..." from table "Localizable") buttons {(localized string "OK" from table "Localizable")} default button 1 with icon icon giving up after 15
	end if
	--hide window "hud"
	return foundcount
end multisel

on showlyrics()
	set t to null
	tell application "iTunes"
		set sel to selection
		if (count of sel) is 1 then
			set t to item 1 of sel
			set h to "Selection"
		else if player state is not stopped then
			set t to current track
			set h to "Current"
		end if
	end tell
	if t is not null then
		lyricHUD(t, h, true)
	else
		tell application "System Events"
			tell me to display dialog (localized string "No tracks selected or playing." from table "Localizable") buttons {(localized string "OK" from table "Localizable")} default button 1 with icon icon giving up after 15
		end tell
	end if
end showlyrics

on showlyricsCurr()
	set t to null
	tell application "iTunes"
		set sel to selection
		if player state is not stopped then
			set t to current track
			set h to "Current"
		end if
	end tell
	if t is not null then
		lyricHUD(t, h, true)
	else
		tell application "System Events"
			tell me to display dialog (localized string "No track playing." from table "Localizable") buttons {(localized string "OK" from table "Localizable")} default button 1 with icon icon giving up after 15
		end tell
	end if
end showlyricsCurr

on showlyricsSel()
	set t to null
	tell application "iTunes"
		set sel to selection
		if (count of sel) is 1 then
			set t to item 1 of sel
			set h to "Selection"
		end if
	end tell
	log "have sel"
	if t is not null then
		lyricHUD(t, h, true)
		log "lyrichud should be up"
	else
		tell application "System Events"
			tell me to display dialog (localized string "No track selected (or you have more than one track selected)." from table "Localizable") buttons {(localized string "OK" from table "Localizable")} default button 1 with icon icon giving up after 15
		end tell
	end if
end showlyricsSel

on choose menu item theObject
	set nom to name of theObject
	if nom is "showmain" then
		show window "main"
	else if nom is "showpref" then
		show window "prefs"
	else if nom is "showlyrics" then
		showlyrics()
	else if nom is "checkvers" then
		check_vers(true)
	else if nom is "tagplaylist" then
		tell application "iTunes"
			set dc to view of front window
			set sel to every track of dc
		end tell
		
		multisel(sel, false)
	else if nom contains "_toggle" then
		set b to (1 is not the state of theObject)
		set the state of theObject to b
		writeDefaultEntry(thepreffile, nom, state of theObject)
	else if nom is "keepontop" then
		if state of theObject is 0 then
			set state of theObject to 1
			set level of window "main" to 3
		else
			set state of theObject to 0
			set level of window "main" to 0
		end if
		writeDefaultEntry(thepreffile, "keepontop", state of theObject)
	else if nom is "zh_search" then
		--log (state of theObject) as text
		if state of theObject is not 1 then
			set state of theObject to 1
			writeDefaultEntry(thepreffile, "gl-go-type", "zh")
		else
			set state of theObject to 0
			writeDefaultEntry(thepreffile, "gl-go-type", "en")
		end if
		--log (state of theObject) as text
		--my gl_go_check()
	end if
	
	--set title of menu item "inclyrhead_toggle" of sub menu of menu item 2 of main menu to "blah"
end choose menu item


(* Methods to initialize and manage iTunes observation *)
on will finish launching theObject
	set ITObserver to (call method "newITObserver" of class "ITObserver")
	call method "beginObservingiTunes" of ITObserver
	
end will finish launching

on will quit theObject
	call method "endObservingiTunes" of ITObserver
end will quit

on activated theObject
	selcheck()
end activated

on idle theObject
	try
		with timeout of 5 seconds
			selcheck()
		end timeout
	on error err
		--
	end try
	return 1
end idle






--Subroutines--

on liracl(theTrack, overwrite)
	--display dialog 1
	--log theTrack
	set phppath to POSIX path of (path to resource "go.php") --& "go.php"
	--log phppath
	--display dialog 1
	try
		tell application "iTunes"
			
			tell theTrack
				set origlyr to lyrics
				if (origlyr is not "") and (overwrite is false) then
					if (debuglogon) then log "keeping what we've got"
					return true
				end if
				--log "debug 1"
				set nom to (((name))) --my justletters my smallCaps
				--log nom
				set art to ((my clearparenth(artist))) --my justletters my smallCaps
				--log art
				--display dialog nom giving up after 1
			end tell
		end tell
		
		--log 1
		set lowernom to my titleCase(nom)
		set lowerart to my titleCase(art)
		set noms to {nom, lowernom, my stripAccents(nom), my clearparenth(lowernom), my justletters(my clearparenth(nom)), my clearfeat(my clearparenth(lowernom)), my switchText(lowernom, " & ", " And "), my switchText(lowernom, " And ", " & "), my switchText(lowernom, "’", "'"), my clear_A_The(my clearparenth(lowernom)), my switchText(lowernom, "$", "s"), my switchText(lowernom, "$", "S"), my switchWords(lowernom, "You", "U"), my switchWords(lowernom, "U", "You")}
		set arts to {art, lowerart, ("The " & lowerart), my clear_A_The(lowerart), my stripAccents(art), my clearfeat(lowerart), my clearand(lowerart), my clearparenth(art), my switchText(lowerart, " & ", " And "), my switchText(lowerart, " And ", " & "), my switchText(lowerart, "’", "'"), my switchText(lowerart, "$", "s"), my switchText(lowerart, "$", "S")}
		--log 2
		--, " \"" & art & "\" \"" & (nom) & "\""}
		--log "" & (count of noms) & "x" & (count of arts) & "=" & ((count of noms) * (count of arts))
		
		set dohead to state of menu item "inclyrhead_toggle" of sub menu of menu item 2 of main menu
		set dofoot to state of menu item "inclyrfoot_toggle" of sub menu of menu item 2 of main menu
		
		set artnoms to {}
		set keepgo to true
		repeat with ii from 1 to count of noms
			repeat with i from 1 to count of arts
				set artnom to " " & quoted form of (item i of arts) & " " & quoted form of (item ii of noms) & " " & dohead & " " & dofoot
				--log "artnom: " & artnom
				if artnoms does not contain artnom then
					set end of artnoms to artnom
					set sh to "php " & (quoted form of phppath) & artnom
					--if (debuglogon) then 
					log sh
					set res to (do shell script sh) as string
					--log res
					if (res is -1 or res is -2 or res is -3 or res is "") then
						--nada
					else
						set keepgo to false
						exit repeat
					end if
				end if
			end repeat
			if not keepgo then exit repeat
		end repeat
		
		if go_vers is "" then
			try
				set phppath to POSIX path of (path to resource "go.php")
				set sh to "head -n1  " & (quoted form of phppath) & " | grep php  | sed 's#.*//##'"
				set go_vers to (do shell script sh) as string
			on error
				set go_vers to ""
			end try
		end if
		
		my gl_go_check()
		
		set formbr to "php -r \"echo('http://shullian.com/lyric_reporter.php?&go=" & (go_vers) & "&vers=" & (myvers) & "&t='.urlencode(utf8_decode(" & switchText(quoted form of nom, "'\\''", "\\'") & ")).'&a='.urlencode(utf8_decode(" & switchText(quoted form of art, "'\\''", "\\'") & ")));\""
		if (debuglogon) then log formbr
		
		
		--set baserep to "http://shullian.com/lyric_reporter.php?t=" & urlencode(nom) & "&a=" & urlencode(art) & "&vers=" & urlencode(myvers)
		
		if (res is "") then
			
			set baserep to do shell script formbr
			set rep to baserep & "&found=0"
			report(rep)
			
			error "results were negative"
			
		end if
		
		try
			set baserep to do shell script formbr
			set rep to baserep & "&found=1"
			report(rep)
		on error
			--
		end try
		
		set LyricalF to res as string
		--if (debuglogon) then
		--log res
		tell application "iTunes"
			tell theTrack
				set lyrics to LyricalF as string
				if lyrics is "" then error "insert failed"
			end tell
		end tell
		
		if (debuglogon) then log "found"
		return true
	on error err
		--log "not found / " & err
	end try
	return false
end liracl

on report(tURL)
	if 1 is the state of menu item "failrpt_toggle" of sub menu of menu item 2 of main menu then
		try
			with timeout of 5 seconds
				--if (debuglogon) then
				
				set rep to "curl \"" & tURL & "\""
				set sh to rep & " > /dev/null 2>&1 &"
				if (debuglogon) then log sh
				do shell script sh
				
			end timeout
		on error err
			--display dialog err
		end try
	end if
end report

on stripAccents(str)
	return do shell script "echo " & (quoted form of str) & " | php -r '$title = file_get_contents(\"php://stdin\");$search = explode(\",\",\"ç,æ,œ,á,é,í,ó,ú,à,è,ì,ò,ù,ä,ë,ï,ö,ü,ÿ,â,ê,î,ô,û,å,e,i,ø,u\");$replace = explode(\",\",\"c,ae,oe,a,e,i,o,u,a,e,i,o,u,a,e,i,o,u,y,a,e,i,o,u,a,e,i,o,u\");echo str_replace($search, $replace, $title);'"
end stripAccents

on switchWords(str, from_s, to_s)
	set ws to words of str
	set o to ""
	repeat with i from 1 to count of ws
		set w to item i of ws
		if i is not 1 then set o to o & " "
		if w is from_s then
			set o to o & to_s
		else
			set o to o & w
		end if
	end repeat
	return o
end switchWords

on clearand(thetext)
	set n to offset of "& " in thetext
	if n is 0 then set n to offset of ", " in thetext
	if n is 0 then set n to offset of "and " in thetext
	return text 1 thru (n - 1) of thetext
end clearand

on clearfeat(thetext)
	set n to offset of "ft." in changecaseof(thetext, "lower")
	if n is 0 then set n to offset of "feat" in changecaseof(thetext, "lower")
	if n is 0 then set n to offset of "featuring" in changecaseof(thetext, "lower")
	return text 1 thru (n - 1) of thetext
end clearfeat

on clear_A_The(thetext)
	if word 1 of thetext is "A" then
		set thetext to text items 2 thru -1 of thetext
	else if word 1 of thetext is "The" then
		set thetext to text items 4 thru -1 of thetext
	end if
	return thetext as text
end clear_A_The

on switchText(tex, rem, neww)
	set d to text item delimiters
	set text item delimiters to rem
	set tex to tex's text items
	set text item delimiters to neww
	tell tex to set tex to beginning & ({""} & rest)
	set text item delimiters to d
	return tex
end switchText

on texttolist_delim(thetext, s)
	set {oldTIDs, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {s}} -- one line
	try
		set a to text items of thetext
	on error
		set a to my LargeTids(thetext, "0")
	end try
	set AppleScript's text item delimiters to oldTIDs
	return a
end texttolist_delim
on textToList(thetext, theSep)
	set soFar to {}
	set textSoFar to thetext
	repeat until theSep is not in textSoFar
		set thePos to the offset of theSep in textSoFar
		set thenewPos to thePos
		if thenewPos is 1 then set thenewPos to 2
		set nextBit to text 1 through (thenewPos - 1) of textSoFar
		if textSoFar is not theSep then
			set textSoFar to text (thePos + (count of text items in theSep)) through -1 of textSoFar
			copy nextBit to the end of soFar
		else
			set textSoFar to ""
		end if
	end repeat
	copy textSoFar to the end of soFar
	return soFar
end textToList

on clearparenth(thetext)
	set Lthetext to text items of thetext
	set tl to {}
	set kill to false
	repeat with i from 1 to count of items of Lthetext
		set this_item to item i of Lthetext
		if this_item is "(" or this_item is "[" then set kill to true
		if kill is false then set end of tl to this_item
		if this_item is ")" or this_item is "]" then set kill to false
	end repeat
	return tl as text
end clearparenth

on clearHTML(thetext)
	set Lthetext to text items of thetext
	set tl to {}
	set kill to false
	repeat with i from 1 to count of items of Lthetext
		set this_item to item i of Lthetext
		if this_item is "<" then set kill to true
		if kill is false then set end of tl to this_item
		if this_item is ">" then set kill to false
	end repeat
	return tl as text
end clearHTML

on justletters(teststring)
	if word 1 of teststring is "the" then set teststring to text 5 thru -1 of teststring
	set the testlist to the text items of the teststring
	set ns to {}
	repeat with letter in testlist
		set asc to the ASCII number of the letter
		if (asc is 32) or ((asc is greater than 96) and (asc is less than 123)) or ((asc is greater than 64) and (asc is less than 91)) then
			set end of ns to ASCII character asc
		end if
	end repeat
	set the teststring to the ns as text
	return the teststring
end justletters

on smallCaps(teststring)
	set the testlist to the text items of the teststring
	repeat with letter in testlist
		set asc to the ASCII number of the letter
		if (asc is greater than 64) and (asc is less than 91) then
			set the contents of the letter to ASCII character (asc + 32)
		end if
	end repeat
	set the teststring to the testlist as text
	return the teststring
end smallCaps

------------------
on check_vers(sayifok)
	--return
	
	if (debuglogon) then log "check_vers"
	
	try
		with timeout of 5 seconds
			set phppath to POSIX path of (path to resource "go.php")
			set sh to "head -n1  " & (quoted form of phppath) & " | grep php  | sed 's#.*//##'"
			set local_vers to (do shell script sh) as string
			set go_vers to local_vers
			log "go_vers L: " & local_vers
			
			do shell script "curl -o '/tmp/go.php' -g 'http://shullian.com/glgo.txt'"
			
			set sh to "head -n1 '/tmp/go.php'  | grep php  | sed 's#.*//##'"
			set online_vers to (do shell script sh) as string
			log "go_vers O: " & online_vers
			
			set diff to (local_vers is less than online_vers)
			if diff then
				set sh to "echo " & (quoted form of phppath) & " | sed 's#php$#orig.php#'"
				set newloc to (do shell script sh)
				try
					set sh to "cp -n " & (quoted form of phppath) & " " & (quoted form of newloc)
					do shell script sh
				on error
					--n
				end try
				
				set sh to "cp -f '/tmp/go.php' " & (quoted form of phppath)
				do shell script sh
				
				set go_vers to online_vers
				log "updated go"
			end if
		end timeout
	on error err
		log err
		--nada
	end try
	
	try
		with timeout of 5 seconds
			set thevers to do shell script "curl -g 'http://shullian.com/versions.php?app=getlyrical'"
			set thevers to getBW(thevers, "<version>", "</version>", 1)
			--log "have: " & myvers & " | server: " & thevers & " | " & (myvers is less than thevers)
		end timeout
		if myvers is less than thevers then
			tell application "System Events"
				tell me to set UDdiag to display dialog (localized string "Not up to date (current version: " from table "Localizable") & myvers & ", " & (localized string "latest version: " from table "Localizable") & thevers & ")." & return & (localized string "Update now?" from table "Localizable") buttons {(localized string "Not Yet" from table "Localizable"), (localized string "Get Update" from table "Localizable")} default button 2 with icon icon --attached to window "Freeopardy"
			end tell
			if button returned of UDdiag is (localized string "Get Update" from table "Localizable") then
				open location "http://shullian.com/"
			end if
		else if sayifok then
			tell application "System Events"
				tell me to display dialog (localized string "You are up to date (version: " from table "Localizable") & myvers & ")." buttons {(localized string "OK" from table "Localizable")} default button 1 with icon icon --attached to window "Freeopardy"
			end tell
		end if
	on error err
		log err
		if sayifok then
			tell application "System Events"
				tell me to set UDdiag to display dialog (localized string "Unable to check version. Do you have an internet connection? You can also check http://shullian.com.") buttons {"shullian.com", (localized string "OK" from table "Localizable")} default button 2 with icon icon
			end tell
			if button returned of UDdiag is "shullian.com" then
				open location "http://shullian.com/"
			end if
		end if
	end try
	
	
end check_vers
on getBW(base, s1, s2, ind)
	return item 1 of texttolist_delim(item (ind + 1) of texttolist_delim(base, s1), s2)
end getBW

on urlencode(thetext)
	set theTextEnc to ""
	repeat with eachChar in characters of thetext
		set useChar to eachChar
		set eachCharNum to ASCII number of eachChar
		if eachCharNum = 32 then
			set useChar to "+"
		else if (eachCharNum ≠ 42) and (eachCharNum ≠ 95) and (eachCharNum < 45 or eachCharNum > 46) and (eachCharNum < 48 or eachCharNum > 57) and (eachCharNum < 65 or eachCharNum > 90) and (eachCharNum < 97 or eachCharNum > 122) then
			set firstDig to round (eachCharNum / 16) rounding down
			set secondDig to eachCharNum mod 16
			if firstDig > 9 then
				set aNum to firstDig + 55
				set firstDig to ASCII character aNum
			end if
			if secondDig > 9 then
				set aNum to secondDig + 55
				set secondDig to ASCII character aNum
			end if
			set numHex to ("%" & (firstDig as string) & (secondDig as string)) as string
			set useChar to numHex
		end if
		set theTextEnc to theTextEnc & useChar as string
	end repeat
	return theTextEnc
end urlencode


on writeDefaultEntry(preffile, prefname, prefValue)
	--set prefValue to prefValue as text
	--tell application "Finder"
	set prefvals to do shell script ("defaults write " & quoted form of preffile & " " & quoted form of prefname & " " & quoted form of (prefValue as string) & "")
	--end tell
	--log "wrote pref " & prefname & ": " & prefValue
end writeDefaultEntry
on readDefaultEntry(preffile, prefname, prefValue)
	--set prefValue to prefValue as text
	--tell application "Finder"
	try
		set prefValue to do shell script ("defaults read " & quoted form of preffile & " " & quoted form of prefname & "")
	on error
		my writeDefaultEntry(preffile, prefname, prefValue)
	end try
	--display dialog 1 default answer "defaults read '" & preffile & "' '" & prefname & "'"
	--end tell
	--log "read pref " & prefname & ": " & prefValue
	try
		if (prefValue as number) is prefValue then
			return prefValue as number
		else
			error
		end if
	on error
		return prefValue as Unicode text
	end try
end readDefaultEntry

on changecaseof(thistext, thiscase)
	if thiscase is "lower" then
		set the comparisonstring to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		set the sourcestring to "abcdefghijklmnopqrstuvwxyz"
	else
		set the comparisonstring to "abcdefghijklmnopqrstuvwxyz"
		set the sourcestring to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	end if
	set the newtext to ""
	repeat with thisChar in thistext
		set x to the offset of thisChar in the comparisonstring
		if x is not 0 then
			set the newtext to (the newtext & character x of the sourcestring) as string
		else
			set the newtext to (the newtext & thisChar) as string
		end if
	end repeat
	return the newtext
end changecaseof
on titleCase(_string)
	set _code to "import sys; print sys.argv[1].title()"
	set _script to "/usr/bin/python -c " & _code's quoted form & " " & _string's quoted form
	return do shell script _script
end titleCase


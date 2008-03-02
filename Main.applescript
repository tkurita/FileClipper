property loader : proxy_with({autocollect:true}) of application (get "FileClipperLib")

on load(a_name)
	return loader's load(a_name)
end load

property FileUtil : load("FileUtility")
property UniqueNamer : UniqueNamer of FileUtil
property PathAnalyzer : PathAnalyzer of FileUtil
property InsertionLocator : load("InsertionLocator")'s set_allow_closed_folder(false)
property ShellUtils : load("ShellUtils")
property GUIScriptingChecker : load("GUIScriptingChecker")

property do_file : missing value

on move_clip_item(a_source, a_destination)
	moveItem of FileUtil from a_source into a_destination given name:"", mode:3
end move_clip_item

on make_alias(a_source, a_destination)
	tell application "Finder"
		make alias file at a_destination to a_source
	end tell
end make_alias

on make_symbolick_link(a_source, a_destination)
	set a_name to name of (do(a_source) of PathAnalyzer)
	set a_name to do of UniqueNamer about a_name at a_destination
	set a_target to (a_destination as Unicode text) & a_name
	make_symbolick_link of ShellUtils from a_source into a_target with relativePath
	tell application "Finder"
		update file a_target
	end tell
end make_symbolick_link

on copy_clip_item(a_source, a_destination)
	copyItem of FileUtil from a_source into a_destination given name:"", mode:3
end copy_clip_item

on show_message(a_msg)
	activate
	hide window "Progress"
	display dialog a_msg buttons {"OK"} default button "OK" with icon note
end show_message

on show_alert(a_message, sub_message)
	activate
	hide window "Progress"
	display alert a_message message sub_message
end show_alert

on will open theObject
	set coordinate system to AppleScript coordinate system
	if InsertionLocator's is_location_in_window() then
		tell application "Finder"
			set fwin_bounds to bounds of Finder window 1
		end tell
		set x_pos to ((item 1 of fwin_bounds) + (item 3 of fwin_bounds)) / 2
		set y_pos to ((item 2 of fwin_bounds) + (item 4 of fwin_bounds)) / 2
		set win_size to size of theObject
		set x_pos to x_pos - (item 1 of win_size) / 2
		set y_pos to y_pos - (item 2 of win_size) / 2
		set position of theObject to {x_pos, y_pos}
	end if
	
end will open

on bool_value(a_bool)
	return (a_bool is 1)
end bool_value

on launched theObject
	if not do() of GUIScriptingChecker then
		-- GUI Scripting is disable
		return
	end if
	set target_location to InsertionLocator's do()
	show window "Progress"
	set a_list to call method "getContents" of class "FilesInPasteboard"
	try
		get a_list
	on error
		set a_msg to localized string "NoFilesInClipboard"
		show_message(a_msg)
		quit
		return
	end try
	
	set an_identifier to identifier of main bundle
	if an_identifier is "MoveToHere" then
		set do_file to move_clip_item
	else if an_identifier is "make_aliasFileToHere" then
		set do_file to make_alias
	else if an_identifier is "make_symbolick_linkToHere" then
		set do_file to make_symbolick_link
	else if an_identifier is "CopyToHere" then
		set do_file to copy_clip_item
	end if
	
	set file_manager to call method "defaultManager" of class "NSFileManager"
	repeat with an_item in a_list
		set is_exists to call method "fileExistsAtPath:" of file_manager with parameter an_item
		set is_exists to bool_value(is_exists)
		if not is_exists then
			set a_msg to localized string "fileIsNotFound"
			--set a_msg to a_msg & return & an_item
			--show_message(a_msg)
			show_alert(a_msg, an_item)
			exit repeat
		end if
		
		try
			do_file(POSIX file an_item, target_location)
		on error errMsg number errN
			if errN is -48 then
				set a_msg to localized string "SameNameExists"
				show_message(a_msg)
			else if errN is not -1712 then
				show_message(errMsg)
			end if
		end try
	end repeat
	
	--beep
	quit
end launched


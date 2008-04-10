property loader : proxy_with({autocollect:true}) of application (get "FileClipperLib")

on load(a_name)
	return loader's load(a_name)
end load

property XFile : load("XFile")
property UniqueNamer : UniqueNamer of XFile
property PathAnalyzer : PathAnalyzer of XFile
property InsertionLocator : load("InsertionLocator")'s set_allow_closed_folder(false)
property ShellUtils : load("ShellUtils")
property GUIScriptingChecker : load("GUIScriptingChecker")

property do_file : missing value

on do_svn(svn_action, a_source, a_destination)
	set x_source to XFile's make_with(a_source)
	set source_dir to x_source's parent_folder()'s posix_path()
	if (source_dir & "/") is (a_destination's POSIX path) then
		set a_name to x_source's item_name()
		activate
		try
			set a_result to display dialog "Enter File Name :" default answer a_name
		on error number -128
			return
		end try
		set new_name to text returned of a_result
		if new_name is a_name then
			return
		end if
		set a_destination to new_name
	else
		set a_destination to POSIX path of a_destination
	end if
	
	set source_dir to source_dir's quoted form
	set source_name to x_source's item_name()'s quoted form
	set a_destination to quoted form of a_destination
	set a_shell to system attribute "SHELL"
	set cd_command to "cd " & source_dir & ";"
	set all_command to cd_command & a_shell & " -lc 'svn $0 $1 $2' " & svn_action & space & source_name & space & a_destination
	log all_command
	do shell script all_command
end do_svn

on svn_copy(a_source, a_destination)
	do_svn("cp", a_source, a_destination)
end svn_copy

on svn_move(a_source, a_destination)
	do_svn("mv", a_source, a_destination)
end svn_move

on move_clip_item(a_source, a_destination)
	--moveItem of FileUtil from a_source into a_destination given name:"", mode:3
	set x_source to XFile's make_with(a_source)
	set x_dest to XFile's make_with(a_destination)
	set x_dest to x_dest's unique_child(x_source's item_name())
	x_source's move_to(x_dest)
	tell application "Finder"
		update file (x_dest's hfs_path())
	end tell
end move_clip_item

on make_alias(a_source, a_destination)
	tell application "Finder"
		make alias file at a_destination to a_source
	end tell
end make_alias

on make_symbolic_link(a_source, a_destination)
	set a_name to name of (do(a_source) of PathAnalyzer)
	set a_name to do of UniqueNamer about a_name at a_destination
	set a_target to (a_destination as Unicode text) & a_name
	symlink of ShellUtils from a_source into a_target with relative
	tell application "Finder"
		update file a_target
	end tell
end make_symbolic_link

on copy_clip_item(a_source, a_destination)
	set x_source to XFile's make_with(a_source)
	set x_dest to XFile's make_with(a_destination)
	set x_dest to x_dest's unique_child(x_source's item_name())
	x_source's copy_to(x_dest)
	tell application "Finder"
		update file (x_dest's hfs_path())
	end tell
	--copyItem of FileUtil from a_source into a_destination given name:"", mode:3
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
	log target_location
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
	else if an_identifier is "MakeAliasFileToHere" then
		set do_file to make_alias
	else if an_identifier is "MakeSymbolicLinkToHere" then
		set do_file to make_symbolic_link
	else if an_identifier is "CopyToHere" then
		set do_file to copy_clip_item
	else if an_identifier is "SVNCopy" then
		set do_file to svn_copy
	else if an_identifier is "SVNMove" then
		set do_file to svn_move
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
			log target_location
			do_file(POSIX file an_item, target_location)
		on error a_msg number errn
			if errn is -48 then
				set a_msg to localized string "SameNameExists"
				show_message(a_msg)
			else if errn is not -1712 then
				show_message(a_msg)
			end if
		end try
	end repeat
	
	--beep
	quit
end launched


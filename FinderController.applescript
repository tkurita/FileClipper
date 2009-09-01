property loader : proxy_with({autocollect:true}) of application (get "FileClipperLib")

on load(a_name)
	return loader's load(a_name)
end load

property InsertionLocator : load("InsertionLocator")'s set_allow_closed_folder(false)

on insertion_location()
	set a_location to InsertionLocator's do()
	return POSIX path of a_location
end insertion_location

on center_of_finderwindow()
	if InsertionLocator's is_location_in_window() then
		tell application "Finder"
			set fwin_bounds to bounds of Finder window 1
		end tell
		set x_pos to ((item 1 of fwin_bounds) + (item 3 of fwin_bounds)) / 2
		set y_pos to ((item 2 of fwin_bounds) + (item 4 of fwin_bounds)) / 2
		return {x_pos, y_pos}
	end if
	return {}
end center_of_finderwindow
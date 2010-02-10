--property loader : proxy_with({autocollect:true}) of application (get "FileClipperLib")
(*
property loader : proxy() of application (get "FileClipperLib")

on load(a_name)
	return loader's load(a_name)
end load
*)
property GUIScriptingChecker : module
property loader : boot (module loader of application (get "FileClipperLib")) for me

on run
	tell GUIScriptingChecker
		set_delegate(me)
		set is_enabled to do()
	end tell
	--log is_enabled
	return is_enabled
end run

on ok_button()
	return localized string "Enable GUI Scripting"
end ok_button

on cancel_button()
	return localized string "Cancel"
end cancel_button

on title_message()
	return localized string "GUI Scripting is not enabled."
end title_message

on detail_message()
	return localized string "Enable GUI Scripting ?"
end detail_message
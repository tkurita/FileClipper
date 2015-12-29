property GUIScriptingChecker : module
property XText : module
property loader : boot (module loader of application (get "FileClipperLib")) for me

on run
	tell GUIScriptingChecker
		if is_mavericks() then
			set_delegate(MessageProvider109)
		else
			set_delegate(MessageProvider)
		end if
		set is_enabled to do()
	end tell
	return is_enabled
end run

script MessageProvider
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
end script

script MessageProvider109
	on ok_button()
		return localized string "Open System Preferences"
	end ok_button
	
	on cancel_button()
		return localized string "Deny"
	end cancel_button
	
	on title_message()
		set a_format to localized string "need accessibility"
		return XText's formatted_text(a_format, {name of current application})
	end title_message
	
	on detail_message()
		return localized string "Grant access"
	end detail_message
end script
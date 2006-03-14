property FileUtil : load("FileUtility") of application "FileClipperLib"
property UniqueNamer : UniqueNamer of FileUtil
property PathAnalyzer : PathAnalyzer of FileUtil
property InsertionLocation : load("InsertionContainer") of application "FileClipperLib"
property ShellUtils : load("ShellUtils") of application "FileClipperLib"

property _insetionLocation : missing value
property doFile : missing value

on moveClipItem(sourceItem, destinationFolder)
	moveItem of FileUtil from sourceItem into destinationFolder given name:"", mode:3
end moveClipItem

on makeAlias(sourceItem, destinationFolder)
	tell application "Finder"
		make alias file at destinationFolder to sourceItem
	end tell
end makeAlias

on makeSymbolicLink(sourceItem, destinationFolder)
	set theName to name of (do(sourceItem) of PathAnalyzer)
	set theName to do of UniqueNamer about theName at destinationFolder
	set theTarget to (destinationFolder as Unicode text) & theName
	makeSymbolicLink of ShellUtils from sourceItem into theTarget with relativePath
	tell application "Finder"
		update file theTarget
	end tell
end makeSymbolicLink

on copyClipItem(sourceItem, destinationFolder)
	copyItem of FileUtil from sourceItem into destinationFolder given name:"", mode:3
end copyClipItem

on showMessage(theMessage)
	activate
	hide window "Progress"
	display dialog theMessage buttons {"OK"} default button "OK" with icon note
end showMessage

on will open theObject
	set coordinate system to AppleScript coordinate system
	set _insetionLocation to do() of InsertionLocation
	
	if _isInFinderWindow of InsertionLocation then
		tell application "Finder"
			set fwinBounds to bounds of Finder window 1
		end tell
		set xPos to ((item 1 of fwinBounds) + (item 3 of fwinBounds)) / 2
		set yPos to ((item 2 of fwinBounds) + (item 4 of fwinBounds)) / 2
		set winSize to size of theObject
		set xPos to xPos - (item 1 of winSize) / 2
		set yPos to yPos - (item 2 of winSize) / 2
		set position of theObject to {xPos, yPos}
	end if
	
end will open

on launched theObject
	set theList to call method "getContents" of class "FilesInPasteboard"
	try
		get theList
	on error
		set theMessage to localized string "NoFilesInClipboard"
		showMessage(theMessage)
		quit
		return
	end try
	
	set theIdentifier to identifier of main bundle
	if theIdentifier is "MoveToHere" then
		set doFile to moveClipItem
	else if theIdentifier is "MakeAliasFileToHere" then
		set doFile to makeAlias
	else if theIdentifier is "MakeSymbolicLinkToHere" then
		set doFile to makeSymbolicLink
	else if theIdentifier is "CopyToHere" then
		set doFile to copyClipItem
	end if
	
	set fileManager to call method "defaultManager" of class "NSFileManager"
	repeat with theItem in theList
		set isExists to call method "fileExistsAtPath:" of fileManager with parameter theItem
		
		if not isExists then
			set theMessage to localized string "fileIsNotFound"
			set theMessage to theMessage & return & theItem
			showMessage(theMessage)
			exit repeat
		end if
		
		try
			doFile(POSIX file theItem, _insetionLocation)
		on error errMsg number errN
			if errN is -48 then
				set theMessage to localized string "SameNameExists"
				showMessage(theMessage)
			else if errN is not -1712 then
				showMessage(errMsg)
			end if
		end try
	end repeat
	
	--beep
	quit
end launched


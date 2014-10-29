

#Include %A_ScriptDir%\ahk_modules\Json2.ahk
global uo := {} ;short for userObject

; check that userconfig file exists
file := FileOpen("userconfig.txt", "r")
if (file = 0) {
	file.Close()
	; InputBox, pathToLive, File path of LIve, Please enter the file path to the Live.exe file on your computer (you only have to do this once)
	file := FileOpen("userconfig.txt", "w")
	if !IsObject(file)
		{
			MsgBox Can't open "%FileName%" for writing.
			return
		}
	file.Close()
}

; read userconfig and initialize if empty
FileRead, userConfigText, %A_ScriptDir%\userconfig.txt
if (userConfigText = ""){
	uo.scriptPaths := {}
	uo.scriptPaths1 := {none: "--none--", path1: "C:\ProgramData\Ableton\Live 9 Suite\Resources\MIDI Remote Scripts", path2: " ", path3: " ", path4: " ", path5: " "}
	uo.scriptPaths2 := {none: "--none--", path1: "--none--", path2: "C:\ProgramData\Ableton\Live 9 Suite\Resources\MIDI Remote Scripts", path3: " ", path4: " ", path5: " "}
	uo.livePath := "C:\ProgramData\Ableton\Live 9 Suite\Program\Ableton Live 9 Suite.exe"
	uo.loadLiveHotkey := "^!;"
	uo.closeLiveHotkey := "^!l"
	uo.reloadGuiHotkey := "^!8"
	uo.suppressDeleteConfirmation := 1
	
	file := FileOpen("userconfig.txt", "w")
	if !IsObject(file)
	{
		MsgBox Can't open "%FileName%" for writing.
		return
	}
	uoSerialized := _Json2(uo)
	file.WriteLine(uoSerialized)
	file.Close()
	FileRead, userConfigText, %A_ScriptDir%\userconfig.txt
}

guiInitialize:
uo := Json2(userConfigText)
path1 := uo.scriptPaths1.path1
path2 := uo.scriptPaths1.path2
path3 := uo.scriptPaths1.path3
path4 := uo.scriptPaths1.path4
path5 := uo.scriptPaths1.path5
path1_2 := uo.scriptPaths2.path1
path2_2 := uo.scriptPaths2.path2
path3_2 := uo.scriptPaths2.path3
path4_2 := uo.scriptPaths2.path4
path5_2 := uo.scriptPaths2.path5
none := uo.scriptPaths1.none
none_2 := uo.scriptPaths2.none
livePath := uo.livePath
loadLiveHotkey := uo.loadLiveHotkey
closeLiveHotkey := uo.closeLiveHotkey
reloadGuiHotkey := uo.reloadGuiHotkey
suppressDeleteConfirmation := uo.suppressDeleteConfirmation

Hotkey,%loadLiveHotkey%,loadLive
Hotkey,%closeLiveHotkey%,closeLive
Hotkey,%reloadGuiHotkey%,guiInitialize



; guiStart:
Gui, New, , Live-Reloader
Gui, Add, Text,, Path of control script directory to clean:
Gui, Add, ComboBox, w475 vscriptPath1, %path1%||%path2%|%path3%|%path4%|%path5%|%none%,
Gui, Add, Text,, Path of second control script directory to clean (optional):
Gui, Add, ComboBox, w475 vscriptPath2, %path1_2%||%path2_2%|%path3_2%|%path4_2%|%path5_2%|%none_2%
Gui, Add, Text,, Path to live.exe:
Gui, Add, Edit, vlivePath, %livePath%
if (suppressDeleteConfirmation = 1)
{
	Gui, Add, Checkbox, Checked 1 vsuppressDeleteConfirmation, Show message for .pyc file delete success?
}
else
{
	Gui, Add, Checkbox, vsuppressDeleteConfirmation, Show message for .pyc file delete success?
}
Gui, Add, Button, default section w75 xp+195 yp+35, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.

Gui, Show,, Live-Reloader
return  ; End of auto-execute section. The script is idle until the user does something.

GuiClose:
MsgBox, 3, Live-Reloader exit window, Do you want to exit?
ifMsgBox Yes
	ExitApp
ifMsgBox No
{
	Gui, Hide
	return
}
ifMsgBox Cancel
{
	return
}
ButtonOK:
Gui, Submit  ; Save the input from the user to each control's associated variable.
; update uo object and write it to userconfig, update variable hotkeys, and reformat script paths

scriptPath1 := RegExReplace(scriptPath1, "$\\", Replacement = "")
scriptPath2 := RegExReplace(scriptPath2, "$\\", Replacement = "")

uo.livePath := livePath
uo.suppressDeleteConfirmation := suppressDeleteConfirmation

if (uo.scriptPaths1.path1 != scriptPath1){
	uo.scriptPaths1.path2 := path1
	uo.scriptPaths1.path3 := path2
	uo.scriptPaths1.path4 := path3
	uo.scriptPaths1.path5 := path4
	uo.scriptPaths1.path1 := scriptPath1
}
if (uo.scriptPaths2.path1 != scriptPath2){
	uo.scriptPaths2.path2 := path1_2
	uo.scriptPaths2.path3 := path2_2
	uo.scriptPaths2.path4 := path3_2
	uo.scriptPaths2.path5 := path4_2
	uo.scriptPaths2.path1 := scriptPath2
}
file := FileOpen("userconfig.txt", "w")
if !IsObject(file)
{
	MsgBox Can't open "%FileName%" for writing.
	return
}
uoSerialized := _Json2(uo)
file.WriteLine(uoSerialized)
file.Close()

; reinitialize userConfigText for future gui submits
FileRead, userConfigText, %A_ScriptDir%\userconfig.txt
return


; HOTKEYS
loadLive:
{
SetTitleMatchMode, 2

if (scriptPath1 != "--none--")
{
	try {
		FileDelete, %scriptPath1%\*.pyc
	} catch e {
		MsgBox % "An error occurred trying to delete files in scriptPath1:`n`n" . e.Line . "`n" . e.Message . "n" . e.Extra
		return
	}
}
if (scriptPath2 != "--none--")
{
	try {
		FileDelete, %scriptPath2%\*.pyc
	} catch e {
		MsgBox % "An error occurred trying to delete files in scriptPath2:`n`n" . e.Line . "`n" . e.Message . "n" . e.Extra
		return
	}
}

if (scriptPath1 = "--none--" and scriptPath2 = "--none--")
{
	MsgBox, 2, No directories have been selected to delete .pyc files, your script may not update on reload.  Is this correct?
	ifMsgBox Yes
	{
	}
	ifMsgBox No
	{
		; Goto guiStart
	}
}
;log
MsgBox, 262144,, .pyc files deleted successfully

IfWinNotExist, Ableton Live 9 Suite
{
	Run, %livePath%
}
else
{
	WinClose, Ableton Live 9 Suite
	closedCounter := 0
	SetTimer, checkIsClosed, 250
	checkIsClosed:
		IfWinNotExist, Ableton Live 9 Suite
		{	
			setTimer, checkIsClosed, Off
			if (scriptPath != "--none--")
			{
				FileDelete, %scriptPath%
			}
			Run, %livePath%
			return
		}
		closedCounter++
		if (closedCounter = 50)
		{
			MsgBox Could not close Live before timeout`n`nAborting reload
			return
		}
}
return
}

closeLive:
{
	SetTitleMatchMode, 2
	WinClose, Ableton Live 9 Suite
	return
}
